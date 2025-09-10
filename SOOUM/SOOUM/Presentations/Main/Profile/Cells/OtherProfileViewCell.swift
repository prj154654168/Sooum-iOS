//
//  OtherProfileViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/24.
//

import UIKit

import SnapKit
import Then

import RxSwift


class OtherProfileViewCell: UICollectionViewCell {
    
    enum Text {
        static let cardTitle: String = "카드"
        static let follingTitle: String = "팔로잉"
        static let followerTitle: String = "팔로워"
        
        static let followButtonTitle: String = "팔로우하기"
        static let didFollowButtonTitle: String = "팔로우 중"
        static let blockedFollowButtonTitle: String = "차단 해제"
    }
    
    static let cellIdentifier = String(reflecting: OtherProfileViewCell.self)
    
    private let profileImageView = UIImageView().then {
        $0.layer.cornerRadius = 128 * 0.5
        $0.clipsToBounds = true
    }
    
    private let totalCardCountLabel = UILabel().then {
        $0.textColor = .som.gray700
        $0.typography = .som.head2WithBold
    }
    private let cardTitleLabel = UILabel().then {
        $0.text = Text.cardTitle
        $0.textColor = .som.gray500
        $0.typography = .som.caption
    }
    
    let followingButton = UIButton()
    private let totalFollowingCountLabel = UILabel().then {
        $0.textColor = .som.gray700
        $0.typography = .som.head2WithBold
    }
    private let followingTitleLabel = UILabel().then {
        $0.text = Text.follingTitle
        $0.textColor = .som.gray500
        $0.typography = .som.caption
    }
    
    let followerButton = UIButton()
    private let totalFollowerCountLabel = UILabel().then {
        $0.textColor = .som.gray700
        $0.typography = .som.head2WithBold
    }
    private let followerTitleLabel = UILabel().then {
        $0.text = Text.followerTitle
        $0.textColor = .som.gray500
        $0.typography = .som.caption
    }
    
    let followButton = SOMButton().then {
        $0.image = .init(.icon(.outlined(.plus)))?.resized(.init(width: 16, height: 16), color: .som.white)
        
        $0.title = Text.followButtonTitle
        $0.typography = .som.body2WithBold
        $0.foregroundColor = .som.white
        
        $0.backgroundColor = .som.p300
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.backgroundColor = .clear
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag() 
    }
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.profileImageView)
        self.profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(128)
        }
        
        let cardContainer = UIStackView(arrangedSubviews: [
            self.totalCardCountLabel,
            self.cardTitleLabel
        ]).then {
            $0.axis = .vertical
            $0.alignment = .center
            $0.distribution = .equalSpacing
            $0.spacing = 4
        }
        cardContainer.snp.makeConstraints {
            $0.width.equalTo(48)
            $0.height.equalTo(42)
        }
        
        let followingContainer = UIStackView(arrangedSubviews: [
            self.totalFollowingCountLabel,
            self.followingTitleLabel
        ]).then {
            $0.axis = .vertical
            $0.alignment = .center
            $0.distribution = .equalSpacing
            $0.spacing = 4
        }
        followingContainer.snp.makeConstraints {
            $0.width.equalTo(48)
            $0.height.equalTo(42)
        }
        followingContainer.addSubview(self.followingButton)
        self.followingButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        let followerContainer = UIStackView(arrangedSubviews: [
            self.totalFollowerCountLabel,
            self.followerTitleLabel
        ]).then {
            $0.axis = .vertical
            $0.alignment = .center
            $0.distribution = .equalSpacing
            $0.spacing = 4
        }
        followerContainer.snp.makeConstraints {
            $0.width.equalTo(48)
            $0.height.equalTo(42)
        }
        followerContainer.addSubview(self.followerButton)
        self.followerButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        let totalContainer = UIStackView(arrangedSubviews: [
            cardContainer,
            followingContainer,
            followerContainer
        ]).then {
            $0.axis = .horizontal
            $0.alignment = .fill
            $0.distribution = .equalSpacing
            $0.spacing = 12
        }
        self.contentView.addSubview(totalContainer)
        totalContainer.snp.makeConstraints {
            $0.top.equalToSuperview().offset(43) 
            $0.leading.equalTo(self.profileImageView.snp.trailing).offset(24)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        self.contentView.addSubview(self.followButton)
        self.followButton.snp.makeConstraints {
            $0.top.equalTo(self.profileImageView.snp.bottom).offset(22)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-22)
            $0.height.equalTo(48)
        }
    }
    
    func setModel(_ profile: Profile, isBlocked: Bool) {
        if let profileImg = profile.profileImg {
            self.profileImageView.setImage(strUrl: profileImg.url)
        } else {
            self.profileImageView.image = .init(.image(.defaultStyle(.sooumLogo)))
        }
        self.totalCardCountLabel.text = profile.cardCnt
        self.totalFollowingCountLabel.text = profile.followingCnt
        self.totalFollowerCountLabel.text = profile.followerCnt
        
        let isFollowing = profile.isFollowing ?? false
        
        if isBlocked {
            self.followButton.image = nil
            self.followButton.title = Text.blockedFollowButtonTitle
            self.followButton.foregroundColor = .som.white
            self.followButton.backgroundColor = .som.p300
        } else {
            let image = UIImage(.icon(.outlined(.plus)))?.resized(.init(width: 16, height: 16), color: .som.white)
            self.followButton.image = isFollowing ? nil : image
            self.followButton.title = isFollowing ? Text.didFollowButtonTitle : Text.followButtonTitle
            self.followButton.foregroundColor = isFollowing ? .som.gray600 : .som.white
            self.followButton.backgroundColor = isFollowing ? .som.gray200 : .som.p300
        }
    }
}
