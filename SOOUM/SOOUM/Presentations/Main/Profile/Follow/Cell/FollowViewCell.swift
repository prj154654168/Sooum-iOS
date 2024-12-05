//
//  FollowViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import UIKit

import SnapKit
import Then


class FollowViewCell: UITableViewCell {
    
    private let profileImageView = UIImageView().then {
        $0.layer.cornerRadius = 46 * 0.5
        $0.clipsToBounds = true
    }
    
    private let profileNickname = UILabel().then {
        $0.textColor = .som.gray700
        $0.typography = .som.body1WithBold
    }
    
    private let followButton = UIButton()
    
    private let cancelFollowButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.contentView.clipsToBounds = true
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.profileImageView)
        self.profileNickname.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(46)
        }
        
        self.contentView.addSubview(self.profileNickname)
        self.profileNickname.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.profileImageView.snp.trailing).offset(12)
        }
        
        self.contentView.addSubview(self.followButton)
        self.followButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(self.profileNickname.snp.trailing).offset(40)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(26)
        }
    }
    
    func setModel(_ follow: Follow) {
        if let url = follow.backgroundImgURL?.url {
            self.profileImageView.setImage(strUrl: url)
        } else {
            self.profileImageView.image = .init(.image(.sooumLogo))
        }
        self.profileNickname.text = follow.nickname
        
    }
}
