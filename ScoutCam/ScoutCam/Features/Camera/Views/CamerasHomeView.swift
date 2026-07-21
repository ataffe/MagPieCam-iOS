//
//  cameras.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/19/26.
//

import SwiftUI

struct CamerasHomeView: View {
    @Environment(AppDependencies.self) private var dependencies
    
    var body: some View {
        Button("Sign Out") {
            Task {
                await dependencies.authService.logOut()
            }
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 8))
        .padding(.top, 50)
        Text("Hello, Camera!")
    }
}

#Preview {
    CamerasHomeView()
        .environment(AppDependencies())
}
