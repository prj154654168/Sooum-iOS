//
//  UIViewController+PushAndPop.swift
//  SOOUM
//
//  Created by 오현식 on 9/21/24.
//

import UIKit

extension UIViewController {

    private var enclosingMainTabBarController: MainTabBarController? {
        if let mainTabBarController = self as? MainTabBarController {
            return mainTabBarController
        }
        
        if let navigationController = self as? UINavigationController,
           let mainTabBarController = navigationController.parent as? MainTabBarController {
            return mainTabBarController
        }
        
        var parentViewController = self.parent
        while let current = parentViewController {
            if let mainTabBarController = current as? MainTabBarController {
                return mainTabBarController
            }
            
            parentViewController = current.parent
        }
        
        return nil
    }
    
    private var targetNavigationController: UINavigationController? {
        if let mainTabBarController = self.enclosingMainTabBarController {
            return mainTabBarController.navigationController
        }
        
        return (self as? UINavigationController) ?? self.navigationController
    }

    private var transitionGuardSourceViewController: UIViewController {
        if let mainTabBarController = self.enclosingMainTabBarController,
           let navigationController = mainTabBarController.navigationController,
           navigationController.topViewController === mainTabBarController {
            return mainTabBarController
        }
        
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController ?? navigationController
        }

        return self
    }

    func navigationPush(
        _ viewController: UIViewController,
        animated: Bool,
        bottomBarHidden: Bool = false,
        completion: ((UIViewController) -> Void)? = nil
    ) {
        guard let navigationController = self.targetNavigationController else { return }
        guard NavigationTransitionGuard.canPush(
            from: self.transitionGuardSourceViewController,
            on: navigationController
        ) else { return }

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?(viewController)
        }

        self.hidesBottomBarWhenPushed = bottomBarHidden
        NavigationTransitionGuard.lock(on: navigationController)
        navigationController.pushViewController(viewController, animated: animated)
        NavigationTransitionGuard.unlockAfterTransition(on: navigationController)

        CATransaction.commit()
    }
    
    func navigationPop(
        to: UIViewController.Type? = nil,
        animated: Bool = true,
        bottomBarHidden: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard let navigationController = self.targetNavigationController else { return }
        guard NavigationTransitionGuard.canPop(
            from: self.transitionGuardSourceViewController,
            on: navigationController
        ) else { return }

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        NavigationTransitionGuard.lock(on: navigationController)

        let viewControllers = navigationController.viewControllers
        if let to: UIViewController.Type = to,
            let destination: UIViewController = viewControllers.last(
                where: { type(of: $0) == to }
            ) {
            destination.hidesBottomBarWhenPushed = bottomBarHidden
            navigationController.popToViewController(destination, animated: animated)
        } else {
            self.hidesBottomBarWhenPushed = bottomBarHidden
            navigationController.popViewController(animated: animated)
        }

        NavigationTransitionGuard.unlockAfterTransition(on: navigationController)

        CATransaction.commit()
    }
    
    func navigationPopToRoot(
        animated: Bool = true,
        bottomBarHidden: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard let navigationController = self.targetNavigationController else { return }
        guard NavigationTransitionGuard.canPop(
            from: self.transitionGuardSourceViewController,
            on: navigationController
        ) else { return }

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        self.hidesBottomBarWhenPushed = bottomBarHidden
        NavigationTransitionGuard.lock(on: navigationController)
        navigationController.popToRootViewController(animated: animated)
        NavigationTransitionGuard.unlockAfterTransition(on: navigationController)
        
        CATransaction.commit()
    }
}
