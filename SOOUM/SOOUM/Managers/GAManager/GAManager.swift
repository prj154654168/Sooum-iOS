//
//  GAManager.swift
//  SOOUM
//
//  Created by JDeoks on 3/11/25.
//

import FirebaseAnalytics

class GAManager {
  
  static let shared = GAManager()
    
  private init() { }
  
  func logEvent(event: AnalyticsEventProtocol) {
    Analytics.logEvent(event.eventName, parameters: event.parameters)
  }
}
