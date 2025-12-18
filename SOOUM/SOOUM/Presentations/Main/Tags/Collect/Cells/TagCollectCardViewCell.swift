//
//  TagCollectCardViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 11/20/25.
//

import UIKit

import SnapKit
import Then

class TagCollectCardViewCell: UICollectionViewCell {
    
    static let cellIdentifier = String(reflecting: TagCollectCardViewCell.self)
    
    
    // MARK: Views
    
    private let backgroundImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let backgroundDimView = UIView().then {
        $0.backgroundColor = .som.v2.dim
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    
    private let contentLabel = UILabel().then {
        $0.textColor = .som.v2.white
        $0.textAlignment = .center
        $0.typography = .som.v2.caption4
        $0.numberOfLines = 8
        $0.lineBreakMode = .byTruncatingTail
        $0.lineBreakStrategy = .hangulWordPriority
    }
    
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.backgroundImageView.image = nil
        self.contentLabel.text = nil
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.backgroundImageView)
        self.backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.backgroundImageView.addSubview(self.backgroundDimView)
        self.backgroundDimView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
        }
        
        self.backgroundDimView.addSubview(self.contentLabel)
        self.contentLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.bottom.equalToSuperview().offset(-6)
            $0.leading.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-8)
        }
    }
    
    
    // MARK: Public func
    
    func setModel(_ model: ProfileCardInfo) {
        
        self.backgroundImageView.setImage(strUrl: model.imgURL, with: model.imgName)
        self.contentLabel.text = model.content
        self.contentLabel.textAlignment = .center
        let typography: Typography
        switch model.font {
        case .pretendard:   typography = .som.v2.caption4
        case .ridi:         typography = .som.v2.ridiProfile
        case .yoonwoo:      typography = .som.v2.yoonwooProfile
        case .kkookkkook:   typography = .som.v2.kkookkkookProfile
        }
        self.contentLabel.typography = typography
    }
}
