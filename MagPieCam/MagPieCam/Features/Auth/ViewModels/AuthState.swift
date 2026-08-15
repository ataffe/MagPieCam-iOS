//
//  AuthState.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/19/26.
//

import Foundation

@MainActor
@Observable
final class AuthState {
    enum Status {
        case checking      // app just launched, verifying Keychain
        case signedOut
        case signedIn
    }

    var status: Status = .checking
}
