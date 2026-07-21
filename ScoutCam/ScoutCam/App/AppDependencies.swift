//
//  AppDependencies.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/19/26.
//

import Foundation

@Observable
final class AppDependencies {
    let apiClient: ApiClient
    let authService: AuthService
    let authState: AuthState
    
    init() {
        self.apiClient = ApiClient(baseUrl: AppConfig.apiBaseUrl)
        self.authState = AuthState()
        self.authService = AuthService(
            apiClient: apiClient,
            authState: authState
        )
    }
}
