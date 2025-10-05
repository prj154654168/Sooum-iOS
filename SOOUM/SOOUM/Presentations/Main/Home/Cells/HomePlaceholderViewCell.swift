//
//  HomePlaceholderViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 12/30/24.
//

import UIKit

import SnapKit
import Then


class HomePlaceholderViewCell: UITableViewCell {
    
    enum Text {
        static let message: String = "아직 작성된 글이 없어요\n하고 싶은 이야기를 카드로 남겨보세요"
    }
    
    static let cellIdentifier = String(reflecting: HomePlaceholderViewCell.self)
    
    
    // MARK: Views
    
    private let placeholderImageView = UIImageView().then {
        $0.image = .init(.image(.v2(.placeholder_home)))
    }
    
    private let placeholderMessageLabel = UILabel().then {
        $0.text = Text.message
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.body1
        $0.textAlignment = .center
    }
    
    
    // MARK: Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
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
            let offset = UIScreen.main.bounds.height * 0.2
            $0.top.equalToSuperview().offset(offset)
            $0.centerX.equalToSuperview()
        }
        
        self.contentView.addSubview(self.placeholderMessageLabel)
        self.placeholderMessageLabel.snp.makeConstraints {
            $0.top.equalTo(self.placeholderImageView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
    }
}
