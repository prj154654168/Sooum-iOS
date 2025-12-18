//
//  ReortType.swift
//  SOOUM
//
//  Created by 오현식 on 11/2/25.
//

import Foundation

enum ReportType: String, CaseIterable {
    case defamationAndAbuse = "DEFAMATION_AND_ABUSE"
    case privacyViolation = "PRIVACY_VIOLATION"
    case inappropriateAdvertising = "INAPPROPRIATE_ADVERTISING"
    case pornography = "PORNOGRAPHY"
    case impersonationAndFraud = "IMPERSONATION_AND_FRAUD"
    case other = "OTHER"
    
    var identifier: Int {
        switch self {
        case .defamationAndAbuse:
            return 0
        case .privacyViolation:
            return 1
        case .inappropriateAdvertising:
            return 2
        case .pornography:
            return 3
        case .impersonationAndFraud:
            return 4
        case .other:
            return 5
        }
    }
    
    var message: String {
        switch self {
        case .defamationAndAbuse:
            return "폭언, 비속어, 혐오 발언"
        case .privacyViolation:
            return "개인정보 침해"
        case .inappropriateAdvertising:
            return "부적절한 홍보 및 바이럴"
        case .pornography:
            return "나체 이미지 또는 성적 행위"
        case .impersonationAndFraud:
            return "스팸, 사기 또는 스팸"
        case .other:
            return "기타"
        }
    }
}
