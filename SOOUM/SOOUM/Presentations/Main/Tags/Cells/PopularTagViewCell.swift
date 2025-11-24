//
//  PopularTagViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 11/20/25.
//

import UIKit

import SnapKit
import Then

class PopularTagViewCell: UICollectionViewCell {
    
    static let cellIdentifier = String(reflecting: PopularTagViewCell.self)
    
    
    // MARK: Views
    
    private let container = UIView()
    
    private let numberLabel = UILabel().then {
        $0.textColor = .som.v2.pDark
        $0.typography = .som.v2.title2
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.v2.gray600
        $0.typography = .som.v2.subtitle1
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private let countLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.caption2
    }
    
    
    // MARK: Variables
    
    private(set) var model: TagInfo?
    
    override var isHighlighted: Bool {
        didSet {
            if oldValue != self.isHighlighted {
                self.updateColors(self.isHighlighted)
            }
        }
    }
    
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Override func
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.numberLabel.text = nil
        self.titleLabel.text = nil
        self.countLabel.text = nil
    }
    
    // Set highlighted color
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        
//        guard let touch = touches.first else { return }
//        
//        let location = touch.location(in: self.container)
//        if self.container.frame.contains(location) {
//            
//            self.updateColors(true)
//        }
//        
//        super.touchesBegan(touches, with: event)
//    }
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        
//        self.updateColors(false)
//        
//        super.touchesEnded(touches, with: event)
//    }
//    
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        
//        self.updateColors(false)
//        
//        super.touchesCancelled(touches, with: event)
//    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.numberLabel)
        self.numberLabel.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
        }
        
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
        
        self.contentView.addSubview(self.countLabel)
        self.countLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(2)
            $0.bottom.equalToSuperview().offset(-4)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
        
        self.contentView.addSubview(self.container)
        self.container.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func updateColors(_ isTouchesBegan: Bool) {
        
        self.numberLabel.textColor = isTouchesBegan ? .som.v2.pLight2 : .som.v2.pDark
        self.titleLabel.textColor = isTouchesBegan ? .som.v2.gray400 : .som.v2.gray600
        self.countLabel.textColor = isTouchesBegan ? .som.v2.gray300 : .som.v2.gray500
    }
    
    
    // MARK: Public func
    
    func setModel(_ model: TagInfo, with number: Int) {
        
        self.model = model
        
        self.numberLabel.text = "\(number)"
        self.numberLabel.typography = .som.v2.title2
        
        self.titleLabel.text = model.name
        self.titleLabel.typography = .som.v2.subtitle1
        
        self.countLabel.text = "\(model.usageCnt)"
        self.countLabel.typography = .som.v2.caption2
    }
}
