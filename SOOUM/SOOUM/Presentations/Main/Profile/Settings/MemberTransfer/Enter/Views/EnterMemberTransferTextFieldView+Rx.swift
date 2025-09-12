//
//  EnterMemberTransferTextFieldView+Rx.swift
//  SOOUM
//
//  Created by 오현식 on 9/12/25.
//

import UIKit

import RxCocoa
import RxSwift


extension Reactive where Base: EnterMemberTransferTextFieldView {
    
    var text: ControlProperty<String?> {
        self.base.textField.rx.text
    }
}
