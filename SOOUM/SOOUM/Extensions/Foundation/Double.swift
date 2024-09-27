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
        case ..<100:
            return "100m 이내"
        case 100..<900:
            let roundedDistance = Int(ceil(self / 100.0)) * 100
            return "\(roundedDistance)m 이내"
        case 900..<100000:
            let roundedDistance = Int(ceil(self / 5000.0)) * 5
            return "\(roundedDistance)km 이내"
        default:
            let roundedDistance = Int(ceil(self / 100000.0)) * 100
            return "\(roundedDistance)km 이내"
        }
    }
}
