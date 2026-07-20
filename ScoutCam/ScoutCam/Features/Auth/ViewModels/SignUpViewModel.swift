//
//  SignUpModel.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/14/26.
//
//  Copyright © 2026 Alexander Taffe. All rights reserved.
import Foundation

@Observable
@MainActor
final class SignUpViewModel {
    let authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    var firstName: String = ""
    var lastName: String = ""
    var email: String = "" {
        didSet {
            let lowered = email.lowercased()
            if email != lowered {
                email = lowered
            }
        }
    }
    
    var password: String = ""
    var confirmPassword: String = ""
    var isLoading: Bool = false
    var fieldErrors: [String: String] = [:]
    var generalError = ""
    
    var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        isEmailValid &&
        !password.trimmingCharacters(in: .whitespaces).isEmpty &&
        !confirmPassword.trimmingCharacters(in: .whitespaces).isEmpty &&
        password == confirmPassword
    }
    
    var isEmailValid: Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
    
    func signUp() async {
        isLoading = true
        do {
            try await authService
                .signUp(
                    firstName: firstName,
                    lastName: lastName,
                    email: email.lowercased(),
                    password: password
                )
        } catch let AuthError.validationFailed(fields)  {
            fieldErrors = fields
        } catch AuthError.accoutCreatedButSessionNoSaved {
            generalError = "Your account was created, but we couldn't save your session. Please log in."
        } catch AuthError.network {
            generalError = "Couldn't reach the server. Check your connection and try again."
        } catch {
            generalError = "Something went wrong. Please try again."
        }
        isLoading = false
    }
}
