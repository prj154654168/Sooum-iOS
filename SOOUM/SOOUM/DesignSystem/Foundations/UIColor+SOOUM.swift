//
//  UIColor+SOOUM.swift
//  SOOUM
//
//  Created by 오현식 on 9/7/24.
//

import UIKit

extension UIColor: SOOUMStyleCompatible { }

extension SOOUMStyle where Base == UIColor {
    
    // Primary
    static let p100 = UIColor(hex: "#EFFAFF")
    static let p200 = UIColor(hex: "#AFE5FD")
    static let p300 = UIColor(hex: "#0BC7F2")
    
    // Secondary
    static let red = UIColor(hex: "#FF2424")
    
    // Blue
    static let blue50 = UIColor(hex: "#E7F9FE")
    static let blue100 = UIColor(hex: "#B4EEFB")
    static let blue200 = UIColor(hex: "#8FE5F9")
    static let blue300 = UIColor(hex: "#5CD9F6")
    static let blue400 = UIColor(hex: "#3DD2F5")
    static let blue500 = UIColor(hex: "#0CC7F2")
    static let blue600 = UIColor(hex: "#0BB5DC")
    static let blue700 = UIColor(hex: "#098DAC")
    static let blue800 = UIColor(hex: "#076D85")
    static let blue900 = UIColor(hex: "#055466")
    
    // Gray Scale
    static let white = UIColor(hex: "#FEFEFE")
    static let gray50 = UIColor(hex: "#F9F9F9")
    static let gray100 = UIColor(hex: "#EEEEEE")
    static let gray200 = UIColor(hex: "#E5E5E5")
    static let gray300 = UIColor(hex: "#C7C7C7")
    static let gray400 = UIColor(hex: "#B5B5B5")
    static let gray500 = UIColor(hex: "#8D8D8D")
    static let gray600 = UIColor(hex: "#6D6D6D")
    static let gray700 = UIColor(hex: "#545454")
    static let gray800 = UIColor(hex: "#3A3A3A")
    static let black = UIColor(hex: "#222222")
    
    // Dim
    static let dimForCard = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    static let dimForTabBar = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
}
