//
//  CameraDetailViewModel.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/24/26.
//

import Foundation

@Observable
@MainActor
final class CameraDetailViewModel {
    let camera: Camera
    let cameraService: CameraService
    
    struct Notification {
        let rule: String
        let time: String
        let numTimesRuleTriggered: Int
    }
    
    var recentNotifications: [Notification]

    init(
        camera: Camera,
        cameraService: CameraService,
        recentNotifications: [Notification]
    ) {
        self.camera = camera
        self.cameraService = cameraService
        self.recentNotifications = recentNotifications
    }
    
    func getNotifcations() async throws {
        // TODO: Complete function
    }
}
