//
//  NotificationsView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 8/11/26.
//

import SwiftUI

struct NotificationsView: View {
    let cameraId: String
    var scrollToId: String? = nil
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel: NotificationsViewModel?

    init(cameraId: String, scrollToId: String? = nil) {
        self.cameraId = cameraId
        self.scrollToId = scrollToId
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                if let viewModel {
                    if viewModel.isLoading && viewModel.notifications.isEmpty {
                        loadingState
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                    } else if viewModel.notifications.isEmpty {
                        emptyState
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                    } else {
                        ForEach(viewModel.notifications, id: \.publicNotificationId) { notification in
                            NotificationCardView(notification: notification)
                                .id(notification.publicNotificationId)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.dismiss(id: notification.publicNotificationId)
                                    } label: {
                                        Label("Dismiss", systemImage: "trash")
                                    }
                                }
                        }
                        .animation(.spring(duration: 0.4), value: viewModel.notifications)
                    }
                } else {
                    loadingState
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .onChange(of: viewModel?.notifications) { _, notifications in
                guard let id = scrollToId,
                      let notifications,
                      notifications.contains(where: { $0.publicNotificationId == id }) else { return }
                withAnimation {
                    proxy.scrollTo(id, anchor: .top)
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .background(Constants.UI.backgroundGradient(for: colorScheme).ignoresSafeArea())
        .task {
            if viewModel == nil {
                viewModel = NotificationsViewModel(
                    cameraId: cameraId,
                    notificationService: dependencies.notificationService
                )
            }
            await viewModel?.loadNotifications()
            viewModel?.startPolling()
        }
        .onDisappear {
            viewModel?.stopPolling()
        }
    }

    private var loadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading notifications...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "bell.slash")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No notifications yet")
                .font(.headline)
                .foregroundStyle(.primary)
            Text("Notifications will appear here when your rules are triggered.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
}

// MARK: - Preview support

fileprivate extension NotificationsView {
    init(cameraId: String, scrollToId: String? = nil, previewViewModel: NotificationsViewModel) {
        self.cameraId = cameraId
        self.scrollToId = scrollToId
        self._viewModel = State(initialValue: previewViewModel)
    }
}

private let previewNotifications: [NotificationResponse] = [
    NotificationResponse(
        publicNotificationId: "notif-001",
        publicCameraId: "cam-001",
        ruleNicknames: ["Person at front door"],
        detectionPreviewUrl: nil,
        videoClipUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
        createdAt: "2026-08-11T14:32:00.000Z"
    ),
    NotificationResponse(
        publicNotificationId: "notif-002",
        publicCameraId: "cam-001",
        ruleNicknames: ["Motion in backyard", "Person detected"],
        detectionPreviewUrl: "https://picsum.photos/seed/scoutcam/800/450",
        videoClipUrl: nil,
        createdAt: "2026-08-11T13:15:00.000Z"
    ),
    NotificationResponse(
        publicNotificationId: "notif-003",
        publicCameraId: "cam-001",
        ruleNicknames: ["Package delivered"],
        detectionPreviewUrl: nil,
        videoClipUrl: nil,
        createdAt: "2026-08-11T09:00:00.000Z"
    ),
]

#Preview("With Notifications") {
    NavigationStack {
        NotificationsView(
            cameraId: "preview",
            previewViewModel: .preview(notifications: previewNotifications)
        )
    }
    .environment(AppDependencies())
}

#Preview("Loading") {
    NavigationStack {
        NotificationsView(
            cameraId: "preview",
            previewViewModel: .preview(isLoading: true)
        )
    }
    .environment(AppDependencies())
}

#Preview("Empty") {
    NavigationStack {
        NotificationsView(
            cameraId: "preview",
            previewViewModel: .preview()
        )
    }
    .environment(AppDependencies())
}
