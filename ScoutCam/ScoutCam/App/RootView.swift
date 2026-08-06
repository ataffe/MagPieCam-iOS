//
//  SwiftUIView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/19/26.
//

import SwiftUI
import UserNotifications

struct RootView: View {
    @Environment(AppDependencies.self) private var dependencies

    var body: some View {
        switch dependencies.authState.status {
        case .checking:
            ProgressView().task {
                await dependencies.authService.restoreSession()
            }
        case .signedOut:
            LoginView()
        case .signedIn:
            CamerasHomeView(cameraService: dependencies.cameraService)
                .onAppear {
                    Task {
                        let center = UNUserNotificationCenter.current()
                        guard let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge]),
                              granted else { return }
                        await MainActor.run {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .didReceiveApnsToken)) { notification in
                    guard let token = notification.object as? String else { return }
                    Task { await dependencies.authService.updateApnsToken(token) }
                }
        }
    }
}
