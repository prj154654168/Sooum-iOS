//
//  ProfileCardsPlaceholderViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 11/7/25.
//

import UIKit

import SnapKit
import Then

class ProfileCardsPlaceholderViewCell: UICollectionViewCell {
    
    enum Text {
        static let message: String = "카드가 없어요"
    }
    
    static let cellIdentifier = String(reflecting: ProfileCardsPlaceholderViewCell.self)
    
    
    // MARK: Views
    
    private let placeholderImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.filled(.card))))
        $0.tintColor = .som.v2.gray200
        $0.contentMode = .scaleAspectFit
    }
    
    private let placeholderMessageLabel = UILabel().then {
        $0.text = Text.message
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.body1
    }
    
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.placeholderImageView)
        self.placeholderImageView.snp.makeConstraints {
            /// (screen height - safe layout guide top - navi height - user cell height) * 0.5 - (icon height + spacing + label height) * 0.5 - tabBar height
            let offset = (UIScreen.main.bounds.height - (48 + 84 + 76 + 48 + 16)) * 0.5 - 53 * 0.5 - 88
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(offset)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        self.contentView.addSubview(self.placeholderMessageLabel)
        self.placeholderMessageLabel.snp.makeConstraints {
            $0.top.equalTo(self.placeholderImageView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
    }
}
