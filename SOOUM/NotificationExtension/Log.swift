//
//  Log.swift
//  SOOUM
//
//  Created by 오현식 on 3/22/26.
//

import OSLog

extension Logger {
    
    private static var subsystem = Bundle.main.bundleIdentifier ?? "com.sooum.notificationExtension"
    
    static let notification = Logger(subsystem: Self.subsystem, category: "NotificationService")
}
