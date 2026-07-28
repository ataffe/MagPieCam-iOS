//
//  CameraDTOs.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/24/26.
//

import Foundation

nonisolated struct ClaimCameraResponse: Decodable {
    let publicCameraId: String
}

nonisolated struct ClaimCameraRequest: Encodable {
    let claimToken: String
    let location: String
}

nonisolated struct CameraResponse: Decodable {
    let publicCameraId: String
    let location: String
    let cameraPreviewUrl: String?
}
