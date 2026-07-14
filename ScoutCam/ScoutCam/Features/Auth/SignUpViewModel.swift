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
    var first_name: String = ""
    var last_name: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    
    var isFormValid: Bool {
        !first_name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !last_name.trimmingCharacters(in: .whitespaces).isEmpty &&
        isEmailValid &&
        !password.trimmingCharacters(in: .whitespaces).isEmpty &&
        !confirmPassword.trimmingCharacters(in: .whitespaces).isEmpty &&
        password == confirmPassword
    }
    
    var isEmailValid: Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
    
    func signUp() {
        print("Placeholder: Signing up!")
    }
}
