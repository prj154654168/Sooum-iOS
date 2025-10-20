//
//  WriteCardTags+Rx.swift
//  SOOUM
//
//  Created by 오현식 on 10/15/25.
//

import RxSwift

extension Reactive where Base: WriteCardTags {

    func models<T: WriteCardTagModel>() -> Binder<[T]> {
        return Binder(self.base) { tags, models in
            tags.setModels(models)
        }
    }
}
