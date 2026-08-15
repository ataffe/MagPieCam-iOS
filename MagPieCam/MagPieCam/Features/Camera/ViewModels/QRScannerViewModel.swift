//
//  QRScannerViewModel.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/20/26.
//

import Foundation
import CodeScanner

@Observable
@MainActor
final class QRScannerViewModel {
    let cameraService: CameraService
    
    
    init(cameraService: CameraService) {
        self.cameraService = cameraService
    }
    
    var isLoading = false
    var claimToken = ""
    var location = ""
    var isShowingLocationPrompt = false
    var didSuccessfullyClaim = false

    func handleScanResult(_ result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let scan):
            claimToken = scan.string
            isShowingLocationPrompt = true
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }

    func cancelClaim() {
        claimToken = ""
        location = ""
        isShowingLocationPrompt = false
    }

    func saveCamera() async {
        isShowingLocationPrompt = false
        isLoading = true
        do {
            try await cameraService.claimCamera(claimToken: claimToken, location: location)
            didSuccessfullyClaim = true
        } catch {
            print("There was an error: \(error.localizedDescription)")
        }
        claimToken = ""
        location = ""
        isLoading = false
    }
}
