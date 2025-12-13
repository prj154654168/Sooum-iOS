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
        let components = String(describing: type(of: self)).split(separator: ".").map { String($0) }
        
        let parentEnumName = components.first ?? ""
        let childEnumName = components.last ?? ""
        
        let caseName = "\(self)".components(separatedBy: "(").first ?? ""
        
        return "\(parentEnumName)_\(childEnumName)_\(caseName)"
    }
    
    var parameters: [String: FirebaseLoggable]? {
        let mirror = Mirror(reflecting: self)
            
        // Case 1: Associated Value를 가진 Enum Case
        if let tupleValue = mirror.children.first?.value,
           Mirror(reflecting: tupleValue).displayStyle == .tuple {
            
            var dict = [String: FirebaseLoggable]()
            let tupleMirror = Mirror(reflecting: tupleValue)
            
            // 튜플 안의 각 파라미터를 순회
            for paramChild in tupleMirror.children {
                guard let paramLabel = paramChild.label else { continue }
                let paramValue = paramChild.value
                
                // FirebaseLoggable 타입 검사
                if let loggableValue = paramValue as? any FirebaseLoggable {
                    dict[paramLabel] = loggableValue
                }
            }
            return dict.isEmpty ? nil : dict
            
        }
        // Case 2: Associated Value가 없는 단순 Case (파라미터 없음)
        // 현재 코드는 단일 파라미터인 경우를 처리하나, Associated Value가 없는 경우는 `nil` 반환이 적절함.
        
        return nil
    }
}
