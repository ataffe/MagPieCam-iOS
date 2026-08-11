//
//  RulesViewModel.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/24/26.
//

import Foundation

@Observable
@MainActor
final class RulesViewModel {
    let camera: Camera
    let rulesService: RulesService
    var rules: [Rule] = []
    var isLoading = false
    private var toggleTasks: [String: Task<Void, Never>] = [:]
    
    init(
        camera: Camera,
        rulesService: RulesService,
        rules: [Rule] = []
    ) {
        self.camera = camera
        self.rulesService = rulesService
        self.rules = rules
    }
    
    
    func getCameraRules() async  {
        isLoading = true
        defer { isLoading = false }
        do {
            rules = try await rulesService
                .fetchRules(for: camera.id)
                .map { ruleResponse in
                Rule(from: ruleResponse)
            }
        } catch {
            // TODO: Display error
        }
    }
    
    func addRule(nickname: String, rule: String) async throws {
        isLoading = true
        defer { isLoading = false }
        let response = try await rulesService.addRule(
            nickname: nickname,
            rule: "\(Constants.Rules.prefix) \(rule)",
            for: camera.id
        )
        rules.append(Rule(from: response))
    }

    func toggleRule(id: String) {
        guard let index = rules.firstIndex(where: { $0.id == id }) else { return }
        rules[index].isEnabled.toggle()
        let updated = rules[index]

        // Cancel any pending API call for this rule and restart the debounce timer
        toggleTasks[id]?.cancel()
        toggleTasks[id] = Task {
            do {
                try await Task.sleep(for: .milliseconds(500))
                try await rulesService.updateRule(updated, for: camera.id)
            } catch is CancellationError {
                // Another toggle arrived before the timer fired — no action needed
            } catch {
                // Real API failure: roll back the optimistic update
                if let idx = rules.firstIndex(where: { $0.id == id }) {
                    rules[idx].isEnabled = !updated.isEnabled
                }
                // TODO: surface error to user
            }
        }
    }

    func deleteRule(id: String) async {
        guard let index = rules.firstIndex(where: { $0.id == id }) else { return }
        let removed = rules[index]
        rules.remove(at: index)
        do {
            try await rulesService.deleteRule(ruleId: id, for: camera.id)
        } catch {
            rules.insert(removed, at: index)
            // TODO: surface error to user
        }
    }
}
