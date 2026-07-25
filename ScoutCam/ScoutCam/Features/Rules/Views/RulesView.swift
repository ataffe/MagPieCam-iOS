//
//  RulesView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/24/26.
//

import SwiftUI

struct RulesView: View {
    let rulesViewModel: RulesViewModel
    @State private var isShowingAddRule = false

    init(rulesViewModel: RulesViewModel) {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(ofSize: Constants.UI.navTitleFontSize, weight: .semibold),
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.systemBlue
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        self.rulesViewModel = rulesViewModel
    }

    var body: some View {
        NavigationStack {
            VStack {
                Divider()
                List {
                    ForEach(rulesViewModel.rules) { rule in
                        RuleCardView(rule: rule) {
                                rulesViewModel.toggleRule(id: rule.id)
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    Task { await rulesViewModel.deleteRule(id: rule.id) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    AddRuleCard()
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .onTapGesture { isShowingAddRule = true }
                }
                .listStyle(.plain)
            }
            .task { await rulesViewModel.getCameraRules() }
            .navigationTitle("\(rulesViewModel.camera.location) Camera Rules")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowingAddRule) {
                AddRuleSheetView(rulesViewModel: rulesViewModel)
                    .presentationDetents([.large])
            }
        }
    }

    struct AddRuleCard: View {
        var body: some View {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundStyle(Color.blue)
                    .padding(.trailing, 8)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add a Rule")
                        .font(.title2)
                        .bold()
                    Text("Want your camera to keep an eye on something?")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                    .opacity(0.80)
                    .shadow(color: .black.opacity(0.50), radius: 4, y: 2)
            )
            .padding()
        }
    }
}

#Preview {
    let camera = Camera(id: "123", location: "Kitchen")
    let rulesViewModel = RulesViewModel(
        camera: camera,
        rulesService: AppDependencies().rulesService,
        rules: [
            Rule(
                id: "1",
                rule: "Tell me when a cat gets in the litter box.",
                ruleNickname: "Cat in litterbox",
                isEnabled: true
            ),
            Rule(
                id: "2",
                rule: "Tell me when you see a person",
                ruleNickname: "Person at the door",
                isEnabled: false
            ),
        ]
    )
    RulesView(
        rulesViewModel: rulesViewModel
    )
}
