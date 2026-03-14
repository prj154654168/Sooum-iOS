//
//  PushNotiSettingsCellView+Rx.swift
//  SOOUM
//
//  Created by 오현식 on 3/7/26.
//

import RxCocoa
import RxSwift

extension Reactive where Base: PushNotiSettingsCellView {
    
    var didSelect: ControlEvent<Void> {
        self.base.toggleBackgroundButton.rx.tap
    }
}
