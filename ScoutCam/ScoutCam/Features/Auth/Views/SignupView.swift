//
//  SignUpPage.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/12/26.
//
//  Copyright © 2026 Alexander Taffe. All rights reserved.
import SwiftUI

struct SignupView: View {
    @State var signupViewModel: SignUpViewModel
    
    init(signupViewModel: SignUpViewModel) {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(ofSize: 25, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.systemBlue]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        self.signupViewModel = signupViewModel
    }

    
    var body: some View {
        NavigationStack {
            Divider()
            ScrollView {
                VStack {
                    textFieldAndLabel(
                        with_name: "First Name",
                        bind_to: $signupViewModel.firstName,
                        error: signupViewModel.fieldErrors["firstName"]
                    )
                    textFieldAndLabel(
                        with_name: "Last Name",
                        bind_to: $signupViewModel.lastName,
                        error: signupViewModel.fieldErrors["lastName"]
                    )
                    textFieldAndLabel(
                        with_name: "Email",
                        bind_to: $signupViewModel.email,
                        error: signupViewModel.fieldErrors["email"])
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .animation(
                            .easeInOut(duration: 0.25),
                            value: signupViewModel.email
                        )
                    textFieldAndLabel(
                        with_name: "Passsword",
                        bind_to: $signupViewModel.password,
                        error: signupViewModel.fieldErrors["password"],
                        secure: true)
                    .animation(
                        .easeInOut(duration: 0.25),
                        value: signupViewModel.password
                    )
                    textFieldAndLabel(
                        with_name: " Confirm Passsword",
                        bind_to: $signupViewModel.confirmPassword,
                        secure: true)
                    Button {
                        Task { await signupViewModel.signUp() }
                    } label: {
                        Group {
                            if signupViewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Create an Account")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: 8))
                    .padding()
                    .disabled(!signupViewModel.isFormValid)
                }
            }
            .padding(.top)
            .navigationTitle("Create an Account")
            .navigationBarTitleDisplayMode(.inline)
        
        }
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
                    Text(error.capitalized)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .padding(.leading)
                        .transition(.opacity)
                }
        }
        .padding(.bottom, 4)
    }
}

#Preview {
    SignupView(signupViewModel: SignUpViewModel(authService: AppDependencies().authService))
}
