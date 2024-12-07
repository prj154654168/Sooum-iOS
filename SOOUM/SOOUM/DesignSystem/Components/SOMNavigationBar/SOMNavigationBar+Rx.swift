//
//  SOMNavigationBar+Rx.swift
//  SOOUM
//
//  Created by 오현식 on 12/7/24.
//

import RxCocoa
import RxSwift

extension Reactive where Base: SOMNavigationBar{

    var title: Binder<String?> {
        return Binder(self.base) { navigationBar, title in
            navigationBar.title = title
        }
    }
}
