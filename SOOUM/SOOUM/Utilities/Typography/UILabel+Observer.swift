//
//  UILabel+Observer.swift
//  SOOUM
//
//  Created by 오현식 on 9/9/24.
//

import UIKit


/// https://github.com/Geri-Borbas/iOS.Blog.UILabel_Typography_Extensions
extension UILabel {
    
    fileprivate struct Keys {
        static var observer: UInt8 = .zero
    }
    
    typealias TextObserver = Observer<UILabel, String?>
    typealias TextChangeAction = (_ oldValue: String?, _ newValue: String?) -> Void
    
    fileprivate var observer: TextObserver? {
        get {
            objc_getAssociatedObject(self, &Keys.observer) as? TextObserver
        }
        set {
            objc_setAssociatedObject(self, &Keys.observer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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


class Observer<ObjectType: NSObject, ValueType>: NSObject {
    
    typealias ChangeAction = (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void
    let onChange: ChangeAction
    private var observer: NSKeyValueObservation?
    
    init(for object: ObjectType, keyPath: KeyPath<ObjectType, ValueType>, onChange: @escaping ChangeAction) {
        self.onChange = onChange
        super.init()
        observe(object, keyPath: keyPath)
    }
    
    func observe(_ object: ObjectType, keyPath: KeyPath<ObjectType, ValueType>) {
        observer = object.observe(
            keyPath,
            options:  [.new, .old],
            changeHandler: { [weak self] _, change in
                self?.onChange(change.oldValue, change.newValue)
            }
        )
    }
    
    deinit {
        observer?.invalidate()
    }
}
