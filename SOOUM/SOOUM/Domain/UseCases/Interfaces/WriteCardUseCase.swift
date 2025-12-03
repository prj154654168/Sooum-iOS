//
//  WriteCardUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 12/2/25.
//

import RxSwift

protocol WriteCardUseCase: AnyObject {
    
    func writeFeed(
        isDistanceShared: Bool,
        latitude: String?,
        longitude: String?,
        content: String,
        font: String,
        imgType: String,
        imgName: String,
        isStory: Bool,
        tags: [String]
    ) -> Observable<String>
    func writeComment(
        parentCardId: String,
        isDistanceShared: Bool,
        latitude: String?,
        longitude: String?,
        content: String,
        font: String,
        imgType: String,
        imgName: String,
        tags: [String]
    ) -> Observable<String>
}
