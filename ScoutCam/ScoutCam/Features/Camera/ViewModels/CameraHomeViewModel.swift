//
//  CameraHomeViewModel.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/23/26.
//

import Foundation


@Observable
@MainActor
final class CameraHomeViewModel {
    let cameraService: CameraService
    var isLoading = false
    
    init(cameraService: CameraService) {
        self.cameraService = cameraService
    }
    
    func getCameras() async {
        do {
            isLoading = true
            try await cameraService.getCameras()
            isLoading = false
        } catch {
            // TODO: Show an error message
        }
    }
}
