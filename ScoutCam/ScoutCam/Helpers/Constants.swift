//
//  Constants.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/24/26.
//

import CoreFoundation

enum Constants {
    enum Rules {
        static let prefix = "Tell me when you see"
        static let maxNicknameLength = 50
        static let maxRuleLength = 240
        static var maxRuleSuffixLength: Int { maxRuleLength - prefix.count - 1 }
    }

    enum UI {
        static let cardCornerRadius: CGFloat = 12
        static let navTitleFontSize: CGFloat = 25
        static let cardShadowRadius: CGFloat = 4
        static let cardShadowY: CGFloat = 2
        static let cardShadowOpacity: Double = 0.08
    }
}
