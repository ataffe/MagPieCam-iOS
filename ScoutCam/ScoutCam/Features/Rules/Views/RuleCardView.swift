//
//  RuleCardView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/24/26.
//

import SwiftUI

struct RuleCardView: View {
    let rule: Rule
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 8) {
                Text(rule.ruleNickname)
                    .foregroundStyle(rule.isEnabled ? Color.primary : Color.secondary)
                    .font(.title2)
                    .bold()
                Text(rule.rule)
                    .foregroundStyle(rule.isEnabled ? Color.primary : Color.secondary)
                    .font(.subheadline)
            }
            Spacer()
            Button {
                onToggle()
            } label: {
                Image(systemName: rule.isEnabled ? "eye.fill" : "eye.slash")
                    .font(.title2)
                    .foregroundStyle(rule.isEnabled ? Color.blue : Color.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                .fill(Color(.secondarySystemBackground))
                .opacity(0.80)
                .shadow(color: .black.opacity(0.50), radius: 4, y: 2)
        )
        .padding()
    }
}

#Preview {
    RuleCardView(
        rule: Rule(id: "123", rule: "Tell me when you see a cat use the litterbox.", ruleNickname: "Cat Uses Litterbox", isEnabled: true),
        onToggle: {}
    )
}
