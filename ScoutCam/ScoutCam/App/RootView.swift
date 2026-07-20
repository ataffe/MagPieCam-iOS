//
//  SwiftUIView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/19/26.
//

import SwiftUI

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
            CamerasHomeView()
        }
    }
}
