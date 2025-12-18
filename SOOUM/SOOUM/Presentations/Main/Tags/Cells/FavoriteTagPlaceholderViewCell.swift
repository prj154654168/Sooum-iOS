//
//  FavoriteTagPlaceholderViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 11/19/25.
//

import UIKit

import SnapKit
import Then

class FavoriteTagPlaceholderViewCell: UICollectionViewCell {
    
    enum Text {
        static let message: String = "관심 태그가 포함된 카드가 작성되면\n알림을 받을 수 있어요"
    }
    
    static let cellIdentifier = String(reflecting: FavoriteTagPlaceholderViewCell.self)
    
    
    // MARK: Views
    
    private let placeholderImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.filled(.star))))
        $0.tintColor = .som.v2.gray200
    }
    
    private let placeholderMessageLabel = UILabel().then {
        $0.text = Text.message
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.body1
        $0.numberOfLines = 0
    }
    
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.placeholderImageView)
        self.placeholderImageView.snp.makeConstraints {
            /// bottom padding +  placeholderMessageLabel height
            let offset = (8 + 42) * 0.5
            $0.centerY.equalToSuperview().offset(-offset)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        self.contentView.addSubview(self.placeholderMessageLabel)
        self.placeholderMessageLabel.snp.makeConstraints {
            $0.top.equalTo(self.placeholderImageView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
    }
}
