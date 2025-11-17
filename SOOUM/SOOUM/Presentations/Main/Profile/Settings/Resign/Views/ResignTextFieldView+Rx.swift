//
//  ResignTextFieldView+Rx.swift
//  SOOUM
//
//  Created by 오현식 on 11/9/25.
//

import UIKit

import RxCocoa
import RxSwift

extension Reactive where Base: ResignTextFieldView {
    
    var text: ControlProperty<String?> {
        self.base.textField.rx.text
    }
}
