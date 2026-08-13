//
//  RecentNotificationsViewModel.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 8/9/26.
//

import Foundation
import os

@Observable
@MainActor
final class RecentNotificationsViewModel {
    private(set) var notifications: [NotificationResponse] = []
    private(set) var isLoading = false
    private(set) var hasMore = true

    private let cameraId: String
    private let notificationService: NotificationService
    private var nextCursor: String? = nil

    init(cameraId: String, notificationService: NotificationService) {
        self.cameraId = cameraId
        self.notificationService = notificationService
    }

    func loadInitial() async {
        guard !isLoading else { return }
        isLoading = true
        nextCursor = nil
        do {
            let response = try await notificationService.getNotifications(cameraId: cameraId)
            self.notifications = response.results
            Logger.notifications
                .info("Retrieved \(self.notifications.count) notifications")
            nextCursor = response.next
            hasMore = nextCursor != nil
        } catch {
            Logger.notifications.error("Failed to load notifications: \(error)")
        }
        isLoading = false
    }

    func dismiss(id: String) {
        notifications.removeAll { $0.publicNotificationId == id }
        Task {
            do {
                try await notificationService.clearNotifications(cameraId: cameraId, ids: [id])
            } catch {
                Logger.notifications.error("Failed to clear notification \(id): \(error)")
            }
        }
    }

    func clearAll() {
        let ids = notifications.map(\.publicNotificationId)
        notifications.removeAll()
        Task {
            do {
                try await notificationService.clearNotifications(cameraId: cameraId, ids: ids)
            } catch {
                Logger.notifications.error("Failed to clear all notifications: \(error)")
            }
        }
    }

    func loadNextPageIfNeeded(currentId: String) async {
        guard currentId == notifications.last?.publicNotificationId,
              hasMore, !isLoading else { return }
        isLoading = true
        do {
            let response = try await notificationService.getNotifications(cameraId: cameraId, cursor: nextCursor)
            notifications.append(contentsOf: response.results)
            nextCursor = response.next
            hasMore = nextCursor != nil
        } catch {
            Logger.notifications.error("Failed to load next page of notifications: \(error)")
        }
        isLoading = false
    }
}
