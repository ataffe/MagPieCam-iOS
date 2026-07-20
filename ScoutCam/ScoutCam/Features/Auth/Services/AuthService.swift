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
}

actor AuthService {
    private let apiClient: ApiClient
    private let keychainStore: KeychainStore
    private let authState: AuthState
    
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
    
    func logOut() async {
        keychainStore.delete(TokenKey.accessToken)
        keychainStore.delete(TokenKey.refreshToken)
        Logger.auth.info("User logged out successfully!")
        await apiClient.deleteAuthToken()
        await MainActor.run { authState.status = .signedOut }
    }
}
