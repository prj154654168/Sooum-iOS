//
//  SOMToggle.swift
//  SOOUM
//
//  Created by 오현식 on 4/17/26.
//

import UIKit

import SnapKit
import Then

final class SOMToggle: UIView {
    
    private enum Metric {
        static let size = CGSize(width: 52, height: 32)
        static let thumbInset: CGFloat = 4
        static let thumbSize: CGFloat = 24
    }
    
    private let trackView = UIView().then {
        $0.layer.cornerRadius = Metric.size.height * 0.5
    }
    
    private let thumbView = UIView().then {
        $0.backgroundColor = .som.v2.white
        $0.layer.cornerRadius = Metric.thumbSize * 0.5
        $0.layer.shadowColor = UIColor.black.withAlphaComponent(0.18).cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 1)
        $0.layer.shadowRadius = 1.5
        $0.layer.shadowOpacity = 1
    }
    
    private(set) var isOn: Bool = false
    
    override var intrinsicContentSize: CGSize {
        Metric.size
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setContentHuggingPriority(.required, for: .horizontal)
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .vertical)
        self.setContentCompressionResistancePriority(.required, for: .vertical)
        
        self.setupConstraints()
        self.setOn(false, animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.thumbView.layer.shadowPath = UIBezierPath(
            roundedRect: self.thumbView.bounds,
            cornerRadius: self.thumbView.bounds.height * 0.5
        ).cgPath
    }
    
    func setOn(_ on: Bool, animated: Bool) {
        self.isOn = on
        
        let applyStyle = {
            self.trackView.backgroundColor = on ? .som.v2.pMain : .som.v2.gray200
            let translationX = on ? (Metric.size.width - Metric.thumbSize - (Metric.thumbInset * 2)) : 0
            self.thumbView.transform = CGAffineTransform(translationX: translationX, y: 0)
        }
        
        guard animated else {
            applyStyle()
            return
        }
        
        UIView.animate(
            withDuration: 0.22,
            delay: 0,
            options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction],
            animations: applyStyle
        )
    }
    
    private func setupConstraints() {
        self.addSubview(self.trackView)
        self.trackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.trackView.addSubview(self.thumbView)
        self.thumbView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Metric.thumbInset)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(Metric.thumbSize)
        }
    }
}
