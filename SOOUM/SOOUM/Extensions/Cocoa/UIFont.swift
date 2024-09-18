//
//  UIFont.swift
//  SOOUM
//
//  Created by 오현식 on 9/10/24.
//

import UIKit


extension UIFont {

    func size(_ value: CGFloat) -> UIFont {
        return self.withSize(value)
    }

    static func size(_ value: CGFloat) -> UIFont {
        return .systemFont(ofSize: value)
    }

    private static func weight(_ value: UIFont.Weight) -> UIFont {
        return .systemFont(ofSize: UIFont.systemFontSize, weight: value)
    }

    /// ========================================================================

    static var ultraLight: UIFont { .weight(.ultraLight) }
    static var thin: UIFont { .weight(.thin) }
    static var light: UIFont { .weight(.light) }
    static var regular: UIFont { .weight(.regular) }
    static var medium: UIFont { .weight(.medium) }
    static var semibold: UIFont { .weight(.semibold) }
    static var bold: UIFont { .weight(.bold) }
    static var heavy: UIFont { .weight(.heavy) }
    static var black: UIFont { .weight(.black) }

    static subscript(size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size)
    }

    subscript(size: CGFloat) -> UIFont {
        return self.withSize(size)
    }
}
