//
//  BlockUserPlaceholderViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 11/9/25.
//

import UIKit

import SnapKit
import Then

class BlockUserPlaceholderViewCell: UITableViewCell {
    
    enum Text {
        static let placeholderText: String = "차단한 사용자가 없어요"
    }
    
    static let cellIdentifier = String(reflecting: BlockUserPlaceholderViewCell.self)
    
    
    // MARK: Views
    
    private let placeholderImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.filled(.hide))))
        $0.tintColor = .som.v2.gray200
        $0.contentMode = .scaleAspectFit
    }
    
    private let placeholderMessageLabel = UILabel().then {
        $0.text = Text.placeholderText
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.body1
    }
    
    
    // MARK: Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.placeholderImageView)
        self.placeholderImageView.snp.makeConstraints {
            /// (screen height - safe layout guide top - navi height - header height) * 0.5 - (icon height + spacing + label height)
            let offset = (UIScreen.main.bounds.height - 48 - 56) * 0.5 - (24 + 8 + 21) * 0.5
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
