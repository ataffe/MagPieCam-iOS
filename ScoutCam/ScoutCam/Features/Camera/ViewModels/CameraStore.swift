//
//  CameraStore.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/23/26.
//

import UIKit

struct Camera: Identifiable {
    let id: String  // publicCameraId returned by the backend
    let location: String
    let cameraPreviewUrl: String?
    let previewUpdatedAt: String?

    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    var parsedPreviewUpdatedAt: Date? {
        guard let previewUpdatedAt else { return nil }
        return Camera.isoFormatter.date(from: previewUpdatedAt)
            ?? ISO8601DateFormatter().date(from: previewUpdatedAt)
    }
}

@Observable
@MainActor
final class CameraStore {
    var cameras: [Camera] = []
    var previewImages: [String: UIImage] = [:]

    func add(_ camera: Camera) {
        cameras.append(camera)
    }
}
