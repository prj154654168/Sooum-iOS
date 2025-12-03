//
//  DeleteCardUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 12/2/25.
//

import RxSwift

protocol DeleteCardUseCase: AnyObject {
    
    func delete(cardId: String) -> Observable<Bool>
}
