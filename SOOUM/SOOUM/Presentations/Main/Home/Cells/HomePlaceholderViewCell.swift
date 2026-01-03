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
    
    static let cellIdentifier = String(reflecting: HomePlaceholderViewCell.self)
    
    
    // MARK: Views
    
    private let placeholderImageView = UIImageView().then {
        $0.image = .init(.image(.v2(.placeholder_home)))
        $0.contentMode = .scaleAspectFit
    }
    
    private let placeholderLabel = UILabel().then {
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.body1
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.lineBreakStrategy = .hangulWordPriority
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
            let offset = UIScreen.main.bounds.height * 0.1
            $0.top.equalToSuperview().offset(offset)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(113)
        }
        
        self.contentView.addSubview(self.placeholderLabel)
        self.placeholderLabel.snp.makeConstraints {
            $0.top.equalTo(self.placeholderImageView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
    }
    
    
    // MARK: Public info
    
    func bind(_ placeholderText: String) {
        self.placeholderLabel.text = placeholderText
        self.placeholderLabel.typography = .som.v2.body1
    }
}
