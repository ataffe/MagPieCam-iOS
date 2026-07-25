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
    
    func getUserCameras() async {
        isLoading = true
        
        defer { isLoading = false }
        
        do {
            try await cameraService.fetchUserCameras()
        } catch {
            // TODO: Show an error message
        }
    }
}
