//
//  PushNotiSettingsViewController.swift
//  SOOUM
//
//  Created by 오현식 on 3/7/26.
//

import UIKit

import SnapKit
import Then

import ReactorKit
import RxSwift

final class PushNotiSettingsViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let navigationTitle: String = "알림 설정"
        
        static let serviceHeaderTitle: String = "서비스 이용 알림"
        static let commentByWrittenCard: String = "작성한 카드의 댓글"
        static let likeByWrittenCard: String = "작성한 카드의 좋아요"
        static let newCardByFollowedUser: String = "팔로우한 사람의 새로운 카드"
        static let newFollower: String = "새로운 팔로워"
        static let newCommentByViewedCard: String = "조회한 카드의 새로운 댓글"
        static let popularCardOrContentsSuggestion: String = "인기카드 등 콘텐츠 추천"
        static let favoriteTag: String = "태그 알림"
        static let favoriteTagGuideText: String = "관심 태그가 포함된 카드가 올라온 경우"
        static let postingBlocked: String = "이용 제한 안내"
        static let postingBlockedGuideText: String = "신고된 카드로 인해 카드 추가 기능이 제한된 경우"
        
        static let marketingHeaderTitle: String = "혜택, 이벤트 알림"
        static let newFeatureAndUpdates: String = "신규기능/업데이트 소식"
        
        static let turnOffMarketingDialogTitle: String = "알림을 끄시겠어요?"
        static let turnOffMarketingDialogMessage: String = "유용한 정보나 이벤트 알림을 받지 못할 수도 있어요."
        static let cancelActionButtonTitle: String = "취소"
        static let turnOffMarketingActionButtonTitle: String = "알림 끄기"
    }
    
    
    // MARK: views
    
    private let scrollView = UIScrollView().then {
        $0.backgroundColor = .som.v2.white
        
        $0.isScrollEnabled = true
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let serviceHeaderView = PushNotiSettingsHeaderView(title: Text.serviceHeaderTitle)
    private let commentByWrittenCardView = PushNotiSettingsCellView(title: Text.commentByWrittenCard)
    private let likeByWrittenCard = PushNotiSettingsCellView(title: Text.likeByWrittenCard)
    private let newCardByFollowedUserView = PushNotiSettingsCellView(title: Text.newCardByFollowedUser)
    private let newFollowerView = PushNotiSettingsCellView(title: Text.newFollower)
    private let newCommentByViewedCardView = PushNotiSettingsCellView(title: Text.newCommentByViewedCard)
    private let popularCardOrContentsSuggestion = PushNotiSettingsCellView(title: Text.popularCardOrContentsSuggestion)
    private let favoriteTagView = PushNotiSettingsCellView(title: Text.favoriteTag, message: Text.favoriteTagGuideText)
    private let postingBlockedView = PushNotiSettingsCellView(title: Text.postingBlocked, message: Text.postingBlockedGuideText)
    
    private let marketingHeaderView = PushNotiSettingsHeaderView(title: Text.marketingHeaderTitle)
    private let newFeatureAndUpdatesView = PushNotiSettingsCellView(title: Text.newFeatureAndUpdates)
    
    
    // MARK: Override variables
    
    override var bottomToastMessageOffset: CGFloat {
        /// bottom safe layout guide + padding
        return 34 + 8
    }
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
    }
    
    override func setupConstraints() {
        
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
        
        let seperator = UIView().then {
            $0.backgroundColor = .som.v2.gray100
        }
        
        let container = UIStackView(arrangedSubviews: [
            self.serviceHeaderView,
            self.commentByWrittenCardView,
            self.likeByWrittenCard,
            self.newCardByFollowedUserView,
            self.newFollowerView,
            self.newCommentByViewedCardView,
            self.popularCardOrContentsSuggestion,
            self.favoriteTagView,
            self.postingBlockedView,
            seperator,
            self.marketingHeaderView,
            self.newFeatureAndUpdatesView
        ]).then {
            $0.axis = .vertical
            $0.alignment = .fill
        }
        self.scrollView.addSubview(container)
        container.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        seperator.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.size.width)
            $0.height.equalTo(16)
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: PushNotiSettingsViewReactor) {
        
        // Action
        self.commentByWrittenCardView.rx.didSelect
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { _ in HapticHelper.shared.trigger(.selection) })
            .map {
                let curr = reactor.currentState.pushNotistatus
                return PushNotiStatusInfo(
                    commentCardNotify: !curr.commentCardNotify,
                    cardLikeNotify: curr.cardLikeNotify,
                    followUserCardNotify: curr.followUserCardNotify,
                    newFollowerNotify: curr.newFollowerNotify,
                    cardNewCommentNotify: curr.cardNewCommentNotify,
                    recommendedContentNotify: curr.recommendedContentNotify,
                    favoriteTagNotify: curr.favoriteTagNotify,
                    serviceUpdateNotify: curr.serviceUpdateNotify,
                    policyViolationNotify: curr.policyViolationNotify
                )
            }
            .map(Reactor.Action.updatePushNotiStatus)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.likeByWrittenCard.rx.didSelect
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { _ in HapticHelper.shared.trigger(.selection) })
            .map {
                let curr = reactor.currentState.pushNotistatus
                return PushNotiStatusInfo(
                    commentCardNotify: curr.commentCardNotify,
                    cardLikeNotify: !curr.cardLikeNotify,
                    followUserCardNotify: curr.followUserCardNotify,
                    newFollowerNotify: curr.newFollowerNotify,
                    cardNewCommentNotify: curr.cardNewCommentNotify,
                    recommendedContentNotify: curr.recommendedContentNotify,
                    favoriteTagNotify: curr.favoriteTagNotify,
                    serviceUpdateNotify: curr.serviceUpdateNotify,
                    policyViolationNotify: curr.policyViolationNotify
                )
            }
            .map(Reactor.Action.updatePushNotiStatus)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.newCardByFollowedUserView.rx.didSelect
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { _ in HapticHelper.shared.trigger(.selection) })
            .map {
                let curr = reactor.currentState.pushNotistatus
                return PushNotiStatusInfo(
                    commentCardNotify: curr.commentCardNotify,
                    cardLikeNotify: curr.cardLikeNotify,
                    followUserCardNotify: !curr.followUserCardNotify,
                    newFollowerNotify: curr.newFollowerNotify,
                    cardNewCommentNotify: curr.cardNewCommentNotify,
                    recommendedContentNotify: curr.recommendedContentNotify,
                    favoriteTagNotify: curr.favoriteTagNotify,
                    serviceUpdateNotify: curr.serviceUpdateNotify,
                    policyViolationNotify: curr.policyViolationNotify
                )
            }
            .map(Reactor.Action.updatePushNotiStatus)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.newFollowerView.rx.didSelect
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { _ in HapticHelper.shared.trigger(.selection) })
            .map {
                let curr = reactor.currentState.pushNotistatus
                return PushNotiStatusInfo(
                    commentCardNotify: curr.commentCardNotify,
                    cardLikeNotify: curr.cardLikeNotify,
                    followUserCardNotify: curr.followUserCardNotify,
                    newFollowerNotify: !curr.newFollowerNotify,
                    cardNewCommentNotify: curr.cardNewCommentNotify,
                    recommendedContentNotify: curr.recommendedContentNotify,
                    favoriteTagNotify: curr.favoriteTagNotify,
                    serviceUpdateNotify: curr.serviceUpdateNotify,
                    policyViolationNotify: curr.policyViolationNotify
                )
            }
            .map(Reactor.Action.updatePushNotiStatus)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.newCommentByViewedCardView.rx.didSelect
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { _ in HapticHelper.shared.trigger(.selection) })
            .map {
                let curr = reactor.currentState.pushNotistatus
                return PushNotiStatusInfo(
                    commentCardNotify: curr.commentCardNotify,
                    cardLikeNotify: curr.cardLikeNotify,
                    followUserCardNotify: curr.followUserCardNotify,
                    newFollowerNotify: curr.newFollowerNotify,
                    cardNewCommentNotify: !curr.cardNewCommentNotify,
                    recommendedContentNotify: curr.recommendedContentNotify,
                    favoriteTagNotify: curr.favoriteTagNotify,
                    serviceUpdateNotify: curr.serviceUpdateNotify,
                    policyViolationNotify: curr.policyViolationNotify
                )
            }
            .map(Reactor.Action.updatePushNotiStatus)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.popularCardOrContentsSuggestion.rx.didSelect
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { _ in HapticHelper.shared.trigger(.selection) })
            .map {
                let curr = reactor.currentState.pushNotistatus
                return PushNotiStatusInfo(
                    commentCardNotify: curr.commentCardNotify,
                    cardLikeNotify: curr.cardLikeNotify,
                    followUserCardNotify: curr.followUserCardNotify,
                    newFollowerNotify: curr.newFollowerNotify,
                    cardNewCommentNotify: curr.cardNewCommentNotify,
                    recommendedContentNotify: !curr.recommendedContentNotify,
                    favoriteTagNotify: curr.favoriteTagNotify,
                    serviceUpdateNotify: curr.serviceUpdateNotify,
                    policyViolationNotify: curr.policyViolationNotify
                )
            }
            .map(Reactor.Action.updatePushNotiStatus)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.favoriteTagView.rx.didSelect
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { _ in HapticHelper.shared.trigger(.selection) })
            .map {
                let curr = reactor.currentState.pushNotistatus
                return PushNotiStatusInfo(
                    commentCardNotify: curr.commentCardNotify,
                    cardLikeNotify: curr.cardLikeNotify,
                    followUserCardNotify: curr.followUserCardNotify,
                    newFollowerNotify: curr.newFollowerNotify,
                    cardNewCommentNotify: curr.cardNewCommentNotify,
                    recommendedContentNotify: curr.recommendedContentNotify,
                    favoriteTagNotify: !curr.favoriteTagNotify,
                    serviceUpdateNotify: curr.serviceUpdateNotify,
                    policyViolationNotify: curr.policyViolationNotify
                )
            }
            .map(Reactor.Action.updatePushNotiStatus)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.postingBlockedView.rx.didSelect
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { _ in HapticHelper.shared.trigger(.selection) })
            .map {
                let curr = reactor.currentState.pushNotistatus
                return PushNotiStatusInfo(
                    commentCardNotify: curr.commentCardNotify,
                    cardLikeNotify: curr.cardLikeNotify,
                    followUserCardNotify: curr.followUserCardNotify,
                    newFollowerNotify: curr.newFollowerNotify,
                    cardNewCommentNotify: curr.cardNewCommentNotify,
                    recommendedContentNotify: curr.recommendedContentNotify,
                    favoriteTagNotify: curr.favoriteTagNotify,
                    serviceUpdateNotify: curr.serviceUpdateNotify,
                    policyViolationNotify: !curr.policyViolationNotify
                )
            }
            .map(Reactor.Action.updatePushNotiStatus)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.newFeatureAndUpdatesView.rx.didSelect
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { _ in HapticHelper.shared.trigger(.selection) })
            .subscribe(with: self) { object, _ in
                let curr = reactor.currentState.pushNotistatus
                if curr.serviceUpdateNotify {
                    object.showMarketingDialog(with: reactor)
                } else {
                    let new = PushNotiStatusInfo(
                        commentCardNotify: curr.commentCardNotify,
                        cardLikeNotify: curr.cardLikeNotify,
                        followUserCardNotify: curr.followUserCardNotify,
                        newFollowerNotify: curr.newFollowerNotify,
                        cardNewCommentNotify: curr.cardNewCommentNotify,
                        recommendedContentNotify: curr.recommendedContentNotify,
                        favoriteTagNotify: curr.favoriteTagNotify,
                        serviceUpdateNotify: true,
                        policyViolationNotify: curr.policyViolationNotify
                    )
                    reactor.action.onNext(.updatePushNotiStatus(new))
                }
            }
            .disposed(by: self.disposeBag)
        
        // State\
        reactor.state.map(\.pushNotistatus)
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, pushNotiStatus in
                object.commentByWrittenCardView.toggleSwitch.setOn(
                    pushNotiStatus.commentCardNotify,
                    animated: true
                )
                object.likeByWrittenCard.toggleSwitch.setOn(
                    pushNotiStatus.cardLikeNotify,
                    animated: true
                )
                object.newCardByFollowedUserView.toggleSwitch.setOn(
                    pushNotiStatus.followUserCardNotify,
                    animated: true
                )
                object.newFollowerView.toggleSwitch.setOn(
                    pushNotiStatus.newFollowerNotify,
                    animated: true
                )
                object.newCommentByViewedCardView.toggleSwitch.setOn(
                    pushNotiStatus.cardNewCommentNotify,
                    animated: true
                )
                object.popularCardOrContentsSuggestion.toggleSwitch.setOn(
                    pushNotiStatus.recommendedContentNotify,
                    animated: true
                )
                object.favoriteTagView.toggleSwitch.setOn(
                    pushNotiStatus.favoriteTagNotify,
                    animated: true
                )
                object.postingBlockedView.toggleSwitch.setOn(
                    pushNotiStatus.policyViolationNotify,
                    animated: true
                )
                object.newFeatureAndUpdatesView.toggleSwitch.setOn(
                    pushNotiStatus.serviceUpdateNotify,
                    animated: true
                )
            }
            .disposed(by: self.disposeBag)
    }
}


// MARK: Show dialog

extension PushNotiSettingsViewController {
    
    func showMarketingDialog(with reactor: PushNotiSettingsViewReactor) {
        
        let cancelAction = SOMDialogAction(
            title: Text.cancelActionButtonTitle,
            style: .gray,
            action: {
                SOMDialogViewController.dismiss()
            }
        )
        
        let turnOffAction = SOMDialogAction(
            title: Text.turnOffMarketingActionButtonTitle,
            style: .primary,
            action: {
                SOMDialogViewController.dismiss {
                    let curr = reactor.currentState.pushNotistatus
                    let pushNotiStatus = PushNotiStatusInfo(
                        commentCardNotify: curr.commentCardNotify,
                        cardLikeNotify: curr.cardLikeNotify,
                        followUserCardNotify: curr.followUserCardNotify,
                        newFollowerNotify: curr.newFollowerNotify,
                        cardNewCommentNotify: curr.cardNewCommentNotify,
                        recommendedContentNotify: curr.recommendedContentNotify,
                        favoriteTagNotify: curr.favoriteTagNotify,
                        serviceUpdateNotify: false,
                        policyViolationNotify: curr.policyViolationNotify
                    )
                    reactor.action.onNext(.updatePushNotiStatus(pushNotiStatus))
                }
            }
        )
        
        SOMDialogViewController.show(
            title: Text.turnOffMarketingDialogTitle,
            message: Text.turnOffMarketingDialogMessage,
            textAlignment: .left,
            actions: [cancelAction, turnOffAction]
        )
    }
}
