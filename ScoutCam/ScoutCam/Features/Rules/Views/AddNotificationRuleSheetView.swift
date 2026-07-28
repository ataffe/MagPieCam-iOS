//
//  AddRuleSheetView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/24/26.
//

import SwiftUI

struct AddNotificationRuleSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    let rulesViewModel: RulesViewModel
    @State private var nickname = ""
    @State private var ruleSuffix = ""
    private var fullRule: String { "\(Constants.Rules.prefix) \(ruleSuffix)" }
    @State private var isSaving = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Add a Rule")
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 32)

            Text("Want your camera to keep an eye on something? Add an alert rule and get notified when it happens.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading, spacing: 6) {
                Text("Nickname")
                    .font(.headline)
                TextField("e.g. Cat in the kitchen", text: $nickname)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: nickname) {
                        if nickname.count > Constants.Rules.maxNicknameLength {
                            nickname = String(nickname.prefix(Constants.Rules.maxNicknameLength))
                        }
                    }
                Text("\(nickname.count)/\(Constants.Rules.maxNicknameLength)")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Rule")
                    .font(.headline)
                HStack(alignment: .top, spacing: 4) {
                    Text(Constants.Rules.prefix)
                        .foregroundStyle(Color.secondary)
                    TextField("a cat enter the kitchen...", text: $ruleSuffix, axis: .vertical)
                        .textInputAutocapitalization(.never)
                        .lineLimit(2...4)
                        .onChange(of: ruleSuffix) {
                            if ruleSuffix.count > Constants.Rules.maxRuleSuffixLength {
                                ruleSuffix = String(ruleSuffix.prefix(Constants.Rules.maxRuleSuffixLength))
                            }
                        }
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(UIColor.systemGray4))
                )
                Text("\(fullRule.count)/\(Constants.Rules.maxRuleLength)")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            Spacer()

            Button {
                isSaving = true
                Task {
                    do {
                        try await rulesViewModel.addRule(nickname: nickname, rule: fullRule)
                        dismiss()
                    } catch {
                        // TODO: show error
                    }
                    isSaving = false
                }
            } label: {
                Group {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save Rule")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius))
            }
            .disabled(nickname.isEmpty || ruleSuffix.isEmpty || isSaving)
            .padding(.bottom, 32)
        }
        .padding(.horizontal)
        .background(Constants.UI.backgroundGradient(for: colorScheme).ignoresSafeArea())
    }
}

#Preview {
    let deps = AppDependencies()
    let camera = Camera(id: "123", location: "Kitchen", cameraPreviewUrl: nil)
    AddNotificationRuleSheetView(
        rulesViewModel: RulesViewModel(
            camera: camera,
            rulesService: deps.rulesService
        )
    )
}
