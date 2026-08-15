//
//  CameraPreviewCard.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/27/26.
//

import SwiftUI

struct CameraDetailPreviewCardView: View {
    let previewImage: UIImage
    let location: String
    
    var body: some View {
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
                Text(location)
                    .font(Constants.UI.cameraPreviewLocationFont)
                    .foregroundStyle(.white)
                    .padding()
            }
            .overlay(alignment: .center) {
                VStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .foregroundStyle(Color.red)
                    Text("Go Live")
                        .foregroundStyle(.white)
                }
                .bold()
                .font(.largeTitle)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
    }
}

#Preview {
    CameraDetailPreviewCardView(previewImage: UIImage(named: "preview_test_image")!, location: "Yosemite")
}
