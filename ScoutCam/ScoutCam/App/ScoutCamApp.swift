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
    
    static var whepUrl: URL {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "WHEP_URL") as? String
        else {
            fatalError("Unable to get webrtc url.")
        }
                
        guard let url = URL(string: urlString) else {
            fatalError("WEBRTC_URL missing or invalid in Info.plist")
        }
        print("WHEP Url: \(urlString)")
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
