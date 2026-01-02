//
//  SearchTextFieldView+Rx.swift
//  SOOUM
//
//  Created by 오현식 on 1/2/26.
//

import RxCocoa
import RxSwift

extension Reactive where Base: SearchTextFieldView {
    
    var text: ControlProperty<String?> {
        self.base.textField.rx.text
    }
}
