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
        print("Base Url: \(urlString)")
        return url
    }
    
    static var whepBaseUrl: URL {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "WHEP_URL") as? String,
              let url = URL(string: urlString) else {
            fatalError("WHEP_URL missing or invalid in Info.plist")
        }
        return url
    }

    static func whepUrl(for cameraId: String) -> URL {
        whepBaseUrl
            .appendingPathComponent(cameraId)
            .appendingPathComponent("whep")
    }
}

@main
struct ScoutCamApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var dependencies = AppDependencies()

    init() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .font: UIFont
                .systemFont(
                    ofSize: Constants.UI.navTitleFontSize,
                    weight: .regular
                )
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(dependencies)
        }
    }
}
