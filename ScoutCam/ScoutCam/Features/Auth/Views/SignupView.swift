//
//  SignUpPage.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/12/26.
//
//  Copyright © 2026 Alexander Taffe. All rights reserved.
import SwiftUI

struct SignupView: View {
    @State var viewModel: SignUpViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack {
                    Text("Create an Account")
                        .font(.title2)
                        .padding()
                    textFieldAndLabel(
                        with_name: "First Name",
                        bind_to: $viewModel.firstName,
                        error: viewModel.fieldErrors["firstName"]
                    )
                    textFieldAndLabel(
                        with_name: "Last Name",
                        bind_to: $viewModel.lastName,
                        error: viewModel.fieldErrors["lastName"]
                    )
                    textFieldAndLabel(
                        with_name: "Email",
                        bind_to: $viewModel.email,
                        error: viewModel.fieldErrors["email"])
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                    textFieldAndLabel(
                        with_name: "Passsword",
                        bind_to: $viewModel.password,
                        error: viewModel.fieldErrors["password"],
                        secure: true)
                    textFieldAndLabel(
                        with_name: " Confirm Passsword",
                        bind_to: $viewModel.confirmPassword,
                        secure: true)
                    Button {
                        Task { await viewModel.signUp() }
                    } label: {
                        Text("Create an Account")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: 8))
                    .padding()
                    .disabled(!viewModel.isFormValid)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    func textFieldAndLabel(
        with_name field_name: String,
        bind_to binding_var: Binding<String>,
        error: String? = nil,
        secure is_secure: Bool = false) -> some View {
            VStack(alignment: .leading, spacing: 4) {
            Text(field_name)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            Group {
                if is_secure {
                    SecureField(field_name, text: binding_var)
                } else {
                    TextField(field_name, text: binding_var)
                }
            }
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(error == nil ? Color.clear : Color.red, lineWidth: 1)
                    .padding(.horizontal)
            )
                
                if let error {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.leading)
                        .transition(.opacity)
                }
        }
            .padding(.bottom, 4)
    }
}

#Preview {
    SignupView(viewModel: SignUpViewModel(authService: AppDependencies().authService))
}
