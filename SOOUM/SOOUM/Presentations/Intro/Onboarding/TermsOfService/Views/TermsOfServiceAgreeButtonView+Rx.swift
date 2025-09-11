//
//  TermsOfServiceAgreeButtonView+Rx.swift
//  SOOUM
//
//  Created by 오현식 on 9/11/25.
//

import RxCocoa
import RxSwift


extension Reactive where Base: TermsOfServiceAgreeButtonView {
    
    var didSelect: ControlEvent<Void> {
        self.base.backgroundButton.rx.tap
    }
}
