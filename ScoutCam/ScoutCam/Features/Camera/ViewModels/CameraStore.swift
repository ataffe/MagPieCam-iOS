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
