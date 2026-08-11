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
    var queryItems: [URLQueryItem] { get }
}

extension ApiEndpoint {
    var queryItems: [URLQueryItem] { [] }
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

    var path: String {
        switch self {
        case .claimCamera: "cameras/claim/"
        case .getCameras: "cameras/"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .claimCamera: .post
        case .getCameras: .get
        }
    }
}

enum RuleEndpoint: ApiEndpoint {
    case getRules(cameraId: String)
    case addRule(cameraId: String)
    case deleteRule(cameraId: String, ruleId: String)
    case updateRule(cameraId: String, ruleId: String)

    var path: String {
        switch self {
        case .getRules(let cameraId):
            "cameras/\(cameraId)/rules/"
        case .addRule(let cameraId): "cameras/\(cameraId)/rules/"
        case .updateRule(
            let cameraId,
            let ruleId
        ): "cameras/\(cameraId)/rules/\(ruleId)/"
        case .deleteRule(let cameraId, let ruleId):
            "cameras/\(cameraId)/rules/\(ruleId)/"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getRules: .get
        case .addRule: .post
        case .updateRule: .put
        case .deleteRule: .delete
        }
    }
}

enum StreamingEndpoint: ApiEndpoint {
    case start(cameraId: String)

    var path: String {
        switch self {
        case .start(let cameraId): "cameras/\(cameraId)/streaming/start/"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .start: .post
        }
    }
}

enum UserEndpoint: ApiEndpoint {
    case updateApnsToken
    
    var path: String {
        switch self {
        case .updateApnsToken: "users/apns_token/"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .updateApnsToken: .post
        }
    }
}

enum NotificationsEndpoint: ApiEndpoint {
    case getNotifications(cameraId: String, cursor: String? = nil)
    case clearNotifications(cameraId: String)

    var path: String {
        switch self {
        case .getNotifications(let cameraId, _): "cameras/\(cameraId)/notifications/"
        case .clearNotifications(let cameraId): "cameras/\(cameraId)/notifications/clear/"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getNotifications: .get
        case .clearNotifications: .post
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .getNotifications(_, let cursor):
            guard let cursor else { return [] }
            return [URLQueryItem(name: "cursor", value: cursor)]
        case .clearNotifications(_): return []
        }
    }
}
