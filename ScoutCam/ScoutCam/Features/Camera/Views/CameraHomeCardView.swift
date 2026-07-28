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
                            .padding()
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
        camera: Camera(id: "1", location: "Kitchen", cameraPreviewUrl: nil),
        previewImage: nil
    )
}
