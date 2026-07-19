//
//  HapticHelper.swift
//  SOOUM
//
//  Created by 오현식 on 3/11/26.
//

import UIKit

final class HapticHelper {
    
    static let shared = HapticHelper()
    
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let impactGenerators: [UIImpactFeedbackGenerator.FeedbackStyle: UIImpactFeedbackGenerator]
    
    private init() {
        let styles: [UIImpactFeedbackGenerator.FeedbackStyle] = [.light, .medium, .heavy, .soft, .rigid]
        var generators: [UIImpactFeedbackGenerator.FeedbackStyle: UIImpactFeedbackGenerator] = [:]
        
        styles.forEach { style in
            generators[style] = UIImpactFeedbackGenerator(style: style)
        }
        
        self.impactGenerators = generators
        
        self.notificationGenerator.prepare()
        self.selectionGenerator.prepare()
        self.impactGenerators.values.forEach { $0.prepare() }
    }

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
            switch type {
            case .success: self.notificationGenerator.notificationOccurred(.success)
            case .warning: self.notificationGenerator.notificationOccurred(.warning)
            case .error:   self.notificationGenerator.notificationOccurred(.error)
            default: break
            }
            
            self.notificationGenerator.prepare()
            
        case .light, .medium, .heavy, .soft, .rigid:
            guard let generator = self.impactGenerator(for: type) else { return }
            
            generator.impactOccurred()
            generator.prepare()
            
        case .selection:
            self.selectionGenerator.selectionChanged()
            self.selectionGenerator.prepare()
        }
    }
    
    private func impactGenerator(for type: HapticType) -> UIImpactFeedbackGenerator? {
        let style: UIImpactFeedbackGenerator.FeedbackStyle
        
        switch type {
        case .light:  style = .light
        case .medium: style = .medium
        case .heavy:  style = .heavy
        case .soft:   style = .soft
        case .rigid:  style = .rigid
        default:
            return nil
            }
        
        return self.impactGenerators[style]
    }
}
