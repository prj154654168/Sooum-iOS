//
//  SwiftEntryKit_Show.swift
//  SOOUM
//
//  Created by 오현식 on 10/1/24.
//

import UIKit

import SwiftEntryKit


extension SwiftEntryKitExtension {
    
    func showBottomSheet() {
        
        var attributes: EKAttributes = .bottomToast

        attributes.entryBackground = .color(color: .init(.white))
        attributes.entryInteraction = .forward

        attributes.screenBackground = .color(color: .init(UIColor.black.withAlphaComponent(0.7)))
        attributes.screenInteraction = .dismiss

        attributes.displayDuration = .infinity

        let translateAnimation = EKAttributes.Animation.Translate(
            duration: 0.65,
            spring: .init(damping: 1, initialVelocity: 0)
        )
        attributes.entranceAnimation = .init(translate: translateAnimation)
        attributes.exitAnimation = .init(translate: translateAnimation)

        attributes.popBehavior = .animated(animation: .init(translate: translateAnimation))

        attributes.positionConstraints.keyboardRelation = .bind(
            offset: .init(bottom: 0, screenEdgeResistance: 0)
        )
        attributes.positionConstraints.maxSize = .init(
            width: .constant(value: UIScreen.main.bounds.size.width),
            height: .intrinsic
        )
        attributes.positionConstraints.safeArea = .empty(fillSafeArea: true)

        attributes.roundCorners = .top(radius: 20)

        self.show(with: attributes)
    }
}
