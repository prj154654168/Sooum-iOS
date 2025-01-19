//
//  TermsOfServiceCellView+Rx.swift
//  SOOUM
//
//  Created by 오현식 on 1/18/25.
//

import RxCocoa
import RxSwift


extension Reactive where Base: TermsOfServiceCellView {
    
    var didSelect: ControlEvent<Void> {
        self.base.backgroundButton.rx.tap
    }
    
    var nextSelect: ControlEvent<Void> {
        self.base.nextButton.rx.tap
    }
}
