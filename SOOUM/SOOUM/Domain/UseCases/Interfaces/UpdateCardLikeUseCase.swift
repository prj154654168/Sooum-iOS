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

protocol UpdatePollVoteUseCase: AnyObject {
    
    func vote(pollOptionId: String) -> Observable<DetailCardInfo.Poll>
    func unvote(pollOptionId: String, currentPoll: DetailCardInfo.Poll) -> Observable<DetailCardInfo.Poll>
}
