//
//  UITextField+Typography.swift
//  SOOUM
//
//  Created by 오현식 on 10/20/24.
//

import UIKit

extension UITextField {
    
    private static var KUITextFieldTypography: UInt8 = 0
    private static var kUITextFieldConstraint: UInt8 = 0

    func setTypography(
        _ typography: Typography,
        with closure: ((inout [NSAttributedString.Key: Any]) -> Void)? = nil
    ) {

        objc_setAssociatedObject(self, &Self.KUITextFieldTypography, typography, .OBJC_ASSOCIATION_RETAIN)

        if let constraint = self.constraint {
            constraint.constant = typography.lineHeight
        } else {
            self.translatesAutoresizingMaskIntoConstraints = false
            let heightConstraint = self.heightAnchor.constraint(equalToConstant: typography.lineHeight)
            heightConstraint.priority = .required
            heightConstraint.isActive = true
            self.constraint = heightConstraint
        }

        var attributes: [NSAttributedString.Key: Any] = typography.attributes
        attributes.removeValue(forKey: .paragraphStyle)
        attributes[.font] = typography.font
        attributes[.foregroundColor] = self.textColor
        closure?(&attributes)
        self.defaultTextAttributes = attributes
    }

    /// When self.text == nil, must set typography when input text
    var typography: Typography? {
        set {
            if let typography: Typography = newValue {
                self.setTypography(typography)
            }
        }
        get {
            return objc_getAssociatedObject(self, &Self.KUITextFieldTypography) as? Typography
        }
    }
    
    private var constraint: NSLayoutConstraint? {
        set {
            objc_setAssociatedObject(self, &Self.kUITextFieldConstraint, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &Self.kUITextFieldConstraint) as? NSLayoutConstraint
        }
    }
}
