//
//  LocationPromptSheetView.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/23/26.
//

import SwiftUI

struct LocationPromptSheetView: View {
    @Bindable var viewModel: QRScannerViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Name Your Camera")
                    .font(.title2).bold()
                Text("Enter a location so you can identify this camera later.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            TextField("Kitchen", text: $viewModel.location)
                .textFieldStyle(.roundedBorder)
                .controlSize(.large)

            Button {
                Task {
                    await viewModel.saveCamera()
                    dismiss()
                }
            } label: {
                Text("Save Camera")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 8))
            .disabled(viewModel.location.trimmingCharacters(in: .whitespaces).isEmpty)

            Button("Cancel", role: .cancel) {
                viewModel.cancelClaim()
                dismiss()
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .padding(.top, 8)
    }
}

#Preview {
    LocationPromptSheetView(
        viewModel: QRScannerViewModel(
            cameraService: AppDependencies().cameraService
        )
    )
}
