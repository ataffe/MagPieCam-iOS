//
//  CameraDetailButton.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/27/26.
//
import SwiftUI

struct CameraDetailButton<TEXT: View>: View {
    let image: Image
    @ViewBuilder let text: TEXT

    var body: some View {
        VStack(spacing: 8) {
            image
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 56)
            text
                .font(.title3)
                .bold()
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 110)
        .padding()
        .glassEffect(in: .rect(cornerRadius: Constants.UI.cardCornerRadius))
        .padding(.vertical, 3)
        .padding(.horizontal)
    }
}

#Preview {
    VStack {
        CameraDetailButton(image: Image(systemName: "sparkle.text.clipboard")) {
            Text("Smart Alerts")
        }
        CameraDetailButton(image: Image(systemName: "bell.fill")) {
            Text("Notifications")
        }
    }
}
