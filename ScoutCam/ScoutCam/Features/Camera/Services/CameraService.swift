//
//  CameraService.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/21/26.
//

import Foundation
import os

extension Logger {
    nonisolated static let camera = Logger(
        subsystem: "scout.scoutcam",
        category: "camera"
    )
}


enum CameraError: Error {
    case encodeDecodeFailure
    case unexpected
    case validationFailed([String: String])
}


actor CameraService {
    private let apiClient: ApiClient
    private let cameraStore: CameraStore

    init(apiClient: ApiClient, cameraStore: CameraStore) {
        self.apiClient = apiClient
        self.cameraStore = cameraStore
    }

    func claimCamera(claimToken: String, location: String) async throws {
        let body = ClaimCameraRequest(claimToken: claimToken, location: location)
        
        do {
            let response: ClaimCameraResponse = try await callApi(
                CameraEndpoint.claimCamera,
                body: body
            )
            let camera = Camera(id: response.publicCameraId, location: location)
            await MainActor.run { cameraStore.add(camera) }
            Logger.camera.info("Camera \(camera.id) claimed and cached.")
        } catch {
            Logger.camera
                .error(
                    "An error occurred while claiming a camera: \(error.localizedDescription)."
                )
            throw error
        }
    }
    
    func fetchUserCameras() async throws {
        do {
            let response: [CameraResponse] = try await callApi(CameraEndpoint.getCameras)
            let userCameras = response.map {
                Camera(id: $0.publicCameraId, location: $0.location.capitalized)
            }
            await MainActor.run { cameraStore.cameras = userCameras }
            Logger.camera.info("Successfully retrieved cameras.")
        } catch {
            Logger.camera
                .error(
                    "An error occurred while retrieving cameras for user: \(error)"
                )
            throw error
        }
    }
    
    func callApi<Request: Encodable, Response: Decodable>(_ endpoint: CameraEndpoint, body: Request) async throws -> Response {
        try await mapCameraErrors {
            try await self.apiClient.request(endpoint: endpoint, body: body)
        }
    }

    func callApi<Response: Decodable>(_ endpoint: CameraEndpoint) async throws -> Response {
        try await mapCameraErrors {
            try await self.apiClient.request(endpoint)
        }
    }

    private func mapCameraErrors<T>(_ call: () async throws -> T) async throws -> T {
        do {
            return try await call()
        } catch let APIError.encodingError(error) {
            Logger.camera.error("Unable to encode camera service request to json: \(error).")
            throw CameraError.encodeDecodeFailure
        } catch let APIError.decodingError(error) {
            Logger.camera.error("Unable to decode camera service response from json: \(error)")
            throw CameraError.encodeDecodeFailure
        } catch APIError.unauthorized {
            Logger.camera.error("Invalid credentials")
            throw AuthError.invalidCredentials
        } catch let APIError.validationErrors(fields) {
            Logger.camera.error("Validation failed: \(fields)")
            throw CameraError.validationFailed(fields.compactMapValues({ $0.first }))
        } catch {
            Logger.camera.error("Unexpected error: \(error).")
            throw CameraError.unexpected
        }
    }
}
