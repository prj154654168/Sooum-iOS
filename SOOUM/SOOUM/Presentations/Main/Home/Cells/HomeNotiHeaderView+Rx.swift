//
//  HomeNotiHeaderView+Rx.swift
//  SOOUM
//
//  Created by 오현식 on 1/31/26.
//

import UIKit

import RxSwift

extension Reactive where Base: HomeNotiHeaderView {

    var deleteButtonDidTapped: Observable<Void> {
        self.base.deleteButton.rx.throttleTap(.seconds(3))
    }
}
