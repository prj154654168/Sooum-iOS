//
//  HapticHelper.swift
//  SOOUM
//
//  Created by 오현식 on 3/11/26.
//

import UIKit

final class HapticHelper {
    
    static let shared = HapticHelper()
    
    private init() {}

    /// 햅틱 피드백 종류
    enum HapticType {
        /// 성공
        case success
        /// 경고
        case warning
        /// 실패
        case error
        
        /// 물리적 충격
        case light
        case medium
        case heavy
        case soft
        case rigid
        
        /// 선택 변경 (피커 돌릴 때 등)
        case selection
    }

    func trigger(_ type: HapticType) {
        switch type {
        case .success, .warning, .error:
            let generator = UINotificationFeedbackGenerator()
            /// 지연 시간 최소화를 위해 미리 준비
            generator.prepare()
            
            switch type {
            case .success: generator.notificationOccurred(.success)
            case .warning: generator.notificationOccurred(.warning)
            case .error:   generator.notificationOccurred(.error)
            default: break
            }
            
        case .light, .medium, .heavy, .soft, .rigid:
            var style: UIImpactFeedbackGenerator.FeedbackStyle
            
            switch type {
            case .light:  style = .light
            case .medium: style = .medium
            case .heavy:  style = .heavy
            case .soft:   style = .soft
            case .rigid:  style = .rigid
            default:      style = .medium
            }
            
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
            
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
}
