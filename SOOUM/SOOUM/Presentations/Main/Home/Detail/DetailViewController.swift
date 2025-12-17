//
//  DetailViewController.swift
//  SOOUM
//
//  Created by 오현식 on 10/1/24.
//

import UIKit

import SnapKit
import Then

import SwiftEntryKit

import ReactorKit
import RxCocoa
import RxSwift

class DetailViewController: BaseNavigationViewController, View {

     enum Text {
         
         static let feedDetailNavigationTitle: String = "카드"
         static let commentDetailNavigationTitle: String = "댓글카드"
         static let deletedNavigationTitle: String = "삭제된 카드"
         
         static let deleteDialogTitle: String = "카드를 삭제하시겠어요?"
         static let deleteDialogMessage: String = "삭제한 카드는 영구적으로 삭제되며, 복구할 수 없습니다."
         
         static let deletePungDialogTitle: String = "시간 제한 카드를 삭제할까요?"
         static let deletePungDialogMessage: String = "카드를 삭제하면,\n답카드가 자동으로 삭제되지 않아요"
         
         static let deletedCardDialogTitle: String = "삭제된 카드예요"
         
         static let bottomFloatEntryName: String = "bottomFloatEntryName"
         static let bottomToastEntryName: String = "bottomToastEntryName"
         
         static let blockButtonFloatActionTitle: String = "차단하기"
         static let unblockButtonFloatActionTitle: String = "차단해제"
         static let reportButtonFloatActionTitle: String = "신고하기"
         static let deleteButtonFloatActionTitle: String = "삭제"
         
         static let blockToastLeadingTitle: String = "앞으로 "
         static let blockToastTrailingTitle: String = "의 카드가 목록에서 보이지 않습니다"
         
         static let blockDialogTitle: String = "차단하시겠어요?"
         static let blockDialogMessage: String = "의 모든 카드를 볼 수 없어요."
         
         static let confirmActionTitle: String = "확인"
         static let cancelActionTitle: String = "취소"
         
         static let eventCardTitle: String = "event"
     }
    
    
    // MARK: Views
     
     private let leftHomeButton = SOMButton().then {
         $0.image = .init(.icon(.v2(.outlined(.home))))
         $0.foregroundColor = .som.black
     }
    
    private let rightMoreButton = SOMButton().then {
        $0.image = .init(.icon(.v2(.outlined(.more))))
        $0.foregroundColor = .som.black
    }
    
    private let rightDeleteButton = SOMButton().then {
        $0.image = .init(.icon(.v2(.outlined(.delete_full))))
        $0.foregroundColor = .som.black
    }
    
    private let pungView = PungView().then {
        $0.isHidden = true
    }
     
     private let flowLayout = UICollectionViewFlowLayout().then {
         $0.scrollDirection = .vertical
     }
     
     private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: self.flowLayout
     ).then {
         $0.alwaysBounceVertical = true
         $0.showsVerticalScrollIndicator = false
         $0.showsHorizontalScrollIndicator = false
         
         $0.contentInsetAdjustmentBehavior = .never
         
         $0.refreshControl = SOMRefreshControl()
         
         $0.register(DetailViewCell.self, forCellWithReuseIdentifier: "cell")
         $0.register(
            DetailViewFooter.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "footer"
         )
         
         $0.dataSource = self
         $0.delegate = self
     }
    
    private let floatingButton = FloatingButton()
    
    
    // MARK: Variables
     
    private var detailCard: DetailCardInfo = .defaultValue
    private var commentCards: [BaseCardInfo] = []
     
    private var isDeleted = false
    
    private var initialOffset: CGFloat = 0
    private var currentOffset: CGFloat = 0
    private var isRefreshEnabled: Bool = true
    private var shouldRefreshing: Bool = false
    
    private var actions: [SOMBottomFloatView.FloatAction] = []
    
    
    // MARK: Override variables
    
    override var bottomToastMessageOffset: CGFloat {
        /// bottom safe layout guide + floating button height + padding
        return 34 + 56 + 8
    }
    
     
     // MARK: Override func
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.reloadDetaildata(_:)),
            name: .reloadDetailData,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.deletedCommentCardWithId(_:)),
            name: .deletedCommentCardWithId,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updatedReportState(_:)),
            name: .updatedReportState,
            object: nil
        )
    }
     
     override func setupNaviBar() {
         super.setupNaviBar()
         
         let isDeleted = self.reactor?.currentState.isDeleted ?? false
         self.navigationBar.setRightButtons([isDeleted ? self.rightDeleteButton : self.rightMoreButton])
     }
     
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
        
        self.view.addSubview(self.pungView)
        self.pungView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.centerX.equalToSuperview()
        }
        
        self.view.addSubview(self.floatingButton)
        self.floatingButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            $0.trailing.equalToSuperview().offset(-16)
        }
     }
     
     
     // MARK: - Bind
     
    func bind(reactor: DetailViewReactor) {
        
        // 댓글카드 작성 전환
        self.floatingButton.backgoundButton.rx.throttleTap(.seconds(3))
            .map { _ in Reactor.Action.willPushToWrite(.floating) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        let detailCard = reactor.state.map(\.detailCard).distinctUntilChanged().filterNil().share()
        let commentCards = reactor.state.map(\.commentCards).distinctUntilChanged().filterNil().share()
        let isFeed = reactor.state.map(\.isFeed).share()
        let isBlocked = reactor.state.map(\.isBlocked).distinctUntilChanged().share()
        let isReported = reactor.state.map(\.isReported).distinctUntilChanged().share()
        
        let rightMoreButtonDidTap = self.rightMoreButton.rx.throttleTap.share()
        // 더보기 버튼 액션
        rightMoreButtonDidTap
            .withLatestFrom(detailCard)
            .filter { $0.isOwnCard }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, _ in
                
                object.actions = [
                    .init(
                        title: Text.deleteButtonFloatActionTitle,
                        image: .init(.icon(.v2(.outlined(.trash)))),
                        foregroundColor: .som.v2.rMain,
                        action: { [weak object] in
                            SwiftEntryKit.dismiss(.specific(entryName: Text.bottomFloatEntryName)) {
                                
                                object?.showDeleteCardDialog()
                            }
                        }
                    )
                ]
                
                let bottomFloatView = SOMBottomFloatView(actions: object.actions)
                
                var wrapper: SwiftEntryKitViewWrapper = bottomFloatView.sek
                wrapper.entryName = Text.bottomFloatEntryName
                wrapper.showBottomFloat(screenInteraction: .dismiss)
            }
            .disposed(by: self.disposeBag)
        
        rightMoreButtonDidTap
            .withLatestFrom(Observable.combineLatest(detailCard, isBlocked, isReported))
            .filter { $0.0.isOwnCard == false }
            .map { ($0.0.nickname, $0.1, $0.2) }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, combined in
                
                let (nickname, isBlocked, isReported) = combined
                
                object.actions = [
                    .init(
                        title: isBlocked ? Text.blockButtonFloatActionTitle : Text.unblockButtonFloatActionTitle,
                        image: .init(.icon(.v2(.outlined(isBlocked ? .hide : .eye)))),
                        action: { [weak object] in
                            SwiftEntryKit.dismiss(.specific(entryName: Text.bottomFloatEntryName)) {
                                if isBlocked {
                                    object?.showBlockedUserDialog(nickname: nickname) {
                                        reactor.action.onNext(.block(isBlocked: true))
                                    }
                                } else {
                                    reactor.action.onNext(.block(isBlocked: false))
                                }
                            }
                        }
                    ),
                    .init(
                        title: Text.reportButtonFloatActionTitle,
                        image: .init(.icon(.v2(.outlined(.flag)))),
                        foregroundColor: .som.v2.rMain,
                        isEnabled: isReported == false,
                        action: { [weak object] in
                            
                            SwiftEntryKit.dismiss(.specific(entryName: Text.bottomFloatEntryName)) {
                                
                                let reportViewController = ReportViewController()
                                reportViewController.reactor = reactor.reactorForReport()
                                object?.navigationPush(reportViewController, animated: true)
                            }
                        }
                    )
                ]
                
                let bottomFloatView = SOMBottomFloatView(actions: object.actions)
                
                var wrapper: SwiftEntryKitViewWrapper = bottomFloatView.sek
                wrapper.entryName = Text.bottomFloatEntryName
                wrapper.showBottomFloat(screenInteraction: .dismiss)
            }
            .disposed(by: self.disposeBag)
        
        // 카드 삭제 후 X 버튼 액션
        self.rightDeleteButton.rx.throttleTap(.seconds(3))
            .subscribe(with: self) { object, _ in
                object.navigationPop(animated: false)
            }
            .disposed(by: self.disposeBag)
        
        // 댓글카드 홈 버튼 액션
        self.leftHomeButton.rx.throttleTap(.seconds(3))
            .subscribe(with: self) { object, _ in
                object.navigationPopToRoot(animated: false)
            }
            .disposed(by: self.disposeBag)
        
        // 카드 정보 업데이트 시 전역으로 알림
        self.rx.viewDidDisappear
            .subscribe(with: self) { object, _ in
                /// 좋아요 업데이트 후 뒤로갔을 때, 좋아요 업데이트 알림
                if reactor.currentState.isLiked {
                    NotificationCenter.default.post(
                        name: .addedFavoriteWithCardId,
                        object: nil,
                        userInfo: [
                            "cardId": object.detailCard.id,
                            "addedFavorite": object.detailCard.isLike
                        ]
                    )
                }
                /// 사용자 차단 후 뒤로 갔을 때, 차단된 사용자 카드 숨김 알림
                if reactor.initialState.isBlocked != reactor.currentState.isBlocked {
                    NotificationCenter.default.post(
                        name: .updatedBlockUser,
                        object: nil,
                        userInfo: ["isBlocked": !reactor.currentState.isBlocked]
                    )
                }
            }
            .disposed(by: self.disposeBag)
        
        
        // Action
        self.rx.viewDidLoad
            .map { _ in Reactor.Action.landing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        let isRefreshing = reactor.state.map(\.isRefreshing).distinctUntilChanged().share()
        self.collectionView.refreshControl?.rx.controlEvent(.valueChanged)
            .withLatestFrom(isRefreshing)
            .filter { $0 == false }
            .delay(.milliseconds(1000), scheduler: MainScheduler.instance)
            .map { _ in Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        isRefreshing
            .observe(on: MainScheduler.asyncInstance)
            .filter { $0 == false }
            .subscribe(with: self.collectionView) { collectionView, _ in
                collectionView.refreshControl?.endRefreshing()
            }
            .disposed(by: self.disposeBag)
        
        isFeed
            .distinctUntilChanged()
            .filterNil()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, isFeed in
                object.navigationBar.title = isFeed ?
                Text.feedDetailNavigationTitle :
                Text.commentDetailNavigationTitle
                
                if isFeed == false {
                    object.navigationBar.setLeftButtons([object.leftHomeButton])
                }
            }
            .disposed(by: self.disposeBag)
        
        detailCard
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, detailCard in
                object.detailCard = detailCard
                
                object.pungView.subscribePungTime(detailCard.storyExpirationTime)
                object.pungView.isHidden = detailCard.storyExpirationTime == nil
                
                UIView.performWithoutAnimation {
                    object.collectionView.reloadData()
                }
            }
            .disposed(by: self.disposeBag)
        
        commentCards
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, commentCards in
                object.commentCards = commentCards
                
                UIView.performWithoutAnimation {
                    object.collectionView.reloadData()
                }
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.willPushToDetailEnabled)
            .distinctUntilChanged(reactor.canPushToDetail)
            .filterNil()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, willPushToDetailEnabled in
                let detailViewController = DetailViewController()
                detailViewController.reactor = reactor.reactorForPush(
                    willPushToDetailEnabled.prevCardId,
                    hasDeleted: willPushToDetailEnabled.isDeleted
                )
                object.navigationPush(detailViewController, animated: true) { _ in
                    reactor.action.onNext(.cleanup)
                    
                    GAHelper.shared.logEvent(
                        event: GAEvent.DetailView.cardDetailView_tracePath_click(
                            previous_path: .detail
                        )
                    )
                }
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.willPushToWriteEnabled)
            .distinctUntilChanged(reactor.canPushToWrite)
            .filterNil()
            .filter { $0.isDeleted }
            .map(\.enterTo)
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, enterTo in
                let writeCardViewController = WriteCardViewController()
                writeCardViewController.reactor = reactor.reactorForWriteCard()
                object.navigationPush(
                    writeCardViewController,
                    animated: true
                ) { _ in
                    reactor.action.onNext(.cleanup)
                    
                    if enterTo == .icon {
                        GAHelper.shared.logEvent(
                            event: GAEvent.DetailView.moveToCreateCommentCardView_icon_btn_click
                        )
                    } else {
                        GAHelper.shared.logEvent(
                            event: GAEvent.DetailView.moveToCreateCommentCardView_floating_btn_click
                        )
                        if reactor.currentState.detailCard?
                            .cardImgName
                            .contains(Text.eventCardTitle) == true {
                            
                            GAHelper.shared.logEvent(
                                event: GAEvent.DetailView.moveToCreateCommentCardView_withEventImg_floating_btn_click
                            )
                        }
                    }
                }
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isLiked)
            .distinctUntilChanged()
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, _ in
                
                let updated: DetailCardInfo
                if object.detailCard.isLike {
                    
                    let updatedLikeCnt = object.detailCard.likeCnt - 1
                    updated = object.detailCard.updateLikeCnt(updatedLikeCnt, with: false)
                } else {
                    
                    let updatedLikeCnt = object.detailCard.likeCnt + 1
                    updated = object.detailCard.updateLikeCnt(updatedLikeCnt, with: true)
                }
                
                object.detailCard = updated
                
                UIView.performWithoutAnimation {
                    object.collectionView.reloadData()
                }
            }
            .disposed(by: self.disposeBag)
        
        isBlocked
            .filter { $0 == false }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, _ in
                
                let title = Text.blockToastLeadingTitle + object.detailCard.nickname + Text.blockToastTrailingTitle
                let actions = [
                    SOMBottomToastView.ToastAction(title: Text.cancelActionTitle, action: {
                        SwiftEntryKit.dismiss(.specific(entryName: Text.bottomToastEntryName)) {
                            reactor.action.onNext(.block(isBlocked: false))
                        }
                    })
                ]
                let bottomToastView = SOMBottomToastView(title: title, actions: actions)
                
                var wrapper: SwiftEntryKitViewWrapper = bottomToastView.sek
                wrapper.entryName = Text.bottomToastEntryName
                wrapper.showBottomToast(verticalOffset: 34 + 56 + 8)
            }
            .disposed(by: self.disposeBag)
        
        Observable.combineLatest(
            reactor.state.map(\.isDeleted).distinctUntilChanged().filter { $0 },
            commentCards.map(\.isEmpty),
            isFeed,
            reactor.state.map(\.hasErrors)
        )
        .map { ($0.1, $0.2, $0.3) }
        .observe(on: MainScheduler.asyncInstance)
        .subscribe(with: self) { object, combined in
            
            object.navigationBar.title = Text.deletedNavigationTitle
            object.navigationBar.setRightButtons([object.rightDeleteButton])
            
            object.floatingButton.removeFromSuperview()
            
            object.isDeleted = true
            
            UIView.performWithoutAnimation {
                object.collectionView.reloadData()
            }
            
            let (isCommentEmpty, isFeed, errors) = combined
            
            guard let isFeed = isFeed else { return }
            
            if isFeed {
                NotificationCenter.default.post(
                    name: .deletedFeedCardWithId,
                    object: nil,
                    userInfo: ["cardId": reactor.selectedCardId, "isDeleted": true]
                )
            } else {
                NotificationCenter.default.post(
                    name: .addedCommentWithCardId,
                    object: nil,
                    userInfo: ["cardId": reactor.selectedCardId, "addedComment": false]
                )
                
                NotificationCenter.default.post(
                    name: .deletedCommentCardWithId,
                    object: nil,
                    userInfo: ["cardId": reactor.selectedCardId, "isDeleted": true]
                )
            }
            
            if case 410 = errors {
                object.showDeletedCardDialog {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak object] in
                        object?.navigationPopToRoot()
                    }
                }
                return
            }
            
            guard isCommentEmpty else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak object] in
                object?.navigationPop()
            }
        }
        .disposed(by: self.disposeBag)
    }
    
    
    // MARK: Objc func
    
    @objc
    private func reloadDetaildata(_ notification: Notification) {
        
        self.reactor?.action.onNext(.landing)
    }
    
    @objc
    private func deletedCommentCardWithId(_ notification: Notification) {
        
        guard let cardId = notification.userInfo?["cardId"] as? String,
            notification.userInfo?["isDeleted"] as? Bool == true
        else { return }
        
        guard self.reactor?.currentState.commentCards?.contains(where: { $0.id == cardId }) == true else { return }
        
        if let detailCard = self.reactor?.currentState.detailCard {
            let commentCnt = detailCard.commentCnt > 0 ? detailCard.commentCnt - 1 : 0
            self.reactor?.action.onNext(.updateDetail(detailCard.updateCommentCnt(commentCnt)))
        }
        
        var commentCards = self.reactor?.currentState.commentCards ?? []
        commentCards.removeAll(where: { $0.id == cardId })
        
        self.reactor?.action.onNext(.updateComments(commentCards))
    }
    
    @objc
    private func updatedReportState(_ notification: Notification) {
        
        self.reactor?.action.onNext(.updateReport(true))
    }
 }

extension DetailViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 1
    }
    
    func collectionView(
        _ collectionView: UICollectionView, 
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let cell: DetailViewCell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            as! DetailViewCell
    
        guard self.isDeleted == false else {
            cell.isDeleted()
            self.pungView.isDeleted()
            return cell
        }
        
        cell.setModels(self.detailCard)
        
        guard let reactor = self.reactor else { return cell }
        
        cell.memberInfoView.memberBackgroundButton.rx.throttleTap(.seconds(3))
            .subscribe(with: self) { object, _ in
                /// 내 프로필일 경우 탭 이동
                if object.detailCard.isOwnCard {
                    guard let navigationController = object.navigationController,
                        let tabBarController = navigationController.parent as? SOMTabBarController
                    else { return }
                    
                    tabBarController.didSelectedIndex(3)
                    navigationController.viewControllers.removeAll(where: { $0.isKind(of: HomeViewController.self) == false })
                } else {
                    let profileViewController = ProfileViewController()
                    profileViewController.reactor = reactor.reactorForProfile(
                        type: .other,
                        object.detailCard.memberId
                    )
                    object.navigationPush(profileViewController, animated: true)
                }
            }
            .disposed(by: cell.disposeBag)
        
        cell.tags.tagDidTap
            .throttle(.seconds(3), scheduler: MainScheduler.instance)
            .subscribe(with: self) { object, tagInfo in
                let tagCollectViewController = TagCollectViewController()
                tagCollectViewController.reactor = reactor.reactorForTagCollect(
                    with: tagInfo.id,
                    title: tagInfo.text
                )
                object.navigationPush(tagCollectViewController, animated: true) { _ in
                    GAHelper.shared.logEvent(
                        event: GAEvent.DetailView.cardDetailTag_btn_click(tag_name: tagInfo.text)
                    )
                }
            }
            .disposed(by: cell.disposeBag)
        
        cell.likeAndCommentView.likeBackgroundButton.rx.throttleTap
            .withLatestFrom(reactor.state.compactMap(\.detailCard).map(\.isLike))
            .subscribe(onNext: { isLike in
                reactor.action.onNext(.updateLike(!isLike))
            })
            .disposed(by: cell.disposeBag)
        
        cell.likeAndCommentView.commentBackgroundButton.rx.throttleTap(.seconds(3))
            .map { _ in Reactor.Action.willPushToWrite(.icon) }
            .bind(to: reactor.action)
            .disposed(by: cell.disposeBag)
        
        cell.prevCardBackgroundButton.rx.throttleTap(.seconds(3))
            .subscribe(with: self) { object, _ in
                guard let prevCardInfo = reactor.currentState.detailCard?.prevCardInfo else {
                    object.navigationPop()
                    return
                }
                /// 현재 쌓인 viewControllers 중 바로 이전 viewController가 전환해야 할 전글이라면 naviPop
                if let naviStackCount = object.navigationController?.viewControllers.count,
                   let prevViewController = object.navigationController?.viewControllers[naviStackCount - 2] as? Self,
                   prevViewController.reactor?.selectedCardId == prevCardInfo.prevCardId {
                    
                    object.navigationPop()
                } else {
                    
                    if prevCardInfo.isPrevCardDeleted {
                        let detailViewController = DetailViewController()
                        detailViewController.reactor = reactor.reactorForPush(
                            prevCardInfo.prevCardId,
                            hasDeleted: true
                        )
                        object.navigationPush(detailViewController, animated: true) { _ in
                            reactor.action.onNext(.cleanup)
                            
                            GAHelper.shared.logEvent(
                                event: GAEvent.DetailView.cardDetailView_tracePath_click(
                                    previous_path: .detail
                                )
                            )
                        }
                    } else {
                        reactor.action.onNext(.willPushToDetail(prevCardInfo.prevCardId))
                    }
                }
            }
            .disposed(by: cell.disposeBag)
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            
            let footer: DetailViewFooter = collectionView
                .dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "footer",
                    for: indexPath
                ) as! DetailViewFooter
            
            footer.setModels(self.commentCards)
            
            guard let reactor = self.reactor else { return footer }
            
            footer.didTap
                .subscribe(with: self) { object, selectedId in
                    let viewController = DetailViewController()
                    viewController.reactor = reactor.reactorForPush(selectedId)
                    object.navigationPush(viewController, animated: true)
                }
                .disposed(by: footer.disposeBag)
            
            footer.moreDisplay
                .subscribe(onNext: { lastId in
                    reactor.action.onNext(.moreFindForComment(lastId: lastId))
                })
                .disposed(by: footer.disposeBag)
            
            return footer
        } else {
            return .init(frame: .zero)
        }
    }
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width: CGFloat = UIScreen.main.bounds.width
        let height: CGFloat = 52 + (width - 16 * 2) + 44
        return CGSize(width: width, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        let width: CGFloat = UIScreen.main.bounds.width
        let cellHeight: CGFloat = 52 + (width - 16 * 2) + 44
        let height: CGFloat = collectionView.bounds.height - cellHeight
        return CGSize(width: width, height: height)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        
        // currentOffset <= 0 && isRefreshing == false 일 때, 테이블 뷰 새로고침 가능
        self.isRefreshEnabled = (offset <= 0) && (self.reactor?.currentState.isRefreshing == false)
        self.shouldRefreshing = false
        self.initialOffset = offset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        
        // 아래 -> 위 스크롤 막음
        guard offset <= self.initialOffset else {
            scrollView.contentOffset.y = 0
            return
        }
        
        // 당겨서 새로고침
        if self.isRefreshEnabled, offset < self.initialOffset,
           let refreshControl = self.collectionView.refreshControl as? SOMRefreshControl {
           
           refreshControl.updateProgress(
               offset: scrollView.contentOffset.y,
               topInset: scrollView.adjustedContentInset.top
           )
            
            let pulledOffset = self.initialOffset - offset
            /// refreshControl heigt + top padding
            let refreshingOffset: CGFloat = 44 + 12
            self.shouldRefreshing = abs(pulledOffset) >= refreshingOffset
        }
        
        self.currentOffset = offset
    }
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        
        if self.shouldRefreshing {
            self.collectionView.refreshControl?.beginRefreshingWithOffset(
                self.detailCard.storyExpirationTime == nil ? 0 : 23
            )
        }
    }
}

private extension DetailViewController {
    
    func showBlockedUserDialog(nickname: String, completion: (() -> Void)? = nil) {
        
        let cancelAction = SOMDialogAction(
            title: Text.cancelActionTitle,
            style: .gray,
            action: {
                SOMDialogViewController.dismiss()
            }
         )
         let blockAction = SOMDialogAction(
            title: Text.blockButtonFloatActionTitle,
            style: .primary,
            action: {
                SOMDialogViewController.dismiss {
                    completion?()
                }
            }
         )

         SOMDialogViewController.show(
            title: Text.blockDialogTitle,
            message: nickname + Text.blockDialogMessage,
            textAlignment: .left,
            actions: [cancelAction, blockAction]
         )
    }
    
    func showDeleteCardDialog() {
        
        guard let reactor = self.reactor else { return }
        
        let cancelAction = SOMDialogAction(
            title: Text.cancelActionTitle,
            style: .gray,
            action: {
                SOMDialogViewController.dismiss()
            }
         )
         let deleteAction = SOMDialogAction(
            title: Text.deleteButtonFloatActionTitle,
            style: .red,
            action: {
                SOMDialogViewController.dismiss {
                    
                    reactor.action.onNext(.delete)
                }
            }
         )

         SOMDialogViewController.show(
            title: Text.deleteDialogTitle,
            message: Text.deleteDialogMessage,
            textAlignment: .left,
            actions: [cancelAction, deleteAction]
         )
    }
    
    func showDeletedCardDialog(completion: (() -> Void)? = nil) {
        
        let confirmAction = SOMDialogAction(
            title: Text.confirmActionTitle,
            style: .primary,
            action: {
                SOMDialogViewController.dismiss {
                    completion?()
                }
            }
        )
        
        SOMDialogViewController.show(
            title: Text.deletedCardDialogTitle,
            messageView: nil,
            textAlignment: .left,
            actions: [confirmAction]
        )
    }
}
