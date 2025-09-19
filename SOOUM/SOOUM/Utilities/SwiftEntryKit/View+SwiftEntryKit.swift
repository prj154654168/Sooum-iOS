//
//  View+SwiftEntryKit.swift
//  SOOUM
//
//  Created by 오현식 on 9/12/25.
//

import UIKit

import SwiftEntryKit

protocol SwiftEntryKitViewExtension: SwiftEntryKitExtension {
    var afterView: () -> UIView? { get }
}

protocol SwiftEntryKitViewBridge {
    associatedtype Base
    var sek: SwiftEntryKitViewWrapper<Base> { get }
}

struct SwiftEntryKitViewWrapper<Base>: SwiftEntryKitViewExtension {

    var afterView: () -> UIView?
    var entryName: String?

    init(closure: @escaping () -> UIView?) {
        self.afterView = closure
    }
}

extension SwiftEntryKitViewExtension {

    func show(with attributes: EKAttributes) {
        guard let view = self.afterView() else { return }
        var attributes: EKAttributes = attributes
        attributes.name = self.entryName
        DispatchQueue.main.async {
            SwiftEntryKit.display(entry: view, using: attributes)
        }
    }
}

extension UIView: SwiftEntryKitViewBridge {

    var sek: SwiftEntryKitViewWrapper<UIView> {
        return .init { [weak self] in self }
    }
}

extension SwiftEntryKitViewWrapper where Base == UIView {

    func showBottomFloat(
        screenColor: UIColor? = .som.v2.dim,
        screenInteraction: EKAttributes.UserInteraction,
        useSafeArea: Bool = true,
        hasHandleBar: Bool = true,
        workAtWillAppear: (() -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) {
        var attributes: EKAttributes = .bottomFloat
        
        if useSafeArea {
            attributes.positionConstraints.safeArea = .overridden
        }

        if let screenColor: UIColor = screenColor {
            attributes.screenBackground = .color(color: .init(screenColor))
        } else {
            attributes.screenBackground = .clear
        }
        
        if hasHandleBar {
            attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        }

        attributes.roundCorners = .all(radius: 20)
        attributes.positionConstraints.verticalOffset = 34
        
        attributes.entryBackground = .color(color: .init(.som.v2.white))
        
        attributes.displayDuration = .infinity
        attributes.entranceAnimation = .init(translate: .init(duration: 0.25))
        attributes.exitAnimation = .init(translate: .init(duration: 0.25))
        
        attributes.entryInteraction = .forward
        attributes.screenInteraction = screenInteraction
        
        attributes.lifecycleEvents.willAppear = workAtWillAppear
        attributes.lifecycleEvents.willDisappear = completion

        self.show(with: attributes)
    }
}
