//
//  ScoutCamApp.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/11/26.
//
//  Copyright © 2026 Alexander Taffe. All rights reserved.
import SwiftUI

enum AppConfig {
    static var apiBaseUrl: URL {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
              let url = URL(string: urlString) else {
            fatalError("API_BASE_URL missing or invalid in Info.plist")
        }
        print("Base Url: \(url.absoluteString)")
        return url
    }
}

@main
struct ScoutCamApp: App {
    @State private var dependencies = AppDependencies()
    

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(dependencies)
        }
    }
}
