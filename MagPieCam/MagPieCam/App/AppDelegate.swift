//
//  AppDelegate.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 7/30/26.
//

import UIKit
import UserNotifications
import os

extension Notification.Name {
    static let didReceiveApnsToken = Notification.Name("didReceiveApnsToken")
    static let didTapPushNotification = Notification.Name("didTapPushNotification")
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

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

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Called when user taps a notification (foreground or background)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let cameraId = userInfo["camera-id"] as? String,
           let notificationId = userInfo["notification-id"] as? String {
            NotificationCenter.default.post(
                name: .didTapPushNotification,
                object: PushDeepLink(cameraId: cameraId, notificationId: notificationId)
            )
        }
        completionHandler()
    }

    // Allow banners/sound when app is in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
