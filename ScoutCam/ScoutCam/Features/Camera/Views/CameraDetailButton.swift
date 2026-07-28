//
//  CameraDetailButton.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/27/26.
//
import SwiftUI


struct CameraDetailButton<TEXT: View> : View {
        let image: Image
        var imageHeight: CGFloat? = nil
        var buttonHeight: CGFloat = 130
        var buttonSpacing: CGFloat? = nil
        var imageTextPadding: CGFloat = 10
        @ViewBuilder let text: TEXT

        var body: some View {
            RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                .fill(.clear)
            .frame(height: buttonHeight)
            .overlay(
                VStack(spacing: buttonSpacing) {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: imageHeight)
                    text
                        .font(.title2)
                        .foregroundStyle(Color.primary)
                        .padding(.top, imageTextPadding)
                }
                .padding()
            )
            .glassEffect(in: .rect(cornerRadius: Constants.UI.cardCornerRadius))
            .padding(.vertical, 3)
            .padding(.horizontal)
        }
    }

#Preview {
    CameraDetailButton(image: Image(systemName: "video")) {
        Text("This is a camera detail button")
    }
}
