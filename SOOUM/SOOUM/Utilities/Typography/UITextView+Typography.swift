//
//  UITextView+Typography.swift
//  SOOUM
//
//  Created by 오현식 on 10/18/24.
//

import UIKit


extension UITextView {

    fileprivate struct Keys {
        static var kUITextViewTypography: String = "kUITextViewTypography"
        
        static func setObjctForTypo(_ typography: Typography) {
            withUnsafePointer(to: Self.kUITextViewTypography) {
                objc_setAssociatedObject(self, $0, typography, .OBJC_ASSOCIATION_RETAIN)
            }
        }
        static func getObjectForTypo() -> Typography? {
            withUnsafePointer(to: Self.kUITextViewTypography) {
                objc_getAssociatedObject(self, $0) as? Typography
            }
        }
    }

    func setTypography(
        _ typography: Typography,
        with closure: ((inout [NSAttributedString.Key: Any]) -> Void)? = nil
    ) {

        Keys.setObjctForTypo(typography)

        var attributes: [NSAttributedString.Key: Any] = typography.attributes
        attributes[.font] = typography.font
        closure?(&attributes)
        self.typingAttributes = attributes
    }

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
