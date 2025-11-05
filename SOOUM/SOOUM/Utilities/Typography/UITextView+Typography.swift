//
//  UITextView+Typography.swift
//  SOOUM
//
//  Created by 오현식 on 10/18/24.
//

import UIKit

extension UITextView {
    
    private static var kUITextViewTypography: UInt8 = 0

    func setTypography(
        _ typography: Typography,
        with closure: ((inout [NSAttributedString.Key: Any]) -> Void)? = nil
    ) {

        objc_setAssociatedObject(self, &Self.kUITextViewTypography, typography, .OBJC_ASSOCIATION_RETAIN)

        var attributes: [NSAttributedString.Key: Any] = typography.attributes
        attributes[.font] = typography.font
        attributes[.foregroundColor] = self.textColor
        closure?(&attributes)
        self.typingAttributes = attributes
        
        if let text = self.text, text.isEmpty == false {
            let selectedRange = self.selectedRange
            
            let attributedText = NSMutableAttributedString(string: text, attributes: attributes)
            self.attributedText = attributedText
            self.selectedRange = selectedRange
        }
    }

    /// When self.text == nil, must set typography when input text
    var typography: Typography? {
        set {
            if let typography: Typography = newValue {
                self.setTypography(typography)
            }
        }
        get {
            return objc_getAssociatedObject(self, &Self.kUITextViewTypography) as? Typography
        }
    }
}
