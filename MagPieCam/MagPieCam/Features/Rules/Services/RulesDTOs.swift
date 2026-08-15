//
//  RulesDTOs.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/24/26.
//

import Foundation

nonisolated struct RuleResponse: Decodable {
    let publicRuleId: String
    let rule: String
    let ruleNickname: String
    let isEnabled: Bool
}

nonisolated struct RuleRequest: Encodable {
    let rule: String
    let ruleNickname: String
    let isEnabled: Bool
}
