//
//  WithdrawType.swift
//  SOOUM
//
//  Created by 오현식 on 11/9/25.
//

import Foundation

enum WithdrawType: CaseIterable {
    case donotUseOfften
    case missingFeature
    case frequentErrors
    case notEasyToUse
    case createNewAccount
    case other
    
    var identifier: Int {
        switch self {
        case .donotUseOfften:
            return 0
        case .missingFeature:
            return 1
        case .frequentErrors:
            return 2
        case .notEasyToUse:
            return 3
        case .createNewAccount:
            return 4
        case .other:
            return 5
        }
    }
    
    var message: String {
        switch self {
        case .donotUseOfften:
            return "자주 사용하지 않아요"
        case .missingFeature:
            return "원하는 기능이 없어요"
        case .frequentErrors:
            return "오류가 잦아서 사용하기 어려워요"
        case .notEasyToUse:
            return "앱 사용법을 모르겠어요"
        case .createNewAccount:
            return "새로운 계정을 만들고 싶어요"
        case .other:
            return "기타"
        }
    }
}
