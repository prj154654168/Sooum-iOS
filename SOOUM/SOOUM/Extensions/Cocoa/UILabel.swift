//
//  UILabel.swift
//  SOOUM
//
//  Created by 오현식 on 12/14/24.
//

import UIKit


extension UILabel {
    
    func copyTextWhenDidTapped() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.labelDidTap))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func labelDidTap(_ sender: UITapGestureRecognizer) {
        
        guard let label = sender.view as? UILabel else { return }
        UIPasteboard.general.string = label.text
    }
}
