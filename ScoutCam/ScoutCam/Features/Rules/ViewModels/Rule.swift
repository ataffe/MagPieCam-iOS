//
//  RuleModel.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/24/26.
//

import Foundation

struct Rule: Identifiable {
    let id: String
    let rule: String
    let ruleNickname: String
    var isEnabled: Bool
}

extension Rule {
    init(from response: RuleResponse) {
        self.id = response.publicRuleId
        self.rule = response.rule
        self.ruleNickname = response.ruleNickname.capitalized
        self.isEnabled = response.isEnabled
    }
}
