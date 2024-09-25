//
//  UIViewController+PushAndPop.swift
//  SOOUM
//
//  Created by 오현식 on 9/21/24.
//

import UIKit

extension UIViewController {

    func navigationPush(
        _ viewController: UIViewController,
        animated: Bool,
        bottomBarHidden: Bool = false,
        completion: ((UIViewController) -> Void)? = nil
    ) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?(viewController)
        }

        self.hidesBottomBarWhenPushed = bottomBarHidden
        self.navigationController?.pushViewController(viewController, animated: animated)

        CATransaction.commit()
    }
    
    // swiftlint:enable identifier_name
    func navigationPop(
        to: UIViewController.Type? = nil,
        animated: Bool = true,
        bottomBarHidden: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)

        if let to: UIViewController.Type = to,
            let viewControllers = self.navigationController?.viewControllers,
            let destination: UIViewController = viewControllers.last(
                where: { type(of: $0) == to }
            ) {
            destination.hidesBottomBarWhenPushed = bottomBarHidden
            self.navigationController?.popToViewController(destination, animated: animated)
        } else {
            self.navigationController?
                .viewControllers.dropLast().last?
                .hidesBottomBarWhenPushed = bottomBarHidden
            self.navigationController?.popViewController(animated: animated)
        }

        CATransaction.commit()
    }
}
