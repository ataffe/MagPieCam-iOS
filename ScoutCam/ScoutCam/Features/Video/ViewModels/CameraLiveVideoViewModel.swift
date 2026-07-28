//
//  CameraLiveVideoViewModel.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/25/26.
//

import Foundation

@Observable
@MainActor
final class CameraLiveVideoViewModel {
    let videoUrl: URL
    
    init(videoUrl: String) {
        self.videoUrl = URL(string: videoUrl)!
    }
}
