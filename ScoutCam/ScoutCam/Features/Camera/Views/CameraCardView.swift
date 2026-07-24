//
//  CameraCardView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/23/26.
//

import SwiftUI

struct CameraCardView: View {
    let camera: Camera

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.secondarySystemBackground))
            .frame(height: 120)
            .overlay(
                VStack {
                    // TODO: Get an image from the camera.
                    Image(systemName: "camera.circle")
                        .resizable()
                        .scaledToFit()
                    Text(camera.location)
                        .font(.headline)
                }
                    .padding()
            )
            .padding(5)
    }
}

#Preview {
    CameraCardView(camera: Camera(id: "1", location: "Kitchen"))
}
