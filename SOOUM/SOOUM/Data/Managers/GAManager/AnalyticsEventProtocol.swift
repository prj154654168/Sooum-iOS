//
//  AnalyticsEventProtocol.swift
//  SOOUM
//
//  Created by JDeoks on 3/11/25.
//

protocol AnalyticsEventProtocol {
  var eventName: String { get }
  var parameters: [String: FirebaseLoggable]? { get }
}

extension AnalyticsEventProtocol {
  
  var eventName: String {
    let enumName = String(describing: type(of: self)) // "Home"
    let caseName = "\(self)".components(separatedBy: "(").first ?? "" // "fetchDefectList"
    return "\(enumName)_\(caseName)" // "Home_fetchDefectList"
  }

  var parameters: [String: FirebaseLoggable]? {
    // (1) 우선 "self"를 미러링 -> enum의 유일한 자식(child)이 "someEvent"라는 케이스
    let paramDict = Mirror(reflecting: self).children.reduce(into: [String: FirebaseLoggable]()) { dict, child in
      guard let caseLabel = child.label else {
        return
      }
      
      let caseValue = child.value
      let caseMirror = Mirror(reflecting: caseValue)
      if caseMirror.displayStyle == .tuple {
        // 🔑 "someEvent(num: 2, text: \"테스트\")" 이런 형태로 들어옴

        // (3) 튜플 안에 있는 각 연관값( num: 2, text: "테스트" )을 순회
        for paramChild in caseMirror.children {
          guard let paramLabel = paramChild.label else { continue }
          let paramValue = paramChild.value

          // (4) FirebaseLoggable 등 타입 검사
          if paramValue is FirebaseLoggable {
            dict[paramLabel] = paramValue as? any FirebaseLoggable
          }
        }
      } else if caseValue is FirebaseLoggable {
        // (단일 파라미터인 경우)
        dict[caseLabel] = caseValue as? any FirebaseLoggable
      }
    }

    return paramDict.isEmpty ? nil : paramDict
  }
}
