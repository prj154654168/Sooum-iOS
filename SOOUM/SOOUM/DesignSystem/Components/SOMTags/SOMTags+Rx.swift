//
//  SOMTags+Rx.swift
//  SOOUM
//
//  Created by 오현식 on 10/1/24.
//

import RxSwift

extension Reactive where Base: SOMTags {

    func datas<T: SOMTagModel>() -> Binder<[T]> {
        return Binder(self.base) { tags, datas in
            tags.setDatas(datas)
        }
    }
}
