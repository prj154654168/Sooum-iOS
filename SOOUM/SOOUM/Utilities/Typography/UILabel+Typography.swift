//
//  UILabel+Typograpy.swift
//  SOOUM
//
//  Created by 오현식 on 9/9/24.
//

import UIKit


/// https://github.com/Geri-Borbas/iOS.Blog.UILabel_Typography_Extensions
extension UILabel {

    fileprivate struct Keys {
        static var typography: UInt8 = .zero
    }

    func setTypography(_ typography: Typography, with closure: ((NSMutableAttributedString) -> Void)? = nil) {

        objc_setAssociatedObject(self, &Keys.typography, typography, .OBJC_ASSOCIATION_RETAIN)

        self.font = typography.font

        let updateClosure: (String?) -> Void = { [weak self] text in
            if let text: String = text {
                let attributedString = NSMutableAttributedString(string: text, attributes: typography.attributes)
                closure?(attributedString)
                self?.attributedText = attributedString
            }
        }

        updateClosure(self.text)

        self.onTextChange { [weak self] oldText, newText in
            let lessThaniOS14: () -> Void = {
                let alignment = self?.textAlignment ?? .left
                let lineBreakMode = self?.lineBreakMode ?? .byTruncatingTail
                updateClosure(newText)
                self?.textAlignment = alignment
                self?.lineBreakMode = lineBreakMode
            }
            if #available(iOS 14.0, *) {
                let lineBreakStrategy = self?.lineBreakStrategy ?? .pushOut
                lessThaniOS14()
                self?.lineBreakStrategy = lineBreakStrategy
            } else {
                lessThaniOS14()
            }
        }
    }

    var typography: Typography? {
        set {
            if let typography: Typography = newValue {
                self.setTypography(typography)
            }
        }
        get {
            return objc_getAssociatedObject(self, &Keys.typography) as? Typography
        }
    }
}
