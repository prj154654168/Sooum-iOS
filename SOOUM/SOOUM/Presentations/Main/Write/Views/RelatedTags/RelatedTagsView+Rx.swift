//
//  RelatedTagsView+Rx.swift
//  SOOUM
//
//  Created by 오현식 on 10/16/25.
//

import RxSwift

extension Reactive where Base: RelatedTagsView {

    func models<T: RelatedTagViewModel>() -> Binder<[T]> {
        return Binder(self.base) { tags, models in
            tags.setModels(models)
        }
    }
}
