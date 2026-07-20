//
//  LoginViewModel.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/14/26.
//

import Foundation


@Observable
@MainActor
final class LoginViewModel {
    private let authService: AuthService
    
    var email: String = "" {
        didSet {
            let lowered = email.lowercased()
            if email != lowered {
                email = lowered
            }
        }
    }
    var password: String = ""
    var isLoading = false
    var generalError = ""
    var fieldErrors: [String: String] = [:]
    
    var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    var isEmailValid: Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func login() async {
        isLoading = true
        do {
            try await authService
                .login(email: email, password: password)
        } catch AuthError.invalidCredentials {
            generalError = "Email or Password not found. Please try again."
        } catch let AuthError.validationFailed(fields)  {
            fieldErrors = fields
        } catch AuthError.network {
            generalError = "Couldn't reach the server. Check your connection and try again."
        } catch {
            generalError = "Something went wrong. Please try again."
        }
        isLoading = false
    }
}
