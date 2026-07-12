//
//  NavigationTransitionGuard.swift
//  SOOUM
//
//  Created by Codex on 7/5/26.
//

import ObjectiveC
import UIKit

final class NavigationTransitionGuard {

    private static var isLockedKey: UInt8 = 0

    static func canPush(
        from sourceViewController: UIViewController,
        on navigationController: UINavigationController?
    ) -> Bool {
        guard let navigationController else { return false }
        guard navigationController.topViewController === sourceViewController else { return false }

        let isLocked = (objc_getAssociatedObject(
            navigationController,
            &Self.isLockedKey
        ) as? Bool) ?? false

        return isLocked == false
    }

    static func canPop(
        from sourceViewController: UIViewController,
        on navigationController: UINavigationController?
    ) -> Bool {
        guard let navigationController else { return false }
        guard navigationController.viewControllers.count > 1 else { return false }

        let isLocked = (objc_getAssociatedObject(
            navigationController,
            &Self.isLockedKey
        ) as? Bool) ?? false

        if navigationController.topViewController === sourceViewController {
            return isLocked == false
        }

        return isLocked == false
    }

    static func lock(on navigationController: UINavigationController?) {
        guard let navigationController else { return }

        objc_setAssociatedObject(
            navigationController,
            &Self.isLockedKey,
            true,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }

    static func unlock(on navigationController: UINavigationController?) {
        guard let navigationController else { return }

        objc_setAssociatedObject(
            navigationController,
            &Self.isLockedKey,
            false,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }

    static func unlockAfterTransition(on navigationController: UINavigationController?) {
        guard let navigationController else { return }

        guard let transitionCoordinator = navigationController.transitionCoordinator else {
            DispatchQueue.main.async {
                Self.unlock(on: navigationController)
            }
            return
        }

        transitionCoordinator.animate(alongsideTransition: nil) { _ in
            Self.unlock(on: navigationController)
        }
    }
}
