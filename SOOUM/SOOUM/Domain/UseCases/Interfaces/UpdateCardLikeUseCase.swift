//
//  UpdateCardLikeUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 12/2/25.
//

import RxSwift

protocol UpdateCardLikeUseCase: AnyObject {
    
    func updateLike(cardId: String, isLike: Bool) -> Observable<Bool>
}
