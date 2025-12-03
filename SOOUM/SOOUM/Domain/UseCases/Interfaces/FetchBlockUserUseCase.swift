//
//  FetchBlockUserUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 12/2/25.
//

import RxSwift

protocol FetchBlockUserUseCase: AnyObject {
    
    func blockUsers(lastId: String?) -> Observable<[BlockUserInfo]>
}
