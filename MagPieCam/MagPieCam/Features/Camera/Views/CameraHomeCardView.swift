//
//  CameraCardView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/23/26.
//

import SwiftUI

struct CameraHomeCardView: View {
    let camera: Camera
    let previewImage: UIImage?

    var body: some View {
        Group {
            if let previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: Constants.UI.cameraPreviewCardHeight)
                    .overlay(alignment: .bottom) {
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.6)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                    }
                    .overlay(alignment: .topLeading) {
                        Text(camera.location)
                            .font(Constants.UI.cameraPreviewLocationFont)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                            .padding()
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if let date = camera.parsedPreviewUpdatedAt {
                            Text(date, format: .relative(presentation: .named))
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(8)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.clear)
                    .frame(height: 120)
                    .overlay {
                        VStack {
                            Image(systemName: "camera.circle")
                                .resizable()
                                .scaledToFit()
                            Text(camera.location)
                                .font(.headline)
                        }
                        .padding()
                    }
                    .glassEffect(
                        in: .rect(cornerRadius: Constants.UI.cardCornerRadius)
                    )
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .padding(5)
    }
}

#Preview {
    CameraHomeCardView(
        camera: Camera(id: "1", location: "Kitchen", cameraPreviewUrl: nil, previewUpdatedAt: "2026-08-14T12:00:00.000Z"),
        previewImage: UIImage(named: "PreviewCamera") ?? UIImage(systemName: "photo")
    )
}
