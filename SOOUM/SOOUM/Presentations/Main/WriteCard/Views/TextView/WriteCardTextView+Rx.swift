//
//  WriteCardTextView+Rx.swift
//  SOOUM
//
//  Created by 오현식 on 11/1/24.
//

import UIKit

import RxCocoa
import RxSwift


extension Reactive where Base: WriteCardTextView {
    
    var text: ControlProperty<String?> {
        self.base.textView.rx.text
    }
}
