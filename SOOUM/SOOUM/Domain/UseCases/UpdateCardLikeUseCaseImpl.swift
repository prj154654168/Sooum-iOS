//
//  UpdateCardLikeUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class UpdateCardLikeUseCaseImpl: UpdateCardLikeUseCase {
    
    private let repository: CardRepository
    
    init(repository: CardRepository) {
        self.repository = repository
    }
    
    func updateLike(cardId: String, isLike: Bool) -> Observable<Bool> {
        
        return self.repository.updateLike(id: cardId, isLike: isLike).map { $0 == 200 }
    }
}

final class UpdatePollVoteUseCaseImpl: UpdatePollVoteUseCase {
    
    private let repository: CardRepository
    
    init(repository: CardRepository) {
        self.repository = repository
    }
    
    func vote(pollOptionId: String) -> Observable<DetailCardInfo.Poll> {
        
        return self.repository.votePollOption(id: pollOptionId)
    }
    
    func unvote(
        pollOptionId: String,
        currentPoll: DetailCardInfo.Poll
    ) -> Observable<DetailCardInfo.Poll> {
        
        return self.repository.unvotePollOption(id: pollOptionId)
            .filter { $0 }
            .map { _ in currentPoll.removingVote(optionId: pollOptionId) }
    }
}
