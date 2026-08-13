//
//  NotificationViewCard.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 8/11/26.
//

import SwiftUI
import AVKit

struct NotificationCardView: View {
    let notification: NotificationResponse
    @State private var player: AVPlayer?

    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private var parsedDate: Date? {
        Self.isoFormatter.date(from: notification.createdAt)
            ?? ISO8601DateFormatter().date(from: notification.createdAt)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            mediaSection
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: Constants.UI.cardCornerRadius,
                    topTrailingRadius: Constants.UI.cardCornerRadius
                ))
            infoRow
                .glassEffect(in: .rect(cornerRadii: RectangleCornerRadii(
                    bottomLeading: Constants.UI.cardCornerRadius,
                    bottomTrailing: Constants.UI.cardCornerRadius
                )))
        }
        .clipShape(RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius))
        .onAppear {
            if let urlString = notification.videoClipUrl, let url = URL(string: urlString) {
                player = AVPlayer(url: url)
            }
        }
        .onChange(of: notification.videoClipUrl) { _, newUrl in
            guard player == nil, let urlString = newUrl, let url = URL(string: urlString) else { return }
            player = AVPlayer(url: url)
        }
        .onDisappear {
            player?.pause()
        }
    }
    
    // MARK: - Media Section
    @ViewBuilder
        private var mediaSection: some View {
            if let player {
                FullscreenVideoPlayer(player: player)
                    .frame(height: 220)
            } else if let urlString = notification.detectionPreviewUrl, let url = URL(string: urlString) {
                ZStack(alignment: .bottom) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Color.secondary.opacity(0.2)
                        }
                    }
                    .frame(height: 220)
                    .clipped()

                    HStack(spacing: 6) {
                        ProgressView().tint(.white).scaleEffect(0.8)
                        Text("Video clip is processing")
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(12)
                }
            } else {
                Image(systemName: "bell.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
            }
        }

// MARK: - Info Row
        private var infoRow: some View {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(notification.ruleNicknames, id: \.self) { nickname in
                        Text(nickname)
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
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
        }
    }


    #Preview("With Video Clip") {
        NotificationCardView(
            notification: NotificationResponse(
                publicNotificationId: "notif-001",
                publicCameraId: "cam-001",
                ruleNicknames: ["Person at front door", "Amazon Delivery"],
                detectionPreviewUrl: nil,
                videoClipUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                createdAt: "2026-08-11T14:32:00.000Z"
            )
        )
        .padding()
    }


    #Preview("Multiple Rules") {
        NotificationCardView(
            notification: NotificationResponse(
                publicNotificationId: "notif-002",
                publicCameraId: "cam-001",
                ruleNicknames: ["Person at front door", "Package delivered"],
                detectionPreviewUrl: "https://picsum.photos/seed/scoutcam/800/450",
                videoClipUrl: nil,
                createdAt: "2026-08-11T13:15:00.000Z"
            )
        )
        .padding()
    }

    #Preview("Clip Processing") {
        NotificationCardView(
            notification: NotificationResponse(
                publicNotificationId: "notif-003",
                publicCameraId: "cam-001",
                ruleNicknames: ["Motion in backyard"],
                detectionPreviewUrl: "https://picsum.photos/seed/scoutcam/800/450",
                videoClipUrl: nil,
                createdAt: "2026-08-11T13:15:00.000Z"
            )
        )
        .padding()
    }

    #Preview("No Media") {
        NotificationCardView(
            notification: NotificationResponse(
                publicNotificationId: "notif-004",
                publicCameraId: "cam-001",
                ruleNicknames: ["Package delivered"],
                detectionPreviewUrl: nil,
                videoClipUrl: nil,
                createdAt: "2026-08-11T09:00:00.000Z"
            )
        )
        .padding()
    }
