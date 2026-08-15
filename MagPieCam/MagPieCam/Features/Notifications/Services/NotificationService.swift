//
//  NotificationService.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 8/8/26.
//

import Foundation
import os

extension Logger {
    nonisolated static let notifications = Logger(
        subsystem: "scout.scoutcam",
        category: "notifications"
    )
}

actor NotificationService {
    private let apiClient: ApiClient

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    func getNotifications(cameraId: String, cursor: String? = nil) async throws -> GetNotificationsResponse {
        try await apiClient.request(
            NotificationsEndpoint.getNotifications(cameraId: cameraId, cursor: cursor)
        )
    }

    func clearNotifications(cameraId: String, ids: [String]) async throws {
        let body = ClearNotificationsRequest(publicNotificationIds: ids)
        try await apiClient.request(
            endpoint: NotificationsEndpoint.clearNotifications(cameraId: cameraId),
            body: body
        )
    }
}
