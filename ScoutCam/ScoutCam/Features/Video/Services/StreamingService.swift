//
//  StreamingService.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/30/26.
//

import Foundation
import os

extension Logger {
    nonisolated static let streaming = Logger(
        subsystem: "scout.scoutcam",
        category: "streaming"
    )
}

actor StreamingService {
    private let apiClient: ApiClient

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    func start(cameraId: String) async throws {
        do {
            try await apiClient.request(StreamingEndpoint.start(cameraId: cameraId))
            Logger.streaming.info("Streaming start requested successfully for camera \(cameraId).")
        } catch {
            Logger.streaming.error("Failed to start streaming for camera \(cameraId): \(error.localizedDescription)")
            throw error
        }
    }
}
