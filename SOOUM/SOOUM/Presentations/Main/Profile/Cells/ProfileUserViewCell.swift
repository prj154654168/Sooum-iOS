//
//  ProfileViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 11/6/25.
//

import UIKit

import SnapKit
import Then

import RxCocoa
import RxSwift

class ProfileUserViewCell: UICollectionViewCell {
    
    enum Text {
        static let totalVisitedTitle: String = "Total"
        static let todayVisitedTitle: String = "Today"
        static let cardCntTitle: String = "카드"
        static let followerCntTitle: String = "팔로워"
        static let followingCntTitle: String = "팔로잉"
        static let updateProfileButtonTitle: String = "프로필 편집"
        static let followButtonTitle: String = "팔로우"
        static let followingButtonTitle: String = "팔로잉"
    }
    
    static let cellIdentifier = String(reflecting: ProfileUserViewCell.self)
    
    // MARK: Views
    
    private let visitedAndNicknameContainer = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.distribution = .fill
        $0.spacing = 2
    }
    
    private let visitedCountContainer = UIView().then {
        $0.isHidden = true
    }
    
    private let totalVisitedTitleLabel = UILabel().then {
        $0.text = Text.totalVisitedTitle
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.caption2
    }
    private let totalVisitedCountLabel = UILabel().then {
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.caption2
    }
    
    private let dot = UIView().then {
        $0.backgroundColor = .som.v2.gray400
        $0.layer.cornerRadius = 3 * 0.5
    }
    
    private let todayVisitedTitleLabel = UILabel().then {
        $0.text = Text.todayVisitedTitle
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.caption2
    }
    private let todayVisitedCountLabel = UILabel().then {
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.caption2
    }
    
    private let nicknameLabel = UILabel().then {
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.head3
    }
    
    private let profilImageView = UIImageView().then {
        $0.image = .init(.image(.v2(.profile_large)))
        $0.backgroundColor = .som.v2.gray300
        $0.layer.cornerRadius = 60 * 0.5
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.som.v2.gray300.cgColor
        $0.clipsToBounds = true
    }
    
    private let bottomContainer = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .top
        $0.distribution = .equalSpacing
        $0.spacing = 0
    }
    
    let updateProfileButton = SOMButton().then {
        $0.title = Text.updateProfileButtonTitle
        $0.typography = .som.v2.subtitle1
        $0.foregroundColor = .som.v2.gray600
        $0.backgroundColor = .som.v2.gray100
    }
    
    let followButton = SOMButton().then {
        $0.title = Text.followButtonTitle
        $0.typography = .som.v2.subtitle1
        $0.foregroundColor = .som.v2.white
        $0.backgroundColor = .som.v2.black
        
        $0.isHidden = true
    }
    
    
    // MARK: Variables
    
    private(set) var model: ProfileInfo = .defaultValue
    
    
    // MARK: Variables + Rx
    
    var disposeBag = DisposeBag()
    
    let cardContainerDidTap = PublishRelay<Void>()
    let followerContainerDidTap = PublishRelay<Void>()
    let followingContainerDidTap = PublishRelay<Void>()
    
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        let topContainer = UIView()
        self.addSubview(topContainer)
        topContainer.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(84)
        }
        
        topContainer.addSubview(self.visitedAndNicknameContainer)
        self.visitedAndNicknameContainer.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }
        
        self.visitedCountContainer.addSubview(self.totalVisitedTitleLabel)
        self.totalVisitedTitleLabel.snp.makeConstraints {
            $0.verticalEdges.leading.equalToSuperview()
        }
        self.visitedCountContainer.addSubview(self.totalVisitedCountLabel)
        self.totalVisitedCountLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.leading.equalTo(self.totalVisitedTitleLabel.snp.trailing).offset(4)
        }
        
        self.visitedCountContainer.addSubview(self.dot)
        self.dot.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.totalVisitedCountLabel.snp.trailing).offset(7.5)
            $0.size.equalTo(3)
        }
        
        self.visitedCountContainer.addSubview(self.todayVisitedTitleLabel)
        self.todayVisitedTitleLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.leading.equalTo(self.dot.snp.trailing).offset(7.5)
        }
        self.visitedCountContainer.addSubview(self.todayVisitedCountLabel)
        self.todayVisitedCountLabel.snp.makeConstraints {
            $0.verticalEdges.trailing.equalToSuperview()
            $0.leading.equalTo(self.todayVisitedTitleLabel.snp.trailing).offset(4)
        }
        
        self.visitedAndNicknameContainer.addArrangedSubview(self.visitedCountContainer)
        self.visitedAndNicknameContainer.addArrangedSubview(self.nicknameLabel)
        
        topContainer.addSubview(self.profilImageView)
        self.profilImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(self.visitedAndNicknameContainer.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.size.equalTo(60)
        }
        
        self.addSubview(self.bottomContainer)
        self.bottomContainer.snp.makeConstraints {
            $0.top.equalTo(topContainer.snp.bottom)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(76)
        }
        
        self.addSubview(self.updateProfileButton)
        self.updateProfileButton.snp.makeConstraints {
            $0.top.equalTo(self.bottomContainer.snp.bottom)
            $0.bottom.equalToSuperview().offset(-16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(48)
        }
        
        self.addSubview(self.followButton)
        self.followButton.snp.makeConstraints {
            $0.top.equalTo(self.bottomContainer.snp.bottom)
            $0.bottom.equalToSuperview().offset(-16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(48)
        }
    }
    
    
    // MARK: public func
    
    func setModel(_ model: ProfileInfo) {
        
        self.model = model
        
        self.visitedCountContainer.isHidden = model.cardCnt == "0"
        self.totalVisitedCountLabel.text = model.totalVisitCnt
        self.totalVisitedCountLabel.typography = .som.v2.caption2
        self.todayVisitedCountLabel.text = model.todayVisitCnt
        self.todayVisitedCountLabel.typography = .som.v2.caption2
        
        self.nicknameLabel.text = model.nickname
        self.nicknameLabel.typography = .som.v2.head3
        
        if let profileImageUrl = model.profileImageUrl {
            self.profilImageView.setImage(strUrl: profileImageUrl, with: model.profileImgName)
        } else {
            self.profilImageView.image = .init(.image(.v2(.profile_medium)))
        }
        
        var contents: [(content: ProfileInfo.Content, count: String)] {
            var contents: [(content: ProfileInfo.Content, count: String)] = []
            
            contents.append((.card, model.cardCnt))
            contents.append((.follower, model.followerCnt))
            contents.append((.following, model.followingCnt))
            
            return contents
        }
        self.setupItems(contents)
        
        self.updateProfileButton.isHidden = model.isAlreadyFollowing != nil
        self.followButton.isHidden = model.isAlreadyFollowing == nil
        if let isAlreadyFollowing = model.isAlreadyFollowing {
            
            self.updateButton(isAlreadyFollowing)
        }
    }
    
    /// 상대방 프로필 일 때만 사용
    func updateButton(_ isFollowing: Bool) {
        
        self.followButton.title = isFollowing ? Text.followingButtonTitle : Text.followButtonTitle
        self.followButton.foregroundColor = isFollowing ? .som.v2.gray600 : .som.v2.white
        self.followButton.backgroundColor = isFollowing ? .som.v2.gray100 : .som.v2.black
    }
}

private extension ProfileUserViewCell {
    
    func setupItems(_ items: [(content: ProfileInfo.Content, count: String)]) {
        
        self.bottomContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        items.forEach { item in
            
            let topSpacing = UIView()
            let bottomSpacing = UIView()
            
            let titleLabel = UILabel().then {
                $0.text = item.content.rawValue
                $0.textColor = .som.v2.gray500
                $0.typography = .som.v2.body1.withAlignment(.left)
            }
            
            let countLabel = UILabel().then {
                $0.text = item.count
                $0.textColor = .som.v2.black
                $0.typography = .som.v2.title1.withAlignment(.left)
            }
            
            let container = UIStackView(arrangedSubviews: [topSpacing, titleLabel, countLabel, bottomSpacing]).then {
                $0.axis = .vertical
                $0.alignment = .leading
                $0.distribution = .equalSpacing
                $0.spacing = 0
            }
            container.snp.makeConstraints {
                $0.width.equalTo(72)
                $0.height.equalTo(64)
            }
            
            topSpacing.snp.makeConstraints {
                $0.height.equalTo(8)
            }
            bottomSpacing.snp.makeConstraints {
                $0.height.equalTo(8)
            }
            
            container.rx.tapGesture()
                .when(.recognized)
                .throttle(.seconds(1), scheduler: MainScheduler.instance)
                .subscribe(with: self) { object, _ in
                    switch item.content {
                    case .card:         object.cardContainerDidTap.accept(())
                    case .follower:     object.followerContainerDidTap.accept(())
                    case .following:    object.followingContainerDidTap.accept(())
                    }
                }
                .disposed(by: self.disposeBag)
            
            self.bottomContainer.addArrangedSubview(container)
        }
    }
}
