//
//  ValidateUserUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 12/2/25.
//

import RxSwift

protocol ValidateUserUseCase: AnyObject {
    
    func checkValidation() -> Observable<CheckAvailable>
    func iswithdrawn() -> Observable<RejoinableDateInfo>
    func postingPermission() -> Observable<PostingPermission>
}
