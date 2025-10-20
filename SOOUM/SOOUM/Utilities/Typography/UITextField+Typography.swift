//
//  UITextField+Typography.swift
//  SOOUM
//
//  Created by 오현식 on 10/20/24.
//

import UIKit

extension UITextField {
    
    fileprivate struct Keys {
        static var UITextFieldTypography: String = "UITextFieldTypography"
        static var kUITextFieldConstraint: String = "kUITextFieldConstraint"
        
        static func setObjctForTypo(_ typography: Typography) {
            withUnsafePointer(to: Self.UITextFieldTypography) {
                objc_setAssociatedObject(self, $0, typography, .OBJC_ASSOCIATION_RETAIN)
            }
        }
        static func getObjectForTypo() -> Typography? {
            withUnsafePointer(to: Self.UITextFieldTypography) {
                objc_getAssociatedObject(self, $0) as? Typography
            }
        }
        
        static func setObjectForConstraint(_ constraint: NSLayoutConstraint?) {
            withUnsafePointer(to: Self.kUITextFieldConstraint) {
                objc_setAssociatedObject(self, $0, constraint, .OBJC_ASSOCIATION_RETAIN)
            }
        }
        
        static func getObjectForConstraint() -> NSLayoutConstraint? {
            withUnsafePointer(to: Self.kUITextFieldConstraint) {
                objc_getAssociatedObject(self, $0) as? NSLayoutConstraint
            }
        }
    }

    func setTypography(
        _ typography: Typography,
        with closure: ((inout [NSAttributedString.Key: Any]) -> Void)? = nil
    ) {

        Keys.setObjctForTypo(typography)

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
            return Keys.getObjectForTypo()
        }
    }
}

extension UITextField {

    static var kUITextFieldConstraint: String = "kUITextFieldConstraint"

    fileprivate var constraint: NSLayoutConstraint? {
        get {
            return Keys.getObjectForConstraint()
        }
        set {
            Keys.setObjectForConstraint(newValue)
        }
    }
}
