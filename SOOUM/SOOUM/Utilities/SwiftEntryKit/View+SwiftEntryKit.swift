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

struct SwiftEntryKitViewConfiguration {
    
    let entryName: String?
    let attributes: EKAttributes
    
    init(entryName: String? = nil, attributes: EKAttributes) {
        self.entryName = entryName
        self.attributes = attributes
    }
}

struct SwiftEntryKitViewWrapper<Base>: SwiftEntryKitViewExtension {

    var afterView: () -> UIView?
    var entryName: String?

    init(closure: @escaping () -> UIView?) {
        self.afterView = closure
    }
}

extension SwiftEntryKitViewExtension {
    
    func show(with configuration: SwiftEntryKitViewConfiguration) {
        self.show(
            with: configuration.attributes,
            entryName: configuration.entryName ?? self.entryName
        )
    }

    func show(with attributes: EKAttributes) {
        self.show(with: attributes, entryName: self.entryName)
    }
    
    private func show(with attributes: EKAttributes, entryName: String?) {
        guard let view = self.afterView() else { return }
        var attributes: EKAttributes = attributes
        attributes.name = entryName
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
    
    func named(_ entryName: String) -> Self {
        var wrapper = self
        wrapper.entryName = entryName
        return wrapper
    }
    
    func show(_ configuration: SwiftEntryKitViewConfiguration) {
        self.show(with: configuration)
    }

    func showBottomFloat(
        screenColor: UIColor? = .som.v2.dim,
        screenInteraction: EKAttributes.UserInteraction,
        useSafeArea: Bool = true,
        hasHandleBar: Bool = true,
        workAtWillAppear: (() -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) {
        self.show(
            .bottomFloat(
                entryName: self.entryName,
                screenColor: screenColor,
                screenInteraction: screenInteraction,
                useSafeArea: useSafeArea,
                hasHandleBar: hasHandleBar,
                workAtWillAppear: workAtWillAppear,
                completion: completion
            )
        )
    }
    
    func showBottomToast(
        verticalOffset: CGFloat,
        displayDuration: CGFloat = 7,
        useSafeArea: Bool = true,
        workAtWillAppear: (() -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) {
        self.show(
            .bottomToast(
                entryName: self.entryName,
                verticalOffset: verticalOffset,
                displayDuration: displayDuration,
                useSafeArea: useSafeArea,
                workAtWillAppear: workAtWillAppear,
                completion: completion
            )
        )
    }
    
    func showFullScreen(
        screenInteraction: EKAttributes.UserInteraction,
        workAtWillAppear: (() -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) {
        self.show(
            .fullScreen(
                entryName: self.entryName,
                screenInteraction: screenInteraction,
                workAtWillAppear: workAtWillAppear,
                completion: completion
            )
        )
    }
}

extension SwiftEntryKitViewConfiguration {
    
    static func bottomFloat(
        entryName: String? = nil,
        screenColor: UIColor? = .som.v2.dim,
        screenInteraction: EKAttributes.UserInteraction,
        useSafeArea: Bool = true,
        hasHandleBar: Bool = true,
        workAtWillAppear: (() -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) -> Self {
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
        
        return .init(entryName: entryName, attributes: attributes)
    }
    
    static func bottomToast(
        entryName: String? = nil,
        verticalOffset: CGFloat,
        displayDuration: CGFloat = 7,
        useSafeArea: Bool = true,
        workAtWillAppear: (() -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) -> Self {
        var attributes: EKAttributes = .bottomToast
        
        if useSafeArea {
            attributes.positionConstraints.safeArea = .overridden
        }

        attributes.screenBackground = .clear
        attributes.scroll = .edgeCrossingDisabled(swipeable: true)

        attributes.roundCorners = .all(radius: 6)
        attributes.positionConstraints.verticalOffset = verticalOffset
        
        attributes.entryBackground = .color(color: .init(.som.v2.gray500))
        
        attributes.displayDuration = displayDuration
        attributes.entranceAnimation = .init(translate: .init(duration: 0.25))
        attributes.exitAnimation = .init(translate: .init(duration: 0.25))
        
        attributes.entryInteraction = .forward
        
        attributes.lifecycleEvents.willAppear = workAtWillAppear
        attributes.lifecycleEvents.willDisappear = completion
        
        return .init(entryName: entryName, attributes: attributes)
    }
    
    static func fullScreen(
        entryName: String? = nil,
        screenInteraction: EKAttributes.UserInteraction,
        workAtWillAppear: (() -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) -> Self {
        var attributes = Self.bottomFloat(
            entryName: entryName,
            screenColor: nil,
            screenInteraction: screenInteraction,
            useSafeArea: true,
            hasHandleBar: false,
            workAtWillAppear: workAtWillAppear,
            completion: completion
        ).attributes
        
        attributes.roundCorners = .all(radius: 0)
        attributes.positionConstraints.verticalOffset = 0
        
        return .init(entryName: entryName, attributes: attributes)
    }
}
