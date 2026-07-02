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
        static let unBlockButtonTitle: String = "차단 해제"
        static let bioMoreButtonTitle: String = "더 보기"
    }
    
    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let topContainerHeight: CGFloat = 84
        static let bottomContainerHeight: CGFloat = 76
        static let actionButtonHeight: CGFloat = 48
        static let actionButtonBottomInset: CGFloat = 16
        static let bioTopInset: CGFloat = 8
        static let bioBottomInset: CGFloat = 12
        static let bioMaximumLines: CGFloat = 4
    }
    
    static let cellIdentifier = String(reflecting: ProfileUserViewCell.self)
    private static let bioTypography = Typography.som.v2.body1.withAlignment(.left)
    
    // MARK: Views
    
    private let visitedAndNicknameContainer = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.distribution = .fill
        $0.spacing = 2
    }
    
    private let visitedCountContainer = UIView()
    
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
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .som.v2.gray300
        $0.layer.cornerRadius = 60 * 0.5
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.som.v2.gray300.cgColor
        $0.clipsToBounds = true
    }
    
    private let bioLabel = UILabel().then {
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.body1.withAlignment(.left)
        $0.numberOfLines = Int(Layout.bioMaximumLines)
        $0.lineBreakMode = .byTruncatingTail
        $0.lineBreakStrategy = .hangulWordPriority
    }
    
    private let bioMoreButton = UIButton(type: .system).then {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.baseForegroundColor = .som.v2.gray400
        $0.configuration = config
        $0.contentHorizontalAlignment = .leading
        $0.titleLabel?.font = Typography.som.v2.body1.font
        $0.setTitle(Text.bioMoreButtonTitle, for: .normal)
        $0.isHidden = true
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
    
    let unBlockButton = SOMButton().then {
        $0.title = Text.unBlockButtonTitle
        $0.typography = .som.v2.subtitle1
        $0.foregroundColor = .som.v2.white
        $0.backgroundColor = .som.v2.black
        
        $0.isHidden = true
    }
    
    
    // MARK: Variables
    
    private(set) var model: ProfileInfo = .defaultValue
    private var isBioExpanded: Bool = false
    private var shouldShowBioMoreButton: Bool = false
    
    
    // MARK: Constraints
    
    private var bottomContainerTopToBioLabelConstraint: Constraint?
    private var bioLabelHeightConstraint: Constraint?
    
    
    // MARK: Variables + Rx
    
    var disposeBag = DisposeBag()
    
    let cardContainerDidTap = PublishRelay<Void>()
    let followerContainerDidTap = PublishRelay<Void>()
    let followingContainerDidTap = PublishRelay<Void>()
    let bioMoreButtonDidTap = PublishRelay<Void>()
    
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.bioMoreButton.addTarget(self, action: #selector(self.didTapBioMoreButton), for: .touchUpInside)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
        self.isBioExpanded = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.updateBioMoreButtonVisibility()
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        let topContainer = UIView()
        self.addSubview(topContainer)
        topContainer.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(Layout.topContainerHeight)
        }
        
        topContainer.addSubview(self.visitedAndNicknameContainer)
        self.visitedAndNicknameContainer.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(Layout.horizontalInset)
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
            $0.trailing.equalToSuperview().offset(-Layout.horizontalInset)
            $0.size.equalTo(60)
        }
        
        self.addSubview(self.bioLabel)
        self.bioLabel.snp.makeConstraints {
            $0.top.equalTo(topContainer.snp.bottom).offset(Layout.bioTopInset)
            $0.leading.equalToSuperview().offset(Layout.horizontalInset)
            $0.trailing.lessThanOrEqualToSuperview().offset(-Layout.horizontalInset)
            self.bioLabelHeightConstraint = $0.height.equalTo(Self.bioTypography.lineHeight).constraint
        }
        
        self.addSubview(self.bioMoreButton)
        self.bioMoreButton.snp.makeConstraints {
            $0.bottom.equalTo(self.bioLabel.snp.bottom)
            $0.leading.equalTo(self.bioLabel.snp.trailing)
            $0.height.equalTo(21)
        }
        
        self.addSubview(self.bottomContainer)
        self.bottomContainer.snp.makeConstraints {
            self.bottomContainerTopToBioLabelConstraint = $0.top.equalTo(self.bioLabel.snp.bottom).offset(Layout.bioBottomInset).constraint
            $0.leading.equalToSuperview().offset(Layout.horizontalInset)
            $0.height.equalTo(Layout.bottomContainerHeight)
        }
        
        self.addSubview(self.updateProfileButton)
        self.updateProfileButton.snp.makeConstraints {
            $0.top.equalTo(self.bottomContainer.snp.bottom)
            $0.bottom.equalToSuperview().offset(-Layout.actionButtonBottomInset)
            $0.leading.equalToSuperview().offset(Layout.horizontalInset)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalInset)
            $0.height.equalTo(Layout.actionButtonHeight)
        }
        
        self.addSubview(self.followButton)
        self.followButton.snp.makeConstraints {
            $0.top.equalTo(self.bottomContainer.snp.bottom)
            $0.bottom.equalToSuperview().offset(-Layout.actionButtonBottomInset)
            $0.leading.equalToSuperview().offset(Layout.horizontalInset)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalInset)
            $0.height.equalTo(Layout.actionButtonHeight)
        }
        
        self.addSubview(self.unBlockButton)
        self.unBlockButton.snp.makeConstraints {
            $0.top.equalTo(self.bottomContainer.snp.bottom)
            $0.bottom.equalToSuperview().offset(-Layout.actionButtonBottomInset)
            $0.leading.equalToSuperview().offset(Layout.horizontalInset)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalInset)
            $0.height.equalTo(Layout.actionButtonHeight)
        }
    }
    
    
    // MARK: public func
    
    func setModel(_ model: ProfileInfo, isBioExpanded: Bool, width: CGFloat) {
        
        self.model = model
        self.isBioExpanded = isBioExpanded
        
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
        
        let bioState = Self.bioState(
            for: model.profileBio,
            width: width,
            isExpanded: isBioExpanded
        )
        self.bioLabel.numberOfLines = isBioExpanded ? 0 : Int(Layout.bioMaximumLines)
        self.bioLabel.lineBreakMode = isBioExpanded ? .byWordWrapping : .byTruncatingTail
        self.bioLabel.text = bioState.text
        self.bioLabel.typography = Self.bioTypography
        self.bioLabel.isHidden = bioState.isHidden
        self.bioLabelHeightConstraint?.update(offset: bioState.visibleTextHeight)
        self.shouldShowBioMoreButton = bioState.showsMoreButton
        self.bioMoreButton.isHidden = bioState.showsMoreButton == false || isBioExpanded
        
        var contents: [(content: ProfileInfo.Content, count: String)] {
            var contents: [(content: ProfileInfo.Content, count: String)] = []
            
            contents.append((.card, model.cardCnt))
            contents.append((.follower, model.followerCnt))
            contents.append((.following, model.followingCnt))
            
            return contents
        }
        self.setupItems(contents)
        
        self.followButton.isHidden = true
        self.unBlockButton.isHidden = true
        self.updateProfileButton.isHidden = model.isAlreadyFollowing != nil
        if let isAlreadyFollowing = model.isAlreadyFollowing, let isBlocked = model.isBlocked {
            
            self.followButton.isHidden = isBlocked
            self.unBlockButton.isHidden = isBlocked == false
            
            self.updateButton(isAlreadyFollowing)
        }
    }
    
    func expandBio(width: CGFloat) {
        guard self.bioLabel.isHidden == false else { return }
        
        self.isBioExpanded = true
        let bioState = Self.bioState(
            for: self.model.profileBio,
            width: width,
            isExpanded: true
        )
        self.bioLabel.numberOfLines = 0
        self.bioLabel.lineBreakMode = .byWordWrapping
        self.bioLabel.text = bioState.text
        self.bioLabel.typography = Self.bioTypography
        self.bioLabelHeightConstraint?.update(offset: bioState.visibleTextHeight)
        self.bioMoreButton.isHidden = true
        
        UIView.performWithoutAnimation {
            self.layoutIfNeeded()
        }
    }
    
    func showBioMoreButton() {
        guard self.shouldShowBioMoreButton else { return }
        self.isBioExpanded = false
        let bioState = Self.bioState(
            for: self.model.profileBio,
            width: self.bounds.width > 0 ? self.bounds.width : UIScreen.main.bounds.width,
            isExpanded: false
        )
        self.bioLabel.numberOfLines = Int(Layout.bioMaximumLines)
        self.bioLabel.lineBreakMode = .byTruncatingTail
        self.bioLabel.text = bioState.text
        self.bioLabel.typography = Self.bioTypography
        self.bioLabelHeightConstraint?.update(offset: bioState.visibleTextHeight)
        self.bioMoreButton.isHidden = false
        
        UIView.performWithoutAnimation {
            self.layoutIfNeeded()
        }
    }
    
    /// 상대방 프로필 일 때만 사용
    func updateButton(_ isFollowing: Bool) {
        
        self.followButton.title = isFollowing ? Text.followingButtonTitle : Text.followButtonTitle
        self.followButton.foregroundColor = isFollowing ? .som.v2.gray600 : .som.v2.white
        self.followButton.backgroundColor = isFollowing ? .som.v2.gray100 : .som.v2.black
    }
    
    static func height(for model: ProfileInfo, width: CGFloat, isBioExpanded: Bool) -> CGFloat {
        let bioState = self.bioState(for: model.profileBio, width: width, isExpanded: isBioExpanded)
        
        return Layout.topContainerHeight
            + bioState.height
            + Layout.bottomContainerHeight
            + Layout.actionButtonHeight
            + Layout.actionButtonBottomInset
    }
}

private extension ProfileUserViewCell {
    
    struct BioState {
        let text: String?
        let isHidden: Bool
        let showsMoreButton: Bool
        let height: CGFloat
        let visibleTextHeight: CGFloat
    }
    
    static func bioState(for bio: String?, width: CGFloat, isExpanded: Bool) -> BioState {
        let trimmedText = bio?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let text = trimmedText, text.isEmpty == false else {
            return BioState(text: nil, isHidden: true, showsMoreButton: false, height: 0, visibleTextHeight: 0)
        }
        
        let resolvedWidth = width > 0 ? width : UIScreen.main.bounds.width
        let availableWidth = max(resolvedWidth - (Layout.horizontalInset * 2), 0)
        let measuredTextHeight = Self.bioTypography.textBoundingHeight(for: text, width: availableWidth)
        let fullLineCount = max(ceil(measuredTextHeight / Self.bioTypography.lineHeight), 1)
        let fullTextHeight = fullLineCount * Self.bioTypography.lineHeight
        let collapsedTextHeight = Self.bioTypography.lineHeight * Layout.bioMaximumLines
        let showsMoreButton = fullTextHeight > collapsedTextHeight
        let visibleTextHeight = isExpanded ? fullTextHeight : min(fullTextHeight, collapsedTextHeight)
        
        return BioState(
            text: text,
            isHidden: false,
            showsMoreButton: showsMoreButton,
            height: Layout.bioTopInset + visibleTextHeight + Layout.bioBottomInset,
            visibleTextHeight: visibleTextHeight
        )
    }
    
    func updateBioMoreButtonVisibility() {
        guard self.bioLabel.isHidden == false else {
            self.bioMoreButton.isHidden = true
            return
        }
        
        guard self.isBioExpanded == false else {
            self.bioMoreButton.isHidden = true
            return
        }
        
        let shouldShowMoreButton = self.shouldShowBioMoreButton
        self.bioMoreButton.isHidden = shouldShowMoreButton == false
        
        UIView.performWithoutAnimation {
            self.layoutIfNeeded()
        }
    }
    
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
    
    @objc
    func didTapBioMoreButton() {
        self.bioMoreButtonDidTap.accept(())
    }
}
