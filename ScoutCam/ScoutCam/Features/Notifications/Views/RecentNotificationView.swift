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
                    NotificationRow(notification: notification) {
                        viewModel.dismiss(id: notification.publicNotificationId)
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

// MARK: - Row

private struct NotificationRow: View {
    let notification: NotificationResponse
    let onDismiss: () -> Void

    @State private var offset: CGFloat = 0

    private static let dismissThreshold: CGFloat = -120
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
        ZStack(alignment: .trailing) {
            RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                .fill(.red)
                .overlay(alignment: .trailing) {
                    Image(systemName: "trash")
                        .foregroundStyle(.white)
                        .font(.title3)
                        .padding(.trailing, 20)
                }
                .opacity(offset < 0 ? 1 : 0)

            HStack(spacing: 14) {
                leadingIcon
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

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
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let translation = value.translation.width
                        if translation < 0 {
                            offset = translation
                        }
                    }
                    .onEnded { value in
                        if offset < Self.dismissThreshold {
                            withAnimation(.easeOut(duration: 0.25)) {
                                offset = -500
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                onDismiss()
                            }
                        } else {
                            withAnimation(.spring()) {
                                offset = 0
                            }
                        }
                    }
            )
        }
        .clipped()
    }

    @ViewBuilder
    private var leadingIcon: some View {
        if let urlString = notification.detectionPreviewUrl, let url = URL(
            string: urlString
        ) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    bellIcon
                }
            }
        } else {
            bellIcon
        }
    }

    private var bellIcon: some View {
        Image(systemName: "bell.fill")
            .font(.title2)
            .foregroundStyle(.blue)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
