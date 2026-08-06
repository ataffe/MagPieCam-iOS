//
//  AppDelegate.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/30/26.
//

import UIKit
import os

extension Notification.Name {
    static let didReceiveApnsToken = Notification.Name("didReceiveApnsToken")
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        NotificationCenter.default.post(name: .didReceiveApnsToken, object: token)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Logger.auth.error("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}
