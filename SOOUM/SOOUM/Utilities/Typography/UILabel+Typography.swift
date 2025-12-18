//
//  UILabel+Typograpy.swift
//  SOOUM
//
//  Created by 오현식 on 9/9/24.
//

import UIKit


/// https://github.com/Geri-Borbas/iOS.Blog.UILabel_Typography_Extensions
extension UILabel {
    
    private static var kUILabelTypography: UInt8 = 0
    private static var kUILabelTextObserver: UInt8 = 0

    func setTypography(
        _ typography: Typography,
        with closure: ((NSMutableAttributedString) -> Void)? = nil
    ) {
        
        objc_setAssociatedObject(self, &Self.kUILabelTypography, typography, .OBJC_ASSOCIATION_RETAIN)

        self.font = typography.font

        let updateClosure: (String?) -> Void = { [weak self] text in
            if let self = self, let text: String = text {
                let alignment = typography.alignment
                let lineBreakMode = self.lineBreakMode
                let lineBreakStrategy = self.lineBreakStrategy
                
                let attributedString = NSMutableAttributedString(
                    string: text,
                    attributes: typography.attributes
                )
                closure?(attributedString)
                self.attributedText = attributedString
                
                self.textAlignment = alignment
                self.lineBreakMode = lineBreakMode
                self.lineBreakStrategy = lineBreakStrategy
            }
        }

        updateClosure(self.text)

        self.onTextChange { _, newText in
            updateClosure(newText)
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
            return objc_getAssociatedObject(self, &Self.kUILabelTypography) as? Typography
        }
    }
}

/// https://github.com/Geri-Borbas/iOS.Blog.UILabel_Typography_Extensions
extension UILabel {

    typealias TextObserver = Observer<UILabel, String?>
    typealias TextChangeAction = (_ oldValue: String?, _ newValue: String?) -> Void
    
    fileprivate var observer: TextObserver? {
        set {
            objc_setAssociatedObject(self, &Self.kUILabelTextObserver, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &Self.kUILabelTextObserver) as? TextObserver
        }
    }
    
    func onTextChange(_ completion: @escaping TextChangeAction) {
        guard observer == nil else {
            return
        }
        
        observer = TextObserver(
            for: self,
            keyPath: \.text,
            onChange: { oldText, newText in
                completion(oldText ?? nil, newText ?? nil)
            }
        )
    }
}
