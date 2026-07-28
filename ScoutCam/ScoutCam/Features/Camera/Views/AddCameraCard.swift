//
//  AddCameraCard.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/27/26.
//
import SwiftUI

struct AddCameraCard: View {
        var body: some View {
            RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                .fill(.clear)
                .frame(height: 120)
                .overlay(
                    Image(systemName: "plus.square")
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(.secondary)
                )
                .glassEffect(
                    in: .rect(cornerRadius: Constants.UI.cardCornerRadius)
                )
                .contentShape(
                    RoundedRectangle(
                        cornerRadius: Constants.UI.cardCornerRadius
                    )
                )
        }
    }

#Preview {
    AddCameraCard()
}
