//
//  BlockUserUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 12/2/25.
//

import RxSwift

protocol BlockUserUseCase: AnyObject {
    
    func updateBlocked(userId: String, isBlocked: Bool) -> Observable<Bool>
}
