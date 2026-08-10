//
//  NotificationDTO.swift
//  ScoutCam
//
//  Created by Alexander Taffe on 8/8/26.
//

import Foundation

nonisolated struct NotificationResponse: Decodable {
    let publicNotificationId: String
    let publicCameraId: String
    let ruleNickname: String
    let createdAt: String
}

nonisolated struct GetNotificationsResponse: Decodable {
    let next: String?
    let previous: String?
    let results: [NotificationResponse]
}
