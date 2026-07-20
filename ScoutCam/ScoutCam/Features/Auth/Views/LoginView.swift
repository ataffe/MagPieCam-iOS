//
//  LoginView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/11/26.
//
//  Copyright © 2026 Alexander Taffe. All rights reserved.
import SwiftUI

struct LoginView: View {
    @Environment(AppDependencies.self) private var dependencies
    
    var body: some View {
        NavigationStack {
            ManagedView { deps in
                LoginViewModel(authService: deps.authService)
            } content: { loginViewModel in
                LoginFormView(
                    viewModel: loginViewModel,
                    dependencies: dependencies
                )
            }
        }
    }
}


struct LoginFormView: View {
    @Bindable var viewModel: LoginViewModel
    let dependencies: AppDependencies
    
    var body: some View {
        VStack(spacing: 0) {
            Text("ScoutCam") // TODO: Replace with logo
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.blue)
                .padding(.bottom, Spacing.logoPaddingTop)
                .padding(.top, Spacing.logoPaddingBottom)
            ScrollView {
                VStack {
                    Text("Login or Create an Account")
                    TextField("Email", text: $viewModel.email)
                        .padding()
                        .textFieldStyle(.roundedBorder)
                        .controlSize(.large)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                    if let error = viewModel.fieldErrors["email"] {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.leading)
                            .transition(.opacity)
                    }
                    SecureField("Password", text: $viewModel.password)
                        .padding(.bottom)
                        .padding(.leading)
                        .padding(.trailing)
                        .textFieldStyle(.roundedBorder)
                    if let error = viewModel.fieldErrors["password"] {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.leading)
                            .transition(.opacity)
                    }
                    Button("Forgot Password") {
                        print("Triggering forgot password flow.")
                    }
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                    Button {
                        Task { await viewModel.login()}
                    } label: {
                        Text("Sign in")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: 8))
                    .padding(.top, 50)
                    NavigationLink("Don't have an account? Sign up!") {
                        SignupView(
                            viewModel: SignUpViewModel(
                                authService: dependencies.authService)
                        )
                    }
                    .foregroundStyle(.blue)
                    .padding(.top)
                }
            }
        }
        .padding()
    }
}

fileprivate struct Spacing {
    static let logoPaddingTop: CGFloat = 10
    static let logoPaddingBottom: CGFloat = 30
}

#Preview {
    LoginView()
        .environment(AppDependencies())
}
