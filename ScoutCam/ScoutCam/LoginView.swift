//
//  LoginView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/11/26.
//
import SwiftUI

struct LoginPage: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack {
            Text("ScoutCam") // TODO: Replace with logo
                .font(.title)
                .foregroundStyle(.blue)
                .padding(.bottom, 100)
            Text("Login or create and account")
                .padding()
            TextField("Username", text: $username)
                .padding()
            SecureField("Password", text: $password)
                .padding(.leading)
                .padding(.bottom)
            Button("Forgot Password") {
                print("Triggering forgot password flow.")
            }
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading)
            Button(action: login) {
                Text("Sign in")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 20))
            .padding(.top, 100)
            Button(action: createAccount) {
                Text("Sign up")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 20))
            .padding(.top)
            .tint(.secondary)
        }
        .padding()
    }
}

func login() {
    print("Logging in")
}

func createAccount() {
    print("Creating account...")
}

#Preview {
    LoginPage()
}
