//
//  SettingVersionCellView+Rx.swift
//  SOOUM
//
//  Created by 오현식 on 11/9/25.
//

import RxCocoa
import RxSwift

extension Reactive where Base: SettingVersionCellView {
    
    var didSelect: ControlEvent<Void> {
        self.base.backgroundButton.rx.tap
    }
}
