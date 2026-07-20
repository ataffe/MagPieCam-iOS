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
