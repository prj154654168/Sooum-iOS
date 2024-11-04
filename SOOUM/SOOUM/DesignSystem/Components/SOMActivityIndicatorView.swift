//
//  SOMActivityIndicatorView.swift
//  SOOUM
//
//  Created by 오현식 on 11/4/24.
//

import UIKit

import SnapKit
import Then


class SOMActivityIndicatorView: UIActivityIndicatorView {
    
    private let imageView = UIImageView().then {
        $0.image = .init(.image(.refreshControl))
        $0.contentMode = .scaleAspectFit
    }
    
    
    // MARK: Init
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        self.tintColor = .clear
        
        let backgroundView = UIView().then {
            $0.backgroundColor = .som.white
            $0.layer.cornerRadius = 40 * 0.5
            $0.layer.shadowColor = UIColor.som.black.withAlphaComponent(0.25).cgColor
            /// Opacity는 1로 설정하여 alpha에 의존
            $0.layer.shadowOpacity = 1
            /// x=0, y=4
            $0.layer.shadowOffset = CGSize(width: 0, height: 4)
            /// blur=4
            $0.layer.shadowRadius = 4
        }
        self.addSubviews(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(40)
        }
        
        backgroundView.addSubviews(self.imageView)
        self.imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(28)
        }
    }
    
    override func startAnimating() {
        super.startAnimating()
        self.animation(true)
    }
    
    override func stopAnimating() {
        super.stopAnimating()
        self.animation(false)
    }
    
    private func animation(_ isAnimating: Bool) {
        
        if isAnimating {
            let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
            rotate.toValue = NSNumber(value: Double.pi * 2.0)
            rotate.duration = 1
            rotate.isCumulative = true
            rotate.repeatCount = Float.infinity
            self.imageView.layer.anchorPoint = .init(x: 0.5, y: 0.5)
            self.imageView.layer.add(rotate, forKey: "rotate")
        } else {
            self.imageView.layer.removeAnimation(forKey: "rotate")
        }
    }
}
