//
//  Constants.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/24/26.
//

import SwiftUI

enum Constants {
    enum Rules {
        static let prefix = "Tell me when you see"
        static let maxNicknameLength = 50
        static let maxRuleLength = 240
        static var maxRuleSuffixLength: Int { maxRuleLength - prefix.count - 1 }
    }

    enum UI {
        static let cardCornerRadius: CGFloat = 15
        static let navTitleFontSize: CGFloat = 25
        static let cardShadowRadius: CGFloat = 4
        static let cardShadowY: CGFloat = 2
        static let cardShadowOpacity: Double = 0.08
        static let cameraPreviewCardHeight: CGFloat = 200
        static let cameraPreviewLocationFont: Font = .title2

        static func backgroundGradient(for colorScheme: ColorScheme) -> LinearGradient {
            colorScheme == .dark
                ? LinearGradient(
                    colors: [Color(.systemBackground), Color.blue.opacity(0.5)],
                    startPoint: .top, endPoint: .bottom
                  )
                : LinearGradient(
                    colors: [.white, Color.blue.opacity(0.25)],
                    startPoint: .top, endPoint: .bottom
                  )
        }
    }
    
    enum Video {
        static let liveStreamUrl = "http://10.0.0.53:8889/cam"
    }
}
