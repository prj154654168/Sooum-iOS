//
//  UpdateTagFavoriteUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 12/2/25.
//

import RxSwift

protocol UpdateTagFavoriteUseCase: AnyObject {
    
    func updateFavorite(tagId: String, isFavorite: Bool) -> Observable<Bool>
}
