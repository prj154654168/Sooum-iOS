//
//  WriteCardSelectImageView+Rx.swift
//  SOOUM
//
//  Created by 오현식 on 10/14/25.
//

import RxSwift

extension Reactive where Base: WriteCardSelectImageView {

    var setModels: Binder<DefaultImages> {
        return Binder(self.base) { imgaeView, models in
            imgaeView.setModels(models)
        }
    }
}
