//
//  Double.swift
//  SOOUM
//
//  Created by 오현식 on 9/27/24.
//

import Foundation


extension Double {
    
    var toString: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        let string = numberFormatter.string(from: NSNumber(value: self))
        return string?.replacingOccurrences(of: ",", with: "")
    }
    
    func infoReadableDistanceRangeFromThis() -> String {
        
        switch self {
        case ..<0.1:
            return "100m 이내"
        case 0.1..<1:
            let roundedDistance = ceil(self * 1000)
            return "\(Int(roundedDistance))m 이내"
        case 1..<100:
            let roundedDistance = ceil(self / 5) * 5
            return "\(Int(roundedDistance))km 이내"
        default:
            let roundedDistance = ceil(self / 100) * 100
            return "\(Int(roundedDistance))km 이내"
        }
    }
}
