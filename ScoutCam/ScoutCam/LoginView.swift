//
//  LoginView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/11/26.
//
import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("ScoutCam") // TODO: Replace with logo
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.blue)
                    .padding(.bottom, 20)
                    .padding(.top, 20)
                
                ScrollView {
                    VStack {
                        Text("Login or Create an Account")
                            .padding()
                        TextField("Username", text: $username)
                            .padding()
                            .textFieldStyle(.roundedBorder)
                        SecureField("Password", text: $password)
                            .padding(.bottom)
                            .padding(.leading)
                            .padding(.trailing)
                            .textFieldStyle(.roundedBorder)
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
                        .buttonBorderShape(.roundedRectangle(radius: 8))
                        .padding(.top, 50)
                        NavigationLink("Don't have an account? Sign up!") {
                                            SignUpView()
                                        }
                        .foregroundStyle(.blue)
                        .padding(.top)
                    }
                }
                
            }
            .padding()
        }
        
    }
}

func login() {
    print("Logging in")
}

func createAccount() {
    print("Creating account...")
}

#Preview {
    LoginView()
}
