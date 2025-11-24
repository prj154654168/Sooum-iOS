//
//  RxSwift+Unretained.swift
//  SOOUM
//
//  Created by 오현식 on 11/23/25.
//

import RxSwift

extension ObservableType {
    
    // `do`와 `onNext`만을 사용할 경우
    func `do`<Object: AnyObject>(
        with object: Object,
        onNext: @escaping (((object: Object, element: Element)) throws -> Void)
    ) -> Observable<Element> {
        `do`(
            onNext: { [weak object] in
                guard let object = object else { return }
                try onNext((object, $0))
            }
        )
    }
}
