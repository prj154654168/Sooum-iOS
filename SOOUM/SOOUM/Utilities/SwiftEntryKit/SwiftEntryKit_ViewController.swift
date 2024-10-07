//
//  SwiftEntryKit_ViewController.swift
//  SOOUM
//
//  Created by 오현식 on 10/1/24.
//

import UIKit

import SwiftEntryKit


protocol SwiftEntryKitViewControllerExtension: SwiftEntryKitExtension {
    var afterViewController: () -> UIViewController? { get }
}

protocol SwiftEntryKitViewControllerBridge {
    associatedtype Base
    var sek: SwiftEntryKitViewControllerWrapper<Base> { get }
}

struct SwiftEntryKitViewControllerWrapper<Base>: SwiftEntryKitViewControllerExtension {

    var afterViewController: () -> UIViewController?
    var entryName: String?

    init(closure: @escaping () -> UIViewController?) {
        self.afterViewController = closure
    }
}

extension SwiftEntryKitViewControllerExtension {

    func show(with attributes: EKAttributes) {
        guard let viewController = self.afterViewController() else { return }
        var attributes: EKAttributes = attributes
        attributes.name = self.entryName
        DispatchQueue.main.async {
            SwiftEntryKit.display(entry: viewController, using: attributes)
        }
    }
}

extension UIViewController: SwiftEntryKitViewControllerBridge {

    var sek: SwiftEntryKitViewControllerWrapper<UIViewController> {
        return .init { [weak self] in self }
    }
}

extension SwiftEntryKitViewControllerWrapper where Base == UIViewController {

    func showBottomNote(
        screenColor: UIColor?,
        screenInteraction: EKAttributes.UserInteraction,
        useSafeArea: Bool = false,
        workAtWillAppear: (() -> Void)? = nil,
        isHandleBar: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        var attributes: EKAttributes = .bottomNote
        
        if useSafeArea {
            attributes.positionConstraints.safeArea = .overridden
        }

        if let screenColor: UIColor = screenColor {
            attributes.screenBackground = .color(color: .init(screenColor))
        } else {
            attributes.screenBackground = .clear
        }
        
        if isHandleBar {
            attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        }

        attributes.displayDuration = .infinity
        attributes.entryBackground = .color(color: .init(.som.white))
        attributes.roundCorners = .top(radius: 20)
        attributes.entranceAnimation = .init(translate: .init(duration: 0.25))
        attributes.exitAnimation = .init(translate: .init(duration: 0.25))
        attributes.screenInteraction = screenInteraction
        attributes.lifecycleEvents.willAppear = workAtWillAppear
        attributes.lifecycleEvents.willDisappear = completion

        self.show(with: attributes)
    }
}
