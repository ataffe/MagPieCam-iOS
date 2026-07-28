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
    @Environment(\.colorScheme) private var colorScheme


    var body: some View {
        VStack(spacing: 0) {
            Text("ScoutCam") // TODO: Replace with logo
                .font(.largeTitle)
                .bold()
                .foregroundStyle(Color.blue)
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
                        .onChange(of: $viewModel.email.wrappedValue){
                            viewModel.fieldErrors["email"] = nil
                        }
                    SecureField("Password", text: $viewModel.password)
                        .padding(.bottom)
                        .padding(.leading)
                        .padding(.trailing)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: $viewModel.password.wrappedValue) {
                            viewModel.fieldErrors["password"] = nil
                        }
                    Button("Forgot Password") {
                        print("Triggering forgot password flow.")
                    }
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                    if !viewModel.generalError.isEmpty {
                        Text(viewModel.generalError.capitalized)
                            .font(.callout)
                            .foregroundStyle(.red)
                            .padding(.top)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    Button {
                        Task { await viewModel.login() }
                    } label: {
                        Group {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Sign in")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: 8))
                    .padding(.top, 30)
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                    NavigationLink("Don't have an account? Sign up!") {
                        SignupView(
                            signupViewModel: SignUpViewModel(
                                authService: dependencies.authService)
                        )
                    }
                    .foregroundStyle(.blue)
                    .padding(.top)
                }
                .animation(.easeInOut(duration: 0.25), value: viewModel.generalError)
            }
        }
        .padding()
        .background(Constants.UI.backgroundGradient(for: colorScheme).ignoresSafeArea())
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
