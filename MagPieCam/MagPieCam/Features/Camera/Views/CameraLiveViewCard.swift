//
//  CameraLiveViewCard.swift
//  MagPieCam
//
//  Created by Alexander Taffe on 7/19/26.
//

import SwiftUI

struct CameraLiveViewCard: View {
    let camera: Camera
    let previewImage: UIImage?

    @State private var feedbackTrigger = false

    var body: some View {
        NavigationLink(destination: CameraStreamingView(camera: camera)) {
            if let previewImage {
                CameraDetailPreviewCardView(
                    previewImage: previewImage
                )
            } else {
                CameraDetailButton(image: Image(systemName: "video")) {
                    Text("Go Live")
                }
                .foregroundStyle(.red)
            }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            feedbackTrigger.toggle()
        })
        .sensoryFeedback(.selection, trigger: feedbackTrigger)
    }
}

#Preview {
    NavigationStack {
        CameraLiveViewCard(
            camera: Camera(id: "1", location: "Kitchen", cameraPreviewUrl: nil, previewUpdatedAt: nil),
            previewImage: UIImage(named: "PreviewCamera")
        )
    }
    .environment(AppDependencies())
}
