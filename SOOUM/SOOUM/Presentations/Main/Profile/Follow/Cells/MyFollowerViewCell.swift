//
//  MyFollowerViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 12/7/24.
//

import UIKit

import SnapKit
import Then

import RxSwift


class MyFollowerViewCell: UITableViewCell {
    
    enum Text {
        static let didFollowButton: String = "팔로잉"
        static let willFollowButton: String = "팔로우"
    }
    
    static let cellIdentifier = String(reflecting: MyFollowerViewCell.self)
    
    let profilBackgroundButton = UIButton()
    
    private let profileImageView = UIImageView().then {
        $0.layer.cornerRadius = 46 * 0.5
        $0.clipsToBounds = true
    }
    
    private let profileNickname = UILabel().then {
        $0.textColor = .som.gray700
        $0.typography = .som.body1WithBold
    }
    
    let followButton = SOMButton().then {
        $0.layer.cornerRadius = 26 * 0.5
        $0.clipsToBounds = true
    }
    
    var disposeBag = DisposeBag()
    
    
    // MARK: Initalization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.contentView.clipsToBounds = true
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Override func
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.profileImageView)
        self.profileImageView.snp.makeConstraints {
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
            $0.width.equalTo(72)
            $0.height.equalTo(26)
        }
        
        self.contentView.addSubview(self.profilBackgroundButton)
        self.profilBackgroundButton.snp.makeConstraints {
            $0.top.equalTo(self.profileImageView.snp.top)
            $0.bottom.equalTo(self.profileImageView.snp.bottom)
            $0.leading.equalTo(self.profileImageView.snp.leading)
            $0.trailing.equalTo(self.profileNickname.snp.trailing)
        }
    }
    
    
    // MARK: Public func
    
    func setModel(_ follow: Follow) {
        if let url = follow.backgroundImgURL?.url {
            self.profileImageView.setImage(strUrl: url)
        } else {
            self.profileImageView.image = .init(.image(.sooumLogo))
        }
        self.profileNickname.text = follow.nickname
        
        self.updateButton(follow.isFollowing)
    }
    
    func updateButton(_ isFollowing: Bool) {
        
        self.followButton.title = isFollowing ? Text.didFollowButton : Text.willFollowButton
        self.followButton.typography = .som.body3WithBold
        self.followButton.foregroundColor = isFollowing ? .som.gray600 : .som.white
        self.followButton.backgroundColor = isFollowing ? .som.gray200 : .som.p300
    }
}
