//
//  UIViewController+Toast.swift
//  SOOUM
//
//  Created by 오현식 on 12/14/24.
//

import UIKit


extension UIViewController {
    
    func showToast(message: String, offset: CGFloat) {
        
        let typography: Typography = .som.body2WithRegular
        let width: CGFloat = NSString(string: message).boundingRect(
            with: .init(width: .infinity, height: typography.lineHeight),
            attributes: typography.attributes,
            context: nil
        ).width
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .som.black.withAlphaComponent(0.9)
        backgroundView.layer.cornerRadius = 8
        backgroundView.clipsToBounds = true
        backgroundView.alpha = 0
        
        self.view.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.bottomAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                constant: -offset
            ),
            backgroundView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            backgroundView.widthAnchor.constraint(equalToConstant: width + 18 * 2),
            backgroundView.heightAnchor.constraint(equalToConstant: typography.lineHeight + 8 * 2)
        ])
        
        let label = UILabel()
        label.text = message
        label.textColor = .som.white
        label.typography = typography
        
        backgroundView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor)
        ])
        
        UIView.animate(
            withDuration: 0.8,
            animations: {
                backgroundView.alpha = 1
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.5,
                    animations: {
                        backgroundView.alpha = 0
                    }, completion: { _ in
                        backgroundView.subviews.forEach { $0.removeFromSuperview() }
                        backgroundView.removeFromSuperview()
                    }
                )
            }
        )
    }
}
