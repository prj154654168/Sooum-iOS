//
//  SOMRefreshControl.swift
//  SOOUM
//
//  Created by 오현식 on 10/7/24.
//

import UIKit

import SnapKit
import Then

import Lottie

class SOMRefreshControl: UIRefreshControl {
    
    
    // MARK: Views
    
    private let animationView = LottieAnimationView(name: "refrech_control_lottie").then {
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .loop
    }
    
    
    // MARK: Initialize
    
    convenience override init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: #keyPath(isRefreshing), context: nil)
    }
    
    
    // MARK: Override func
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.subviews.filter { $0 != self.animationView }.forEach { $0.removeFromSuperview() }
    }
    
    override func beginRefreshing() {
        super.beginRefreshing()
        self.animationView.play()
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        self.animationView.stop()
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.addObserver(self, forKeyPath: #keyPath(isRefreshing), options: .new, context: nil)
        
        self.tintColor = .clear
        self.backgroundColor = .clear
        
        self.addSubview(self.animationView)
        self.animationView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(44)
        }
    }
}
