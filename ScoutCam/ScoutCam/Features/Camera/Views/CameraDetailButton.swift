//
//  CameraDetailButton.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/27/26.
//
import SwiftUI

struct CameraDetailButton<TEXT: View>: View {
    let image: Image
    var imageColor: Color? = nil
    @ViewBuilder let text: TEXT

    var body: some View {
        VStack(spacing: 8) {
            image
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 56)
                .foregroundStyle(imageColor ?? .primary)
            text
                .font(.title3)
                .bold()
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 110)
        .padding()
        .glassEffect(in: .rect(cornerRadius: Constants.UI.cardCornerRadius))
        .contentShape(RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius))
        .padding(.vertical, 3)
        .padding(.horizontal)
    }
}

#Preview {
    VStack {
        CameraDetailButton(
            image: Image(systemName: "sparkle.text.clipboard"),
            imageColor: Color.blue) {
            Text("Smart Alerts")
        }
        CameraDetailButton(
            image: Image(systemName: "bell.fill"),
            imageColor: Color.yellow
        ) {
            Text("Notifications")
        }
    }
}
