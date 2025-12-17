//
//  GAHelper.swift
//  SOOUM
//
//  Created by JDeoks on 3/11/25.
//

import FirebaseAnalytics

final class GAHelper {
    
    static let shared = GAHelper()
    private init() { }
    
    func logEvent(event: AnalyticsEventProtocol) {
        Analytics.logEvent(event.eventName, parameters: event.parameters)
    }
}
