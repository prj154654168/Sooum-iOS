//
//  SearchTermViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 11/22/25.
//

import UIKit

import SnapKit
import Then

class SearchTermViewCell: UICollectionViewCell {
    
    static let cellIdentifier = String(reflecting: SearchTermViewCell.self)
    
    
    // MARK: Views
    
    private let container = UIView()
    
    private let iconView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.hash))))
        $0.tintColor = .som.v2.gray400
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.body1
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private let countLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.caption3
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
        
        self.contentView.addSubview(self.iconView)
        self.iconView.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
            $0.size.equalTo(16)
        }
        
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.leading.equalTo(self.iconView.snp.trailing).offset(10)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        self.contentView.addSubview(self.countLabel)
        self.countLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom)
            $0.bottom.equalToSuperview().offset(-6)
            $0.leading.equalTo(self.iconView.snp.trailing).offset(10)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        self.contentView.addSubview(self.container)
        self.container.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func updateColors(_ isTouchesBegan: Bool) {
        
        self.titleLabel.textColor = isTouchesBegan ? .som.v2.gray500 : .som.v2.black
        self.countLabel.textColor = isTouchesBegan ? .som.v2.gray400 : .som.v2.gray500
    }
    
    
    // MARK: Public func
    
    func setModel(_ model: TagInfo) {
        
        self.model = model
        
        self.titleLabel.text = model.name
        self.titleLabel.typography = .som.v2.body1
        
        self.countLabel.text = "\(model.usageCnt)"
        self.countLabel.typography = .som.v2.caption3
    }
}
