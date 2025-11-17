//
//  SettingTextCellView+Rx.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import RxCocoa
import RxSwift

extension Reactive where Base: SettingTextCellView {
    
    var isOn: ControlProperty<Bool> {
        self.base.toggleSwitch.rx.isOn
    }
    
    var didSelect: ControlEvent<Void> {
        self.base.backgroundButton.rx.tap
    }
}
