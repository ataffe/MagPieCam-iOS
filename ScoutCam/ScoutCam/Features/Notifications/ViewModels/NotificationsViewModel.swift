//
//  NotificationsViewModel.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 8/11/26.
//

import Foundation
import os

@Observable
@MainActor
final class NotificationsViewModel {
    private(set) var notifications: [NotificationResponse] = []
    private(set) var isLoading = false

    private let cameraId: String
    private let notificationService: NotificationService
    private var pollingTask: Task<Void, Never>?

    private static let pollingInterval: Duration = .seconds(15)

    init(cameraId: String, notificationService: NotificationService) {
        self.cameraId = cameraId
        self.notificationService = notificationService
    }

    @MainActor
    static func preview(notifications: [NotificationResponse] = [], isLoading: Bool = false) -> NotificationsViewModel {
        let vm = NotificationsViewModel(
            cameraId: "preview-cam",
            notificationService: NotificationService(apiClient: ApiClient(baseUrl: URL(string: "https://example.com")!))
        )
        vm.notifications = notifications
        vm.isLoading = isLoading
        return vm
    }

    func dismiss(id: String) {
        notifications.removeAll { $0.publicNotificationId == id }
        Task {
            try? await notificationService.clearNotifications(cameraId: cameraId, ids: [id])
        }
    }

    func loadNotifications() async {
        guard !isLoading else { return }
        isLoading = true
        do {
            let response = try await notificationService.getNotifications(cameraId: cameraId)
            notifications = Array(response.results.prefix(10))
        } catch {
            Logger.notifications.error("Failed to load notifications: \(error)")
        }
        isLoading = false
    }

    func startPolling() {
        pollingTask?.cancel()
        pollingTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: Self.pollingInterval)
                guard !Task.isCancelled else { return }
                await refresh()
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    private func refresh() async {
        do {
            let response = try await notificationService.getNotifications(cameraId: cameraId)
            let fresh = Array(response.results.prefix(10))
            let existingIds = Set(notifications.map(\.publicNotificationId))

            // Update video clip URLs on existing notifications that have since become available
            notifications = notifications.map { existing in
                fresh.first { $0.publicNotificationId == existing.publicNotificationId } ?? existing
            }

            // Prepend any brand-new notifications
            let newOnes = fresh.filter { !existingIds.contains($0.publicNotificationId) }
            if !newOnes.isEmpty {
                notifications.insert(contentsOf: newOnes, at: 0)
                notifications = Array(notifications.prefix(10))
            }
        } catch {
            Logger.notifications.error("Failed to refresh notifications: \(error)")
        }
    }
}
