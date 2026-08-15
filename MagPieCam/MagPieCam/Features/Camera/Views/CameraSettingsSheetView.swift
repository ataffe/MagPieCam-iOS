//
//  CameraSettingsSheetView.swift
//  MagPieCam
//
//  Created by Alexander Taffe on 7/19/26.
//

import SwiftUI

struct CameraSettingsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    let camera: Camera
    let cameraService: CameraService
    let onSave: (String) -> Void

    @State private var location: String
    @State private var isSaving = false
    @State private var errorMessage: String? = nil

    init(camera: Camera, cameraService: CameraService, onSave: @escaping (String) -> Void) {
        self.camera = camera
        self.cameraService = cameraService
        self.onSave = onSave
        self._location = State(initialValue: camera.location)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Camera Settings")
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 32)

            VStack(alignment: .leading, spacing: 6) {
                Text("Location")
                    .font(.headline)
                TextField("e.g. Front Door", text: $location)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            Spacer()

            Button {
                isSaving = true
                errorMessage = nil
                Task {
                    do {
                        try await cameraService.updateCamera(id: camera.id, location: location)
                        onSave(location.capitalized)
                        dismiss()
                    } catch {
                        errorMessage = "Failed to save. Please try again."
                    }
                    isSaving = false
                }
            } label: {
                Group {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius))
            }
            .disabled(location.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
            .padding(.bottom, 32)
        }
        .padding(.horizontal)
        .background(Constants.UI.backgroundGradient(for: colorScheme).ignoresSafeArea())
    }
}

#Preview {
    let deps = AppDependencies()
    CameraSettingsSheetView(
        camera: Camera(id: "123", location: "Kitchen", cameraPreviewUrl: nil, previewUpdatedAt: nil),
        cameraService: deps.cameraService,
        onSave: { _ in }
    )
}
