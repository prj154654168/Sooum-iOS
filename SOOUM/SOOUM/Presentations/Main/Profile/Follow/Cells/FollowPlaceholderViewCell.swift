//
//  FollowPlaceholderViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 11/8/25.
//

import UIKit

import SnapKit
import Then

class FollowPlaceholderViewCell: UITableViewCell {
    
    static let cellIdentifier = String(reflecting: FollowPlaceholderViewCell.self)
    
    
    // MARK: Views
    
    private let placeholderImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.filled(.users))))
        $0.tintColor = .som.v2.gray200
        $0.contentMode = .scaleAspectFit
    }
    
    private let placeholderMessageLabel = UILabel().then {
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.body1
    }
    
    
    // MARK: Variables
    
    var placeholderText: String? {
        set {
            self.placeholderMessageLabel.text = newValue
            self.placeholderMessageLabel.typography = .som.v2.body1
        }
        get {
            return self.placeholderMessageLabel.text
        }
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
            let offset = 8 + 21
            $0.centerY.equalToSuperview().offset(-offset)
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
