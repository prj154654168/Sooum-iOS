//
//  WriteCardSelectImageView+Rx.swift
//  SOOUM
//
//  Created by 오현식 on 10/14/25.
//

import RxSwift

extension Reactive where Base: WriteCardSelectImageView {

    var setModels: Binder<(DefaultImages, EntranceCardType)> {
        return Binder(self.base) { imgaeView, tuple in
            imgaeView.setModels(tuple.0, cardType: tuple.1)
        }
    }
}
