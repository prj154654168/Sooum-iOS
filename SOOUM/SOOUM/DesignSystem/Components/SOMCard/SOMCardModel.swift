//
//  SOMCardModel.swift
//  SOOUM
//
//  Created by 오현식 on 10/3/24.
//

import Foundation


struct SOMCardModel {
    
    /// 카드 정보
    let data: Card
    /// 스토리 펑타임
    var pungTime: Date?
    /// 현재 카드가 펑된 카드인지 확인
    var isPunged: Bool {
        guard let pungTime = self.pungTime else {
            return false
        }
        let remainingTime = pungTime.timeIntervalSince(Date())
        return remainingTime <= 0
    }
    
    init(data: Card) {
        self.data = data
        self.pungTime = data.storyExpirationTime
    }
}
