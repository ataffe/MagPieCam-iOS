//
//  RecentNotificationView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/27/26.
//

import SwiftUI

struct RecentNotificationView: View {
    let viewModel: RecentNotificationsViewModel

    var body: some View {
        VStack(spacing: 10) {
            if viewModel.notifications.isEmpty && !viewModel.isLoading {
                emptyState
            } else {
                ForEach(viewModel.notifications, id: \.publicNotificationId) { notification in
                    NotificationRow(notification: notification)
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

// MARK: - Row

private struct NotificationRow: View {
    let notification: NotificationResponse

    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private var parsedDate: Date? {
        NotificationRow.isoFormatter.date(from: notification.createdAt)
            ?? ISO8601DateFormatter().date(from: notification.createdAt)
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "bell.fill")
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(notification.ruleNickname)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("Rule triggered")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let date = parsedDate {
                Text(date, format: .relative(presentation: .named))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding()
        .glassEffect(in: .rect(cornerRadius: Constants.UI.cardCornerRadius))
    }
}
