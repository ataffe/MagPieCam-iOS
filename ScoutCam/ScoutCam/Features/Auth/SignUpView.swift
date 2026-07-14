//
//  SignUpPage.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/12/26.
//
//  Copyright © 2026 Alexander Taffe. All rights reserved.
import SwiftUI

struct SignUpView: View {
    @State private var viewModel = SignUpViewModel()
    
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
                    textFieldAndLabel(with_name: "First Name", bind_to: $viewModel.first_name)
                    textFieldAndLabel(with_name: "Last Name", bind_to: $viewModel.last_name)
                    textFieldAndLabel(with_name: "Email", bind_to: $viewModel.email)
                    textFieldAndLabel(
                        with_name: "Passsword",
                        bind_to: $viewModel.password,
                        secure: true)
                    textFieldAndLabel(
                        with_name: " Confirm Passsword",
                        bind_to: $viewModel.confirmPassword,
                        secure: true)
                    Button(action: viewModel.signUp) {
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
