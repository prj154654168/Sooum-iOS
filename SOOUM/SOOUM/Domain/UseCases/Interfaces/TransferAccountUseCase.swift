//
//  TransferAccountUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 12/2/25.
//

import RxSwift

protocol TransferAccountUseCase: AnyObject {
    
    func issue() -> Observable<TransferCodeInfo>
    func enter(code: String, encryptedDeviceId: String) -> Observable<Bool>
}
