//
//  Endpoints.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/18/26.
//

import Foundation

protocol ApiEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
}


enum AuthEndpoint: ApiEndpoint {
    case signUp
    case logIn
    case refreshToken
    
    var path: String {
        switch self {
        case .signUp: "auth/register/"
        case .logIn: "auth/token/"
        case .refreshToken: "auth/token/refresh/"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .signUp, .logIn, .refreshToken: .post
        }
    }
}

enum CameraEndpoint: ApiEndpoint {
    case claimCamera
    case getCameras
    case getRules(cameraId: Int)
    case newRule(cameraId: Int)
    case updateRule(cameraId: Int, ruleId: Int)

    var path: String {
        switch self {
        case .claimCamera:
            "cameras/claim/"
        case .getCameras: "cameras/"
        case .getRules(let cameraId):
            "cameras/\(cameraId)/rules/"
        case .newRule(let cameraId):
            "cameras/\(cameraId)/rules/"
        case .updateRule(let cameraId, let ruleId):
            "cameras/\(cameraId)/rules/\(ruleId)/"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .claimCamera, .newRule: .post
        case .getRules, .getCameras: .get
        case .updateRule: .put
        }
    }
}
