//
//  SignUpPage.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/12/26.
//

import SwiftUI

struct SignUpView: View {
    @State private var first_name: String = ""
    @State private var last_name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    private var isFormValid: Bool {
        !first_name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !last_name.trimmingCharacters(in: .whitespaces).isEmpty &&
        isEmailValid &&
        !password.trimmingCharacters(in: .whitespaces).isEmpty &&
        !confirmPassword.trimmingCharacters(in: .whitespaces).isEmpty &&
        password == confirmPassword
    }
    
    private var isEmailValid: Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("ScoutCam") // TODO: Replace with logo
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.blue)
                .padding(.bottom, 20)
            
            ScrollView {
                VStack {
                    Text("Create an Account")
                        .font(.title2)
                        .padding()
                    textFieldAndLabel(with_name: "First Name", bind_to: $first_name)
                    textFieldAndLabel(with_name: "Last Name", bind_to: $last_name)
                    textFieldAndLabel(with_name: "Email", bind_to: $email)
                    textFieldAndLabel(
                        with_name: "Passsword",
                        bind_to: $password,
                        secure: true)
                    textFieldAndLabel(
                        with_name: " Confirm Passsword",
                        bind_to: $confirmPassword,
                        secure: true)
                    Button(action: login) {
                        Text("Create an Account")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: 8))
                    .padding()
                    .disabled(!isFormValid)
                }
            }
        }
        
    }
    
    func signUp() {
        print("Signing up...")
    }
    
    func textFieldAndLabel(
        with_name field_name: String,
        bind_to binding_var: Binding<String>,
        secure is_secure: Bool = false) -> some View {
        VStack {
            Text(field_name)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            if is_secure {
                SecureField(field_name, text: binding_var)
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.bottom)
                    .textFieldStyle(.roundedBorder)
            } else {
                TextField(field_name, text: binding_var)
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.bottom)
                    .textFieldStyle(.roundedBorder)
            }
            
        }
    }
}

#Preview {
    SignUpView()
}
