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
        static var kUILabelTypography: String = "kUILabelTypography"
        static var kUILabelTextObserver: String = "kUILabelTextObserver"
        
        static func setObjctForTypo(_ typography: Typography) {
            withUnsafePointer(to: Self.kUILabelTypography) {
                objc_setAssociatedObject(self, $0, typography, .OBJC_ASSOCIATION_RETAIN)
            }
        }
        static func getObjectForTypo() -> Typography? {
            withUnsafePointer(to: Self.kUILabelTypography) {
                objc_getAssociatedObject(self, $0) as? Typography
            }
        }
        
        static func setObjectForObserver(_ textObserver: TextObserver?) {
            withUnsafePointer(to: Self.kUILabelTextObserver) {
                objc_setAssociatedObject(self, $0, textObserver, .OBJC_ASSOCIATION_RETAIN)
            }
        }
        static func getObjectForObserver() -> TextObserver? {
            withUnsafePointer(to: Self.kUILabelTextObserver) {
                objc_getAssociatedObject(self, $0) as? TextObserver
            }
        }
    }

    func setTypography(
        _ typography: Typography,
        with closure: ((NSMutableAttributedString) -> Void)? = nil
    ) {
        
        Keys.setObjctForTypo(typography)

        self.font = typography.font

        let updateClosure: (String?) -> Void = { [weak self] text in
            if let text: String = text {
                let attributedString = NSMutableAttributedString(
                    string: text,
                    attributes: typography.attributes
                )
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
            return Keys.getObjectForTypo()
        }
    }
}

/// https://github.com/Geri-Borbas/iOS.Blog.UILabel_Typography_Extensions
extension UILabel {

    typealias TextObserver = Observer<UILabel, String?>
    typealias TextChangeAction = (_ oldValue: String?, _ newValue: String?) -> Void
    
    fileprivate var observer: TextObserver? {
        get {
            Keys.getObjectForObserver()
        }
        set {
            Keys.setObjectForObserver(newValue)
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
