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
        
        return "\(self)".components(separatedBy: "(").first ?? ""
    }
    
    var parameters: [String: FirebaseLoggable]? {
        let mirror = Mirror(reflecting: self)
        
        guard let child = mirror.children.first else { return nil }
        
        // 튜플의 경우
        if Mirror(reflecting: child.value).displayStyle == .tuple {
            
            var dict = [String: FirebaseLoggable]()
            let tupleMirror = Mirror(reflecting: child.value)
            
            // 튜플 안의 각 파라미터를 순회
            for tupleChild in tupleMirror.children {
                guard let paramLabel = tupleChild.label else { continue }
                // FirebaseLoggable 타입 검사
                if let loggableValue = tupleChild.value as? any FirebaseLoggable {
                    dict[paramLabel] = loggableValue
                }
            }
            return dict.isEmpty ? nil : dict
        // 단일 파라미터인 경우
        } else {
            
            guard let label = child.label else { return nil }
            // FirebaseLoggable 타입 검사
            if let loggableValue = child.value as? any FirebaseLoggable {
                return [label: loggableValue]
            }
        }
        
        return nil
    }
}
