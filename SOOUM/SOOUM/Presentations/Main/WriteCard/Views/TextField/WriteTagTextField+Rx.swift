//
//  WriteTagTextField+Rx.swift
//  SOOUM
//
//  Created by 오현식 on 10/21/24.
//

import UIKit

import RxCocoa
import RxSwift


extension Reactive where Base: WriteTagTextField {
    
    var text: ControlProperty<String?> {
        self.base.textField.rx.text
    }
}
