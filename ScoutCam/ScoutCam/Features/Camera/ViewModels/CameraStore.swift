//
//  CameraStore.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/23/26.
//

import Foundation

struct Camera: Identifiable {
    let id: String  // publicCameraId returned by the backend
    let location: String
}

@Observable
@MainActor
final class CameraStore {
    var cameras: [Camera] = []

    func add(_ camera: Camera) {
        cameras.append(camera)
    }
}
