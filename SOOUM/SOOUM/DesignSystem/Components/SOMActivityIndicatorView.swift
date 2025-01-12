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
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = .som.white
        $0.layer.cornerRadius = 40 * 0.5
    }
    
    private let imageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.refresh)))
        $0.tintColor = .som.black
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
    
    
    // MARK: Override func
    
    override func startAnimating() {
        super.startAnimating()
        self.animation(true)
    }
    
    override func stopAnimating() {
        super.stopAnimating()
        self.animation(false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundView.setShadow(
            radius: 40 * 0.5,
            color: UIColor.som.black.withAlphaComponent(0.25),
            blur: 4,
            offset: .init(width: 0, height: 4)
        )
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.tintColor = .clear
        
        self.addSubviews(self.backgroundView)
        self.backgroundView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(40)
        }
        
        self.backgroundView.addSubviews(self.imageView)
        self.imageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(28)
        }
    }
    
    private func animation(_ isAnimating: Bool) {
        
        if isAnimating {
            let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
            rotate.fromValue = 0
            rotate.toValue = NSNumber(value: Double.pi * -2.0)
            rotate.duration = 1
            rotate.repeatCount = Float.infinity
            rotate.timingFunction = CAMediaTimingFunction(name: .linear)
            self.imageView.layer.add(rotate, forKey: "rotate")
        } else {
            self.imageView.layer.removeAnimation(forKey: "rotate")
        }
    }
}
