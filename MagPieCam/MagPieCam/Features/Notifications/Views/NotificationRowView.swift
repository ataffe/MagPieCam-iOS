//
//  NotificationRow.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 8/12/26.
//
import SwiftUI

struct NotificationRowView: View {
    let notification: NotificationResponse
    var onTap: (() -> Void)? = nil

    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private var parsedDate: Date? {
        NotificationRowView.isoFormatter.date(from: notification.createdAt)
            ?? ISO8601DateFormatter().date(from: notification.createdAt)
    }

    var body: some View {
        HStack(spacing: 14) {
            leadingIcon
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(notification.ruleNicknames.joined(separator: " · "))
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Text(notification.ruleNicknames.count == 1 ? "Rule triggered" : "Rules triggered")
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
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
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

#Preview("Single Rule") {
    NotificationRowView(
        notification: NotificationResponse(
            publicNotificationId: "notif-001",
            publicCameraId: "cam-001",
            ruleNicknames: ["Person at front door"],
            detectionPreviewUrl: "https://picsum.photos/seed/scoutcam/200/200",
            videoClipUrl: nil,
            createdAt: "2026-08-12T10:30:00.000Z"
        )
    ) {
        print("Tapped")
    }
    .padding()
}

#Preview("Multiple Rules") {
    NotificationRowView(
        notification: NotificationResponse(
            publicNotificationId: "notif-002",
            publicCameraId: "cam-001",
            ruleNicknames: ["Motion in backyard", "Person detected"],
            detectionPreviewUrl: nil,
            videoClipUrl: nil,
            createdAt: "2026-08-12T09:15:00.000Z"
        )
    )
    .padding()
}
