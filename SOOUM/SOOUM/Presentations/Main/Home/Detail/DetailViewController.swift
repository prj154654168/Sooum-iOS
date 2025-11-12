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
         
         static let cancelActionTitle: String = "취소"
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
         $0.backgroundColor = .som.v2.gray100
         
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
            selector: #selector(self.reloadCommentsData(_:)),
            name: .reloadCommentsData,
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
         
         guard let reactor = self.reactor else { return }
         
         self.navigationBar.title = reactor.entranceCardType == .feed ?
            Text.feedDetailNavigationTitle :
            Text.commentDetailNavigationTitle
         
         if reactor.entranceCardType == .comment {
             self.navigationBar.setLeftButtons([self.leftHomeButton])
         }
         self.navigationBar.setRightButtons([self.rightMoreButton])
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
         
         // 답카드 작성 전환
         self.floatingButton.backgoundButton.rx.throttleTap
             .subscribe(with: self) { object, _ in
                 let writeCardViewController = WriteCardViewController()
                 writeCardViewController.reactor = reactor.reactorForWriteCard()
                 object.navigationPush(writeCardViewController, animated: true, bottomBarHidden: true)
             }
             .disposed(by: self.disposeBag)
         
         let detailCard = reactor.state.map(\.detailCard).filterNil().distinctUntilChanged()
         let isBlocked = reactor.state.map(\.isBlocked).distinctUntilChanged()
         let isReported = reactor.state.map(\.isReported).distinctUntilChanged()
         
         let rightMoreButtonDidTap = self.rightMoreButton.rx.throttleTap.share()
         // 더보기 버튼 액션
         rightMoreButtonDidTap
             .withLatestFrom(detailCard)
             .filter { $0.isOwnCard }
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
             .map { ($0.1, $0.2) }
             .subscribe(with: self) { object, combined in
                 
                 let (isBlocked, isReported) = combined
                 
                 object.actions = [
                    .init(
                        title: isBlocked ? Text.blockButtonFloatActionTitle : Text.unblockButtonFloatActionTitle,
                        image: .init(.icon(.v2(.outlined(isBlocked ? .hide : .eye)))),
                        action: { [weak object] in
                            SwiftEntryKit.dismiss(.specific(entryName: Text.bottomFloatEntryName)) {
                                if isBlocked {
                                    object?.showBlockedUserDialog()
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
                                object?.navigationPush(reportViewController, animated: true, bottomBarHidden: true)
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
         self.rightDeleteButton.rx.throttleTap
             .subscribe(with: self) { object, _ in
                 object.navigationPop(to: HomeViewController.self, animated: false, bottomBarHidden: false)
             }
             .disposed(by: self.disposeBag)
         
         // 답카드 홈 버튼 액션
         self.leftHomeButton.rx.throttleTap
             .subscribe(with: self) { object, _ in
                 object.navigationPop(to: HomeViewController.self, animated: false, bottomBarHidden: false)
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
         
         detailCard
             .observe(on: MainScheduler.asyncInstance)
             .subscribe(with: self) { object, detailCard in
                 object.detailCard = detailCard
                 
                 object.pungView.subscribePungTime(detailCard.storyExpirationTime)
                 object.pungView.isHidden = detailCard.storyExpirationTime == nil
                 
                 UIView.performWithoutAnimation {
                     object.collectionView.reloadData()
                 }
             }
             .disposed(by: self.disposeBag)
         
         reactor.state.map(\.commentCards)
             .distinctUntilChanged()
             .observe(on: MainScheduler.asyncInstance)
             .subscribe(with: self) { object, commentCards in
                 object.commentCards = commentCards
                 
                 UIView.performWithoutAnimation {
                     object.collectionView.reloadData()
                 }
             }
             .disposed(by: self.disposeBag)
         
         reactor.state.map(\.isLiked)
             .distinctUntilChanged()
             .filter { $0 }
             .observe(on: MainScheduler.asyncInstance)
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
             .observe(on: MainScheduler.asyncInstance)
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
         
         reactor.state.map(\.isDeleted)
             .distinctUntilChanged()
             .filter { $0 }
             .observe(on: MainScheduler.asyncInstance)
             .subscribe(with: self) { object, _ in
                 NotificationCenter.default.post(name: .reloadData, object: nil, userInfo: nil)
                 if reactor.entranceCardType == .comment {
                     NotificationCenter.default.post(name: .reloadCommentsData, object: nil, userInfo: nil)
                 }
                 
                 object.navigationBar.title = Text.deletedNavigationTitle
                 object.navigationBar.setRightButtons([object.rightDeleteButton])
                 
                 object.floatingButton.removeFromSuperview()
                 
                 object.isDeleted = true
                 
                 UIView.performWithoutAnimation {
                     object.collectionView.reloadData()
                 }
             }
             .disposed(by: self.disposeBag)
         
         // reactor.state.map(\.hasErrors)
         //     .filterNil()
         //     .distinctUntilChanged()
         //     .subscribe(with: self) { object, hasErrors in
         //
         //         switch reactor.entranceType {
         //         case .navi:
         //             object.isDeleted = true
         //
         //             UIView.performWithoutAnimation {
         //                 object.collectionView.reloadData()
         //             }
         //         case .push:
         //             return
         //             let notificationTabBarController = NotificationTabBarController()
         //             notificationTabBarController.reactor = reactor.reactorForNoti()
         //
         //             object.navigationPush(notificationTabBarController, animated: false)
         //             object.navigationController?.viewControllers.removeAll(where: { $0.isKind(of: DetailViewController.self) })
         //         }
         //     }
         //     .disposed(by: self.disposeBag)
     }
    
    
    // MARK: Objc func
    
    @objc
    private func reloadCommentsData(_ notification: Notification) {
        
        self.reactor?.action.onNext(.refreshForComment)
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
                    object.navigationPush(profileViewController, animated: true, bottomBarHidden: true)
                }
            }
            .disposed(by: cell.disposeBag)
        
        cell.likeAndCommentView.likeBackgroundButton.rx.throttleTap(.seconds(3))
            .withLatestFrom(reactor.state.compactMap(\.detailCard).map(\.isLike))
            .subscribe(onNext: { isLike in
                reactor.action.onNext(.updateLike(isLike == false))
            })
            .disposed(by: cell.disposeBag)
        
        cell.likeAndCommentView.commentBackgroundButton.rx.throttleTap
            .subscribe(with: self) { object, _ in
                let writeCardViewController = WriteCardViewController()
                writeCardViewController.reactor = reactor.reactorForWriteCard()
                object.navigationPush(writeCardViewController, animated: true, bottomBarHidden: true)
            }
            .disposed(by: cell.disposeBag)
        
        cell.prevCardBackgroundButton.rx.throttleTap
            .subscribe(with: self) { object, _ in
                /// 현재 쌓인 viewControllers 중 바로 이전 viewController가 전환해야 할 전글이라면 naviPop
                if let naviStackCount = object.navigationController?.viewControllers.count,
                   let prevViewController = object.navigationController?.viewControllers[naviStackCount - 2] as? DetailViewController,
                   prevViewController.reactor?.selectedCardId == object.detailCard.prevCardId {
                    
                    object.navigationPop()
                } else {
                    /// 없다면 새로운 viewController로 naviPush
                    guard let prevCardId = object.detailCard.prevCardId else { return }
                    let detailViewController = DetailViewController()
                    detailViewController.reactor = reactor.reactorForPush(prevCardId)
                    object.navigationPush(detailViewController, animated: true, bottomBarHidden: true)
                }
            }
            .disposed(by: cell.disposeBag)
        
        // cell.memberBackgroundButton.rx.tap
        //     .subscribe(with: self) { object, _ in
        //         if object.detailCard.isOwnCard {
        //
        //             let memberId = object.detailCard.member.id
        //             let profileViewController = ProfileViewController()
        //             profileViewController.reactor = object.reactor?.reactorForProfile(type: .myWithNavi, memberId)
        //             object.navigationPush(profileViewController, animated: true, bottomBarHidden: true)
        //         } else {
        //
        //             let memberId = object.detailCard.member.id
        //             let profileViewController = ProfileViewController()
        //             profileViewController.reactor = object.reactor?.reactorForProfile(type: .other, memberId)
        //             object.navigationPush(profileViewController, animated: true, bottomBarHidden: true)
        //         }
        //     }
        //     .disposed(by: cell.disposeBag)
        
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
                    object.navigationPush(viewController, animated: true, bottomBarHidden: true)
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
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        
        // 당겨서 새로고침
        if self.isRefreshEnabled, offset < self.initialOffset {
            guard let refreshControl = self.collectionView.refreshControl else {
                self.currentOffset = offset
                return
            }
            
            let pulledOffset = self.initialOffset - offset
            let refreshingOffset = refreshControl.frame.origin.y + refreshControl.frame.height
            self.shouldRefreshing = abs(pulledOffset) >= refreshingOffset + 10
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
    
    func showBlockedUserDialog() {
        
        guard let reactor = self.reactor else { return }
        
        let cancelAction = SOMDialogAction(
            title: Text.cancelActionTitle,
            style: .gray,
            action: {
                UIApplication.topViewController?.dismiss(animated: true)
            }
         )
         let blockAction = SOMDialogAction(
            title: Text.blockButtonFloatActionTitle,
            style: .primary,
            action: {
                UIApplication.topViewController?.dismiss(animated: true) {
                    
                    reactor.action.onNext(.block(isBlocked: true))
                }
            }
         )

         SOMDialogViewController.show(
            title: Text.blockDialogTitle,
            message: (reactor.currentState.detailCard?.nickname ?? "") + Text.blockDialogMessage,
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
                UIApplication.topViewController?.dismiss(animated: true)
            }
         )
         let deleteAction = SOMDialogAction(
            title: Text.deleteButtonFloatActionTitle,
            style: .red,
            action: {
                UIApplication.topViewController?.dismiss(animated: true) {
                    
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
}

// extension DetailViewController: SOMTagsDelegate {
//
//     func tags(_ tags: SOMTags, didTouch model: SOMTagModel) {
//
//         guard let reactor = self.reactor else { return }
//         GAManager.shared.logEvent(
//             event: SOMEvent.Tag.tag_click(
//                 tag_text: model.originalText,
//                 click_position: SOMEvent.Tag.ClickPositionKey.post
//             )
//         )
//         let tagDetailVC = TagDetailViewController()
//         tagDetailVC.reactor = reactor.reactorForTagDetail(model.id)
//         self.navigationPush(tagDetailVC, animated: true)
//     }
// }
