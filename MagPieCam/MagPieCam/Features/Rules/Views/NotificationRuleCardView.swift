//
//  RuleCardView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/24/26.
//

import SwiftUI

struct NotificationRuleCardView: View {
    let rule: Rule
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 8) {
                Text(rule.ruleNickname)
                    .foregroundStyle(rule.isEnabled ? Color.primary : Color.secondary)
                    .font(.title2)
                    .bold()
                Text("\(Constants.Rules.prefix) \(rule.rule)")
                    .foregroundStyle(rule.isEnabled ? Color.primary : Color.secondary)
                    .font(.subheadline)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { rule.isEnabled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
            .toggleStyle(.switch)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                .fill(.clear)
                .opacity(0.80)
                .shadow(color: .black.opacity(0.50), radius: 4, y: 2)
        )
        .glassEffect(in: .rect(cornerRadius: Constants.UI.cardCornerRadius))
        .padding()
    }
}

#Preview {
    NotificationRuleCardView(
        rule: Rule(id: "123", rule: "a cat use the litterbox.", ruleNickname: "Cat Uses Litterbox", isEnabled: true),
        onToggle: {}
    )
}
