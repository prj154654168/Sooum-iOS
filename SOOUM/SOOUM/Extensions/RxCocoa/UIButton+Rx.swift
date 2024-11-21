//
//  UIButton+Rx.swift
//  SOOUM
//
//  Created by 오현식 on 11/21/24.
//

import UIKit

import RxCocoa
import RxSwift


extension Reactive where Base: UIButton {

    var throttleTap: Observable<Void> {
        return throttleTap()
    }

    func throttleTap(_ dueTime: RxSwift.RxTimeInterval = .seconds(1)) -> Observable<Void> {
        return controlEvent(.touchUpInside)
            .throttle(dueTime, scheduler: MainScheduler.instance)
    }
}
