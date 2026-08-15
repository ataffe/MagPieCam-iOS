//
//  AuthService.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/17/26.
//

import Foundation
import os


extension Logger {
    nonisolated static let auth = Logger(
        subsystem: "scout.scoutcam",
        category: "auth"
    )
}

enum AuthError: Error {
    case emailAlreadyExists
    case invalidCredentials
    case validationFailed([String: String])
    case network
    case unexpected
    case accoutCreatedButSessionNoSaved
    case sessionExpired
}

actor AuthService {
    private let apiClient: ApiClient
    private let keychainStore: KeychainStore
    private let authState: AuthState
    
    private struct RefreshRequest: Encodable {
        let refresh: String
    }

    private struct RefreshResponse: Decodable {
        let access: String
    }

    struct LoginRequest: Encodable {
        let email: String
        let username: String
        let password: String
    }
    
    struct LoginResponse: Decodable {
        let refresh: String
        let access: String
    }
    
    struct SignUpRequest: Encodable {
        let firstName: String
        let lastName: String
        let email: String
        let password: String
    }
    
    struct User: Decodable {
        let publicUserId: String
        let username: String
    }
    
    struct SignUpResponse: Decodable {
        let user: User
        let access: String
        let refresh: String
    }
    
    struct ApnsTokenRequest: Encodable {
        let apnsDeviceId: String
    }
    
    enum TokenKey {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
    }
    
    init(
        apiClient: ApiClient,
        keychainStore: KeychainStore = KeychainStore(),
        authState: AuthState
    ) {
        self.apiClient = apiClient
        self.keychainStore = keychainStore
        self.authState = authState
    }
    
    func login(email: String, password: String) async throws -> Void {
        let body = LoginRequest(email: email, username: email, password: password)
        
        let response: LoginResponse
        do {
            response = try await apiClient
                .request(endpoint: AuthEndpoint.logIn, body: body)
        } catch let APIError.encodingError(error) {
            Logger.auth.error("Unable to encode user login request to json: \(error).")
            return
        } catch let APIError.decodingError(error){
            Logger.auth.error("Unable to decode user login response from json: \(error)")
            return
        } catch APIError.unauthorized {
            Logger.auth.debug("Inavlid credentials")
            throw AuthError.invalidCredentials
        } catch let APIError.validationErrors(fields) {
            throw AuthError.validationFailed(fields.compactMapValues({$0.first}))
        } catch {
            Logger.auth.error("Unexpected error while logging in user up: \(error).")
            throw AuthError.unexpected
        }
        
        do {
            try keychainStore.save(response.access, for: TokenKey.accessToken)
            try keychainStore.save(response.refresh, for: TokenKey.refreshToken)
        }  catch let KeychainError.unableToSave(status) {
            Logger.auth.error("Tokens failed to persist after successful signup: \(status)")
            await apiClient.setAuthToken(response.access)
            throw AuthError.accoutCreatedButSessionNoSaved
        }
        await apiClient.setAuthToken(response.access)
        
        await MainActor.run {
            authState.status = .signedIn
        }
    }
    
    func signUp(
        firstName: String,
        lastName: String,
        email: String,
        password: String
    ) async throws -> Void {
        let body = SignUpRequest(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password
        )
        
        let response: SignUpResponse
        do {
            response = try await apiClient.request(endpoint: AuthEndpoint.signUp, body: body)
        } catch let APIError.encodingError(error) {
            Logger.auth.error("Unable to encode user signup request to json: \(error).")
            return
        } catch let APIError.decodingError(error){
            Logger.auth.error("Unable to decode user signup response from json: \(error)")
            return
        } catch let APIError.validationErrors(fields) {
            Logger.auth.debug("Validation failed: \(fields)")
            throw AuthError.validationFailed(fields.compactMapValues({$0.first}))
        } catch {
            Logger.auth
                .error("Unexpected error while signing user up: \(error).")
            throw AuthError.unexpected
        }
        
        do {
            try keychainStore.save(response.access, for: TokenKey.accessToken)
            try keychainStore.save(response.refresh, for: TokenKey.refreshToken)
        }  catch let KeychainError.unableToSave(status) {
            Logger.auth.error("Tokens failed to persist after successful signup: \(status)")
            await apiClient.setAuthToken(response.access)
            throw AuthError.accoutCreatedButSessionNoSaved
        }
        await apiClient.setAuthToken(response.access)
        Logger.auth.info("User signed up successfully!")
        
        await MainActor.run { authState.status = .signedIn }
    }
    
    func restoreSession() async -> Void {
        do {
            if let access = try keychainStore.read(TokenKey.accessToken) {
                await apiClient.setAuthToken(access)
                await MainActor.run { authState.status = .signedIn }
            } else {
                await MainActor.run { authState.status = .signedOut }
            }
        } catch let KeychainError.unableToRead(status) {
            Logger.auth.error("Unable to read token from keychain: \(status)")
        } catch {
            Logger.auth.error("Unable to read token from keychain: \(error)")
        }
    }
    
    /// Returns a valid access token, refreshing it first if it has expired.
    /// Called by ApiClient's token provider before each authenticated request.
    func validAccessToken() async throws -> String? {
        guard let accessToken = try keychainStore.read(TokenKey.accessToken) else { return nil }
        guard JWT.isExpired(accessToken) else { return accessToken }
        return try await refreshAccessToken()
    }

    private func refreshAccessToken() async throws -> String {
        guard let refreshToken = try keychainStore.read(TokenKey.refreshToken) else {
            Logger.auth.info("No refresh token found — signing out.")
            await signOut()
            throw AuthError.sessionExpired
        }

        let response: RefreshResponse
        do {
            response = try await apiClient.requestUnauthenticated(
                endpoint: AuthEndpoint.refreshToken,
                body: RefreshRequest(refresh: refreshToken)
            )
        } catch APIError.unauthorized {
            Logger.auth.info("Refresh token rejected — signing out.")
            await signOut()
            throw AuthError.sessionExpired
        } catch {
            Logger.auth.error("Token refresh failed: \(error)")
            throw AuthError.network
        }

        do {
            try keychainStore.save(response.access, for: TokenKey.accessToken)
        } catch {
            Logger.auth.error("Failed to persist refreshed access token: \(error)")
        }
        Logger.auth.debug("Access token refreshed successfully.")
        return response.access
    }

    private func signOut() async {
        keychainStore.delete(TokenKey.accessToken)
        keychainStore.delete(TokenKey.refreshToken)
        await apiClient.deleteAuthToken()
        await MainActor.run { authState.status = .signedOut }
    }

    func updateApnsToken(_ token: String) async {
        do {
            try await apiClient.request(
                endpoint: UserEndpoint.updateApnsToken,
                body: ApnsTokenRequest(apnsDeviceId: token)
            )
            Logger.auth.info("APNS token uploaded successfully.")
        } catch {
            Logger.auth.error("Failed to upload APNS token: \(error.localizedDescription)")
        }
    }

    func logOut() async {
        Logger.auth.info("User logged out successfully!")
        await signOut()
    }
}
