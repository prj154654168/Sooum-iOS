//
//  SOMLoadingIndicatorWithLottie.swift
//  SOOUM
//
//  Created by 오현식 on 9/12/25.
//

import UIKit

import SnapKit
import Then

import Lottie

class SOMLoadingIndicatorView: UIView {
    
    
    // MARK: Views
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = .som.v2.dim
    }
    
    private let animationView = LottieAnimationView(name: "loading_indicator_lottie").then {
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .loop
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
    
    
    // MARK: Public func
    
    func startAnimating() {
        self.isHidden = false
        self.animationView.play()
    }
    
    func stopAnimating() {
        self.isHidden = true
        self.animationView.stop()
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.isHidden = true
        
        self.addSubview(self.backgroundView)
        self.backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.backgroundView.addSubviews(self.animationView)
        self.animationView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(60)
        }
    }
}
