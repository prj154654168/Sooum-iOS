//
//  OtherProfileViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/24.
//

import UIKit

import SnapKit
import Then


class OtherProfileViewCell: UICollectionViewCell {
    
    enum Text {
        static let cardTitle: String = "카드"
        static let follingTitle: String = "팔로잉"
        static let followerTitle: String = "팔로워"
        
        static let followButtonTitle: String = "팔로우하기"
        static let didFollowButtonTitle: String = "팔로우 중"
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
    
    private let totalFollowingCountLabel = UILabel().then {
        $0.textColor = .som.gray700
        $0.typography = .som.head2WithBold
    }
    private let followingTitleLabel = UILabel().then {
        $0.text = Text.follingTitle
        $0.textColor = .som.gray500
        $0.typography = .som.caption
    }
    
    private let totalFollowerCountLabel = UILabel().then {
        $0.textColor = .som.gray700
        $0.typography = .som.head2WithBold
    }
    private let followerTitleLabel = UILabel().then {
        $0.text = Text.followerTitle
        $0.textColor = .som.gray500
        $0.typography = .som.caption
    }
    
    let followButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        let image = UIImage(.icon(.outlined(.plus)))?.resized(.init(width: 16, height: 16), color: .som.white)
        config.image = image
        config.image?.withTintColor(.som.white)
        config.imageColorTransformer = UIConfigurationColorTransformer { _ in .som.white }
        config.imagePadding = 2
        
        let typography = Typography.som.body2WithBold
        var attributes = typography.attributes
        attributes.updateValue(typography.font, forKey: .font)
        attributes.updateValue(UIColor.som.white, forKey: .foregroundColor)
        config.attributedTitle = .init(
            Text.followButtonTitle,
            attributes: AttributeContainer(attributes)
        )
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { _ in
            AttributeContainer(attributes)
        }
        
        $0.configuration = config
        $0.backgroundColor = .som.p300
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.backgroundColor = .clear
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func setModel(_ profile: Profile) {
        if let profileImg = profile.profileImg {
            self.profileImageView.setImage(strUrl: profileImg.url)
        } else {
            self.profileImageView.image = .init(.image(.sooumLogo))
        }
        self.totalCardCountLabel.text = profile.cardCnt
        self.totalFollowingCountLabel.text = profile.followingCnt
        self.totalFollowerCountLabel.text = profile.followerCnt
        
        let isFollowing = profile.isFollowing ?? false
        let updateConfigHandler: UIButton.ConfigurationUpdateHandler = { button in
            var updateConfig = button.configuration
            let image = UIImage(.icon(.outlined(.plus)))?.resized(.init(width: 16, height: 16), color: .som.white)
            updateConfig?.image = isFollowing ? nil : image
            updateConfig?.image?.withTintColor(.som.white)
            
            updateConfig?.title = isFollowing ? Text.didFollowButtonTitle : Text.followButtonTitle
            let updateTextAttributes = UIConfigurationTextAttributesTransformer { current in
                var update = current
                update.foregroundColor = isFollowing ? .som.gray600 : .som.white
                return update
            }
            updateConfig?.titleTextAttributesTransformer = updateTextAttributes
            button.configuration = updateConfig
        }
        
        self.followButton.configurationUpdateHandler = updateConfigHandler
        self.followButton.setNeedsUpdateConfiguration()
        
        self.followButton.backgroundColor = isFollowing ? .som.gray200 : .som.p300
    }
}