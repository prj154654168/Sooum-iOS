//
//  UIColor.swift
//  SOOUM
//
//  Created by 오현식 on 9/7/24.
//

import UIKit


extension UIColor {
    
    convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: a
        )
    }

    convenience init(rgb: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(rgb) / 255.0,
            green: CGFloat(rgb) / 255.0,
            blue: CGFloat(rgb) / 255.0,
            alpha: a
        )
    }
    
    public convenience init(hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        while cString.count < 8 {
            cString += "F"
        }

        var rgbaValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbaValue)

        self.init(
            red: CGFloat((rgbaValue & 0xFF000000) >> 24) / 255.0,
            green: CGFloat((rgbaValue & 0x00FF0000) >> 16) / 255.0,
            blue: CGFloat((rgbaValue & 0x0000FF00) >> 8) / 255.0,
            alpha: CGFloat(rgbaValue & 0x000000FF) / 255.0
        )
    }
}
