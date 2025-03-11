//
//  SMEvent.swift
//  SOOUM
//
//  Created by JDeoks on 3/11/25.
//

enum SMEvent {
  enum Tooltip: AnalyticsEventProtocol {
    case tapNext
    case tapPrev
    case tapStart
    case tapSkip
  }
}
