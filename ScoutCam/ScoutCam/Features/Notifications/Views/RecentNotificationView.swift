//
//  RecentNotificationView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/27/26.
//

import SwiftUI

struct RecentNotificationView: View {
    let viewModel: RecentNotificationsViewModel
    var onNotificationTapped: ((NotificationResponse) -> Void)? = nil

    var body: some View {
        VStack(spacing: 10) {
            if viewModel.notifications.isEmpty && !viewModel.isLoading {
                emptyState
            } else {
                ForEach(viewModel.notifications, id: \.publicNotificationId) { notification in
                    NotificationRowView(notification: notification) {
                        onNotificationTapped?(notification)
                    }
                    .onAppear {
                        Task { await viewModel.loadNextPageIfNeeded(currentId: notification.publicNotificationId) }
                    }
                }
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
        .padding(.horizontal)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "bell.slash")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No recent notifications")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .glassEffect(in: .rect(cornerRadius: Constants.UI.cardCornerRadius))
    }
}
