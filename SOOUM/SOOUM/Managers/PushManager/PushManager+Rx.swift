//
//  PushManager+Rx.swift
//  SOOUM
//
//  Created by 오현식 on 12/12/24.
//

import RxSwift


extension PushManagerDelegate {

    func switchNotification(on: Bool) -> Observable<Error?> {
        return .create { observer in
            self.switchNotification(isOn: on) { error in
                if let error: Error = error {
                    observer.onNext(error)
                } else {
                    observer.onNext(nil)
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
