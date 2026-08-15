//
//  NotificationService.swift
//  DetectNotificationExtension
//
//  Created by Alexander Taffe on 8/9/26.
//

import UserNotifications
import os

private let logger = Logger(subsystem: "scout.scoutcam.extension", category: "NotificationService")

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        logger.info("didReceive called. userInfo: \(request.content.userInfo, privacy: .public)")

        guard let bestAttemptContent else {
            logger.error("Failed to create mutable copy of notification content.")
            contentHandler(request.content)
            return
        }

        guard let urlString = request.content.userInfo["detection-image-url"] as? String else {
            logger.error("'detection-img-url' key missing or not a String. Keys present: \(request.content.userInfo.keys.map { "\($0)" }, privacy: .public)")
            contentHandler(bestAttemptContent)
            return
        }

        guard let url = URL(string: urlString) else {
            logger.error("Could not construct URL from string: \(urlString, privacy: .public)")
            contentHandler(bestAttemptContent)
            return
        }

        logger.info("Downloading image from: \(url.absoluteString, privacy: .public)")

        downloadImage(from: url) { attachment in
            if let attachment {
                logger.info("Image downloaded and attached successfully.")
                bestAttemptContent.attachments = [attachment]
            } else {
                logger.error("Image download failed or produced no attachment.")
            }
            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        logger.warning("serviceExtensionTimeWillExpire called — delivering best attempt.")
        if let contentHandler, let bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    // MARK: - Helpers

    private func downloadImage(from url: URL, completion: @escaping (UNNotificationAttachment?) -> Void) {
        URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            if let error {
                logger.error("URLSession download error: \(error.localizedDescription, privacy: .public)")
                completion(nil)
                return
            }

            guard let tempURL else {
                logger.error("Download completed but tempURL is nil.")
                completion(nil)
                return
            }

            let destination = tempURL.deletingLastPathComponent()
                .appendingPathComponent(url.lastPathComponent.isEmpty ? "preview.jpg" : url.lastPathComponent)

            do {
                try FileManager.default.moveItem(at: tempURL, to: destination)
            } catch {
                logger.error("Failed to move downloaded file: \(error.localizedDescription, privacy: .public)")
                completion(nil)
                return
            }

            do {
                let attachment = try UNNotificationAttachment(
                    identifier: "previewImage",
                    url: destination,
                    options: nil
                )
                completion(attachment)
            } catch {
                logger.error("Failed to create UNNotificationAttachment: \(error.localizedDescription, privacy: .public)")
                completion(nil)
            }
        }.resume()
    }
}
