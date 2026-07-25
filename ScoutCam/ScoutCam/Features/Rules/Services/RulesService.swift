//
//  RulesService.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/24/26.
//

import Foundation
import os

extension Logger {
    nonisolated static let rules = Logger(
        subsystem: "scout.scoutcam",
        category: "rules"
    )
}

enum RuleError: Error {
    case encodeDecodeFailure
    case unexpected
    case validationFailed([String: String])
}

actor RulesService {
    private let apiClient: ApiClient
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    func fetchRules(for id: String) async throws -> [RuleResponse] {
        do {
            return try await callApi(RuleEndpoint.getRules(cameraId: id))
        } catch {
            Logger.camera.error("An error occurred while retrieving rules for camera: \(id)")
            throw error
        }
    }
    
    func addRule(nickname: String, rule: String, for cameraId: String) async throws -> RuleResponse {
        do {
            let body = RuleRequest(rule: rule, ruleNickname: nickname, isEnabled: true)
            return try await callApi(
                RuleEndpoint.addRule(cameraId: cameraId),
                body: body
            )
        } catch {
            Logger.camera.error("An error occurred while creating rule for camera: \(cameraId)")
            throw error
        }
    }
    
    func updateRule(_ rule: Rule, for cameraId: String) async throws {
        do {
            let body = RuleRequest(rule: rule.rule, ruleNickname: rule.ruleNickname, isEnabled: rule.isEnabled)
            let _: RuleResponse = try await callApi(
                RuleEndpoint.updateRule(cameraId: cameraId, ruleId: rule.id),
                body: body
            )
        } catch {
            Logger.rules.error("An error occurred while updating rule \(rule.id) for camera: \(cameraId)")
            throw error
        }
    }

    func deleteRule(ruleId: String, for cameraId: String) async throws {
        do {
            try await callApi(RuleEndpoint.deleteRule(cameraId: cameraId, ruleId: ruleId))
        } catch {
            Logger.rules.error("An error occurred while deleting rule for camera: \(cameraId)")
            throw error
        }
    }
    
    func callApi(_ endpoint: RuleEndpoint) async throws {
        try await mapRulesErrors { try await self.apiClient.request(endpoint) }
    }

    func callApi<Request: Encodable, Response: Decodable>(_ endpoint: RuleEndpoint, body: Request) async throws -> Response {
        try await mapRulesErrors {
            try await self.apiClient.request(endpoint: endpoint, body: body)
        }
    }

    func callApi<Response: Decodable>(_ endpoint: RuleEndpoint) async throws -> Response {
        try await mapRulesErrors {
            try await self.apiClient.request(endpoint)
        }
    }
    
    
    private func mapRulesErrors<T>(_ call: () async throws -> T) async throws -> T {
        do {
            return try await call()
        } catch let APIError.encodingError(error) {
            Logger.camera.error("Unable to encode rules service request to json: \(error).")
            throw RuleError.encodeDecodeFailure
        } catch let APIError.decodingError(error) {
            Logger.camera.error("Unable to decode rules serivce response from json: \(error)")
            throw RuleError.encodeDecodeFailure
        } catch APIError.unauthorized {
            Logger.camera.error("Invalid credentials")
            throw AuthError.invalidCredentials
        } catch let APIError.validationErrors(fields) {
            Logger.camera.error("Validation failed: \(fields)")
            throw RuleError.validationFailed(fields.compactMapValues({ $0.first }))
        } catch {
            Logger.camera.error("Unexpected error: \(error).")
            throw RuleError.unexpected
        }
    }
    
}
