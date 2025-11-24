//
//  TagCollectPlaceholderViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 11/20/25.
//

import UIKit

import SnapKit
import Then

class TagCollectPlaceholderViewCell: UICollectionViewCell {
    
    enum Text {
        static let message: String = "조회할 수 있는 카드가 없어요"
    }
    
    static let cellIdentifier = String(reflecting: TagCollectPlaceholderViewCell.self)
    
    
    // MARK: Views
    
    private let placeholderImageView = UIImageView().then {
        $0.image = .init(.image(.v2(.detail_delete_card)))
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
            let offset = (20 + 21) * 0.5
            $0.centerY.equalToSuperview().offset(-offset)
            $0.centerX.equalToSuperview()
        }
        
        self.contentView.addSubview(self.placeholderMessageLabel)
        self.placeholderMessageLabel.snp.makeConstraints {
            $0.top.equalTo(self.placeholderImageView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
    }
}
