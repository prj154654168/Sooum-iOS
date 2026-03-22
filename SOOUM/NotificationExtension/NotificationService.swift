//
//  NotificationService.swift
//  NotificationExtension
//
//  Created by 오현식 on 3/21/26.
//

import UserNotifications

import OSLog

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = self.bestAttemptContent,
           let attachmentString = request.content.userInfo["imageUrl"] as? String,
           let attachmentURL = URL(string: attachmentString) {
            
            self.downloadAndSave(url: attachmentURL) { localURL in
                if let localURL = localURL {
                    do {
                        let attachment = try UNNotificationAttachment(identifier: "image_attachment", url: localURL, options: nil)
                        bestAttemptContent.attachments = [attachment]
                        Logger.notification.info("Attachment creation success")
                    } catch {
                        Logger.notification.error("Attachment creation error: \(error)")
                    }
                }
                contentHandler(bestAttemptContent)
            }
        } else {
            contentHandler(request.content)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = self.contentHandler, let bestAttemptContent = self.bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    private func downloadAndSave(url: URL, completion: @escaping (URL?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { tempURL, _, _ in
            guard let tempURL = tempURL else {
                completion(nil)
                return
            }
            
            let fileManager = FileManager.default
            let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
            let identifier = UUID().uuidString
            let localURL = cacheDirectory.appendingPathComponent("\(identifier).jpg")
            
            try? fileManager.removeItem(at: localURL)
            try? fileManager.moveItem(at: tempURL, to: localURL)
            
            completion(localURL)
        }
        task.resume()
    }
}
