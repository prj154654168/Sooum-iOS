//
//  UIColor+SOOUM.swift
//  SOOUM
//
//  Created by 오현식 on 9/7/24.
//

import UIKit

extension UIColor: SOOUMStyleCompatible { }

extension SOOUMStyle where Base == UIColor {
    
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
    static let black = UIColor(hex: "#000000")
    
    // Dim
    static let dim = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
}
