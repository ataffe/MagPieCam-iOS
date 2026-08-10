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
    let cameraService: CameraService
    let rulesService: RulesService
    let streamingService: StreamingService
    let notificationService: NotificationService
    let authState: AuthState
    let cameraStore: CameraStore

    init() {
        let apiClient = ApiClient(baseUrl: AppConfig.apiBaseUrl)
        let authState = AuthState()
        let cameraStore = CameraStore()
        let authService = AuthService(apiClient: apiClient, authState: authState)
        self.apiClient = apiClient
        self.authState = authState
        self.authService = authService
        self.cameraStore = cameraStore
        self.cameraService = CameraService(apiClient: apiClient, cameraStore: cameraStore)
        self.rulesService = RulesService(apiClient: apiClient)
        self.streamingService = StreamingService(apiClient: apiClient)
        self.notificationService = NotificationService(apiClient: apiClient)

        // Wire the token provider after both objects exist.
        // ApiClient will call this before every authenticated request,
        // transparently refreshing the access token when it has expired.
        Task {
            await apiClient.setTokenProvider {
                try await authService.validAccessToken()
            }
        }
    }
}
