//
//  String.swift
//  SOOUM
//
//  Created by 오현식 on 11/16/25.
//

import UIKit

extension String {
    /// 자음인지 여부 확인
    var isConsonant: Bool {
        guard let scalar = UnicodeScalar(self)?.value else {
            return false
        }
        
        let consonantScalarRange: ClosedRange<UInt32> = 12593...12622
        return consonantScalarRange ~= scalar
    }
    /// 영어인지 여부 확인
    var isEnglish: Bool {
        guard self.isEmpty == false else { return false }
        
        let pattern = "^[a-zA-Z]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: self)
    }
}
