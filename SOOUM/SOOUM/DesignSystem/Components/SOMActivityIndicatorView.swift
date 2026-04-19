//
//  SOMActivityIndicatorView.swift
//  SOOUM
//
//  Created by 오현식 on 11/4/24.
//

import UIKit

import SnapKit
import Then

import Lottie

class SOMActivityIndicatorView: UIActivityIndicatorView {
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = .som.v2.dim
    }
    
    private let animationView = LottieAnimationView(name: "loading_indicator_lottie").then {
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .loop
    }
    
    private var didSetupFillConstraints: Bool = false
    
    
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
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard let superview = self.superview, self.didSetupFillConstraints == false else { return }
        
        self.didSetupFillConstraints = true
        self.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        superview.bringSubviewToFront(self)
    }
    
    override func startAnimating() {
        super.startAnimating()
        self.superview?.bringSubviewToFront(self)
        self.animationView.play()
    }
    
    override func stopAnimating() {
        super.stopAnimating()
        self.animationView.stop()
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.tintColor = .clear
        self.isHidden = true
        
        self.hidesWhenStopped = true
        
        self.addSubview(self.backgroundView)
        self.backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.backgroundView.addSubview(self.animationView)
        self.animationView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(60)
        }
    }
}
