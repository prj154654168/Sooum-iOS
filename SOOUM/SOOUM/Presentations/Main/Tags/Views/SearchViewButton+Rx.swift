//
//  SearchViewButton+Rx.swift
//  SOOUM
//
//  Created by 오현식 on 11/19/25.
//

import UIKit

import RxCocoa
import RxSwift

extension Reactive where Base: SearchViewButton {
    
    var didTap: Observable<Void> {
        self.base.backgroundButton.rx.throttleTap
    }
}
