//
//  UILabel+Observer.swift
//  SOOUM
//
//  Created by 오현식 on 9/9/24.
//

import UIKit


class Observer<ObjectType: NSObject, ValueType>: NSObject {
    
    typealias ChangeAction = (_ oldValue: ValueType?, _ newValue: ValueType?) -> Void
    let onChange: ChangeAction
    private var observer: NSKeyValueObservation?
    
    init(
        for object: ObjectType,
        keyPath: KeyPath<ObjectType, ValueType>,
        onChange: @escaping ChangeAction
    ) {
        self.onChange = onChange
        super.init()
        observe(object, keyPath: keyPath)
    }
    
    func observe(_ object: ObjectType, keyPath: KeyPath<ObjectType, ValueType>) {
        observer = object.observe(
            keyPath,
            options: [.new, .old],
            changeHandler: { [weak self] _, change in
                self?.onChange(change.oldValue, change.newValue)
            }
        )
    }
    
    deinit {
        observer?.invalidate()
    }
}
