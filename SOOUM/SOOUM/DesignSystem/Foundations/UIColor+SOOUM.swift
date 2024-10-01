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
    static let primary = UIColor(hex: "#0BC7F2")
    
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
    static let white = UIColor(hex: "#FFFFFF")
    static let gray01 = UIColor(hex: "#7D7D7D")
    static let gray02 = UIColor(hex: "#B4B4B4")
    static let gray03 = UIColor(hex: "#C7C7C7")
    static let black = UIColor(hex: "#000000")
    
    // Dim
    static let dimForCard = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    static let dimForTabBar = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
}
