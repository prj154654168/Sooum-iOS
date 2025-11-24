//
//  ProfileViewController.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/24.
//

import UIKit

import SnapKit
import Then

import Kingfisher

import ReactorKit
import RxCocoa
import RxSwift


class ProfileViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let navigationTitle: String = "마이"
        static let navigationBlockButtonTitle: String = "차단"
        
        static let blockDialogTitle: String = "차단하시겠어요?"
        static let blockDialogMessage: String = "님의 모든 카드를 볼 수 없어요."
        
        static let unBlockUserDialogTitle: String = "차단 해제하시겠어요?"
        static let unBlockUserDialogMessage: String = "님을 팔로우하고, 카드를 볼 수 있어요."
        
        static let deleteFollowingDialogTitle: String = "님을 팔로워에서 삭제하시겠어요?"
        
        static let cancelActionTitle: String = "취소"
        static let blockActionTitle: String = "차단하기"
        static let unBlockActionTitle: String = "차단 해제"
        static let deleteActionTitle: String = "삭제하기"
    }
    
    enum Section: Int, CaseIterable {
        case user
        case card
    }
    
    enum Item: Hashable {
        case user(ProfileInfo)
        case card(type: EntranceCardType, feed: [ProfileCardInfo], comment: [ProfileCardInfo]?)
    }
    
    
    // MARK: Navi Views
    
    private let rightBlockButton = SOMButton().then {
        $0.title = Text.navigationBlockButtonTitle
        $0.typography = .som.v2.subtitle1
        $0.foregroundColor = .som.v2.black
    }
    
    private let rightSettingButton = SOMButton().then {
        $0.image = .init(.icon(.v2(.outlined(.settings))))
        $0.foregroundColor = .som.v2.black
    }
    
    
    // MARK: Views
    
    private let flowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.sectionHeadersPinToVisibleBounds = true
        $0.sectionInset = .zero
    }
    private lazy var collectionView = UICollectionView(
       frame: .zero,
       collectionViewLayout: self.flowLayout
    ).then {
        $0.backgroundColor = .som.v2.white
        
        $0.contentInset.top = 0
        $0.contentInset.bottom = 54 + 16
        
        $0.contentInsetAdjustmentBehavior = .never
        
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        
        $0.refreshControl = SOMRefreshControl()
        
        $0.register(ProfileUserViewCell.self, forCellWithReuseIdentifier: ProfileUserViewCell.cellIdentifier)
        $0.register(ProfileCardsViewCell.self, forCellWithReuseIdentifier: ProfileCardsViewCell.cellIdentifier)
        $0.register(
            ProfileViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ProfileViewHeader.cellIdentifier
        )
        
        $0.delegate = self
    }
    
    
    // MARK: Variables
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private lazy var dataSource: DataSource = {
        
        let dataSource = DataSource(collectionView: self.collectionView) { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
            
            guard let self = self, let reactor = self.reactor else { return nil }
            
            switch item {
            case let .user(profileInfo):
                
                let cell: ProfileUserViewCell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ProfileUserViewCell.cellIdentifier,
                    for: indexPath
                ) as! ProfileUserViewCell
                
                cell.setModel(profileInfo)
                
                cell.cardContainerDidTap
                    .subscribe(with: self) { object, _ in
                        object.collectionView.setContentOffset(CGPoint(x: 0, y: 84 + 76 + 48 + 16), animated: true)
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.followerContainerDidTap
                    .subscribe(with: self) { object, _ in
                        let followViewController = FollowViewController()
                        followViewController.reactor = reactor.reactorForFollow(
                            type: .follower,
                            view: profileInfo.isAlreadyFollowing == nil ? .my : .other,
                            nickname: profileInfo.nickname,
                            with: profileInfo.userId
                        )
                        object.navigationPush(followViewController, animated: true, bottomBarHidden: true)
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.followingContainerDidTap
                    .subscribe(with: self) { object, _ in
                        let followViewController = FollowViewController()
                        followViewController.reactor = reactor.reactorForFollow(
                            type: .following,
                            view: profileInfo.isAlreadyFollowing == nil ? .my : .other,
                            nickname: profileInfo.nickname,
                            with: profileInfo.userId
                        )
                        object.navigationPush(followViewController, animated: true, bottomBarHidden: true)
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.updateProfileButton.rx.throttleTap
                    .subscribe(with: self) { object, _ in
                        KingfisherManager.shared.download(
                            strUrl: profileInfo.profileImageUrl,
                            with: profileInfo.profileImgName
                        ) { [weak object] profileImage in
                            let updateProfileViewController = UpdateProfileViewController()
                            updateProfileViewController.reactor = reactor.reactorForUpdate(
                                nickname: profileInfo.nickname,
                                image: profileImage
                            )
                            object?.navigationPush(updateProfileViewController, animated: true, bottomBarHidden: true)
                        }
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.followButton.rx.throttleTap
                    .subscribe(with: self) { object, _ in
                        if profileInfo.isAlreadyFollowing == true {
                            object.showdeleteFollowingDialog(with: profileInfo.nickname)
                        } else {
                            reactor.action.onNext(.follow)
                        }
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.unBlockButton.rx.throttleTap
                    .subscribe(with: self) { object, _ in
                        object.showUnblockDialog(nickname: profileInfo.nickname, with: profileInfo.userId)
                    }
                    .disposed(by: cell.disposeBag)
                
                return cell
            case let .card(type, feeds, comments):
                
                let cell: ProfileCardsViewCell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ProfileCardsViewCell.cellIdentifier,
                    for: indexPath
                ) as! ProfileCardsViewCell
                
                if case .other = reactor.entranceType {
                    cell.setModels(type: .feed, feed: feeds, comment: nil)
                } else {
                    cell.setModels(type: type, feed: feeds, comment: comments ?? [])
                }
                
                cell.cardDidTap
                    .subscribe(with: self) { object, selectedId in
                        let detailViewController = DetailViewController()
                        detailViewController.reactor = reactor.reactorForDetail(selectedId)
                        object.navigationPush(detailViewController, animated: true, bottomBarHidden: true)
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.moreFindCards
                    .subscribe(with: self) { object, moreInfo in
                        reactor.action.onNext(.moreFind(moreInfo.type, moreInfo.lastId))
                    }
                    .disposed(by: cell.disposeBag)
                
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            
            guard let self = self else { return nil }
            
            if kind == UICollectionView.elementKindSectionHeader {
                
                let header: ProfileViewHeader = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: ProfileViewHeader.cellIdentifier,
                    for: indexPath
                ) as! ProfileViewHeader
                
                header.tabBarItemDidTap
                    .subscribe(with: self) { object, selectedIndex in
                        object.reactor?.action.onNext(.updateCardType(selectedIndex == 0 ? .feed : .comment))
                    }
                    .disposed(by: header.disposeBag)
                
                return header
            } else {
                return nil
            }
        }
        
        return dataSource
    }()
    
    private var initialOffset: CGFloat = 0
    private var currentOffset: CGFloat = 0
    private var isRefreshEnabled: Bool = true
    private var shouldRefreshing: Bool = false
    
    
    // MARK: Override variables
    
    override var bottomToastMessageOffset: CGFloat {
        /// bottom safe layout guide + floating button height + padding
        return self.reactor?.entranceType == .other ? 34 + 8 : 88
    }
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        guard let reactor = self.reactor else { return }
        
        let isMine = reactor.entranceType == .my || reactor.entranceType == .myWithNavi
        
        self.navigationBar.hidesBackButton = isMine
        self.navigationBar.title = isMine ? Text.navigationTitle : nil
        self.navigationBar.titlePosition = .left
        
        self.navigationBar.setRightButtons(isMine ? [self.rightSettingButton] : [self.rightBlockButton])
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 제스처 뒤로가기를 위한 델리게이트 설정
        if self.reactor?.entranceType != .other {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.reloadProfileData(_:)),
            name: .reloadProfileData,
            object: nil
        )
    }
    
    
    // MARK: ReactorKit - Bind
    
    func bind(reactor: ProfileViewReactor) {
        
        // 설정 화면 전환
        self.rightSettingButton.rx.throttleTap
            .subscribe(with: self) { object, _ in
                let settingsViewController = SettingsViewController()
                settingsViewController.reactor = reactor.reactorForSettings()
                object.navigationPush(settingsViewController, animated: true, bottomBarHidden: true)
            }
            .disposed(by: self.disposeBag)
        
        // 상대방 차단 요청
        self.rightBlockButton.rx.throttleTap
            .subscribe(with: self) { object, _ in
                let cancelAction = SOMDialogAction(
                    title: Text.cancelActionTitle,
                    style: .gray,
                    action: {
                        UIApplication.topViewController?.dismiss(animated: true)
                    }
                )
                let confirmAction = SOMDialogAction(
                    title: Text.blockActionTitle,
                    style: .red,
                    action: {
                        UIApplication.topViewController?.dismiss(animated: true) {
                            
                            reactor.action.onNext(.block)
                        }
                    }
                )
                
                SOMDialogViewController.show(
                    title: Text.blockDialogTitle,
                    message: Text.blockDialogMessage,
                    textAlignment: .left,
                    actions: [cancelAction, confirmAction]
                )
            }
            .disposed(by: self.disposeBag)
        
        // tabBar 표시
        self.rx.viewDidAppear
            .subscribe(with: self) { object, _ in
                object.hidesBottomBarWhenPushed = reactor.entranceType == .other
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
            .filter { $0 == false }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self.collectionView) { collectionView, _ in
                collectionView.refreshControl?.endRefreshing()
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map {
            ProfileViewReactor.DisplayStates(
                cardType: $0.cardType,
                profileInfo: $0.profileInfo,
                feedCardInfos: $0.feedCardInfos,
                commCardInfos: $0.commentCardInfos
            )
        }
        .distinctUntilChanged(reactor.canUpdateCells)
        .observe(on: MainScheduler.asyncInstance)
        .subscribe(with: self) { object, displayStates in
            
            var snapshot = Snapshot()
            snapshot.appendSections(Section.allCases)
            
            guard let profileInfo = displayStates.profileInfo else { return }
            
            if reactor.entranceType == .other, let isBlocked = profileInfo.isBlocked {
                object.rightBlockButton.isHidden = isBlocked
            }
            
            let profileItem = Item.user(profileInfo)
            snapshot.appendItems([profileItem], toSection: .user)
            
            let cardItem = Item.card(
                type: displayStates.cardType,
                feed: displayStates.feedCardInfos,
                comment: displayStates.commCardInfos.isEmpty ? nil : displayStates.commCardInfos
            )
            snapshot.appendItems([cardItem], toSection: .card)
            
            object.dataSource.apply(snapshot, animatingDifferences: false)
        }
        .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$isBlocked)
            .filterNil()
            .filter { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, _ in
                reactor.action.onNext(.updateCards)
            }
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$isFollowing)
            .filterNil()
            .filter { $0 }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, _ in
                reactor.action.onNext(.updateProfile)
            }
            .disposed(by: self.disposeBag)
    }
    
    
    // MARK: Private func
    
    private func updateCollectionViewHeight(numberOfItems: Int) -> CGFloat {
        
        let lineSpacing: CGFloat = 1.0
        // TODO: 임시, 행 개수 3 고정
        let itemsPerRow: CGFloat = 3.0
        let numberOfRows = ceil(CGFloat(numberOfItems) / itemsPerRow)
        
        let itemHeight = (self.collectionView.bounds.width - 2) / 3
        let newHeight = (numberOfRows * itemHeight) + ((numberOfRows - 1) * lineSpacing)
        
        return max(newHeight, self.collectionView.bounds.height - 56)
    }
    
    
    // MARK: Objc
    
    @objc
    private func reloadProfileData(_ notification: Notification) {
        
        self.reactor?.action.onNext(.updateProfile)
    }
}


// MARK: show Dialog

private extension ProfileViewController {
    
    func showdeleteFollowingDialog(with nickname: String) {
        
        let cancelAction = SOMDialogAction(
            title: Text.cancelActionTitle,
            style: .gray,
            action: {
                UIApplication.topViewController?.dismiss(animated: true)
            }
        )
        let deleteAction = SOMDialogAction(
            title: Text.deleteActionTitle,
            style: .red,
            action: {
                UIApplication.topViewController?.dismiss(animated: true) {
                    self.reactor?.action.onNext(.follow)
                }
            }
        )
        
        SOMDialogViewController.show(
            title: nickname + Text.deleteFollowingDialogTitle,
            messageView: nil,
            textAlignment: .left,
            actions: [cancelAction, deleteAction]
        )
    }
    
    func showUnblockDialog(nickname: String, with userId: String) {
        
        let cancelAction = SOMDialogAction(
            title: Text.cancelActionTitle,
            style: .gray,
            action: {
                UIApplication.topViewController?.dismiss(animated: true)
            }
        )
        
        let unBlockAction = SOMDialogAction(
            title: Text.unBlockActionTitle,
            style: .red,
            action: {
                UIApplication.topViewController?.dismiss(animated: true) {
                    self.reactor?.action.onNext(.block)
                }
            }
        )

        SOMDialogViewController.show(
            title: Text.unBlockUserDialogTitle,
            message: nickname + Text.unBlockUserDialogMessage,
            textAlignment: .left,
            actions: [cancelAction, unBlockAction]
        )
    }
}


// MARK: UICollectionViewDelegateFlowLayout

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        
        if self.reactor?.entranceType == .other {
            return .zero
        }
        
        guard let section = self.dataSource.sectionIdentifier(for: section) else { return .zero }
        
        if case .card = section {
            return CGSize(width: collectionView.bounds.width, height: 56)
        } else {
            return .zero
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        
        return .zero
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        guard let section = self.dataSource.sectionIdentifier(for: indexPath.section),
              let reactor = self.reactor
        else { return .zero }
        
        let width: CGFloat = collectionView.bounds.width
        switch section {
        case .user:
            /// top container height + bottom container height + button height + padding
            let height: CGFloat = 84 + 76 + 48 + 16
            return CGSize(width: width, height: height)
        case .card:
            
            let feeds = reactor.currentState.feedCardInfos
            let comments = reactor.currentState.commentCardInfos
            
            var height: CGFloat {
                let cellHeight: CGFloat = 84 + 76 + 48 + 16
                let headerHeight: CGFloat = 56
                let defaultHeight: CGFloat = collectionView.bounds.height - cellHeight - headerHeight
                switch reactor.currentState.cardType {
                case .feed:
                    
                    return feeds.isEmpty ?
                        defaultHeight :
                        self.updateCollectionViewHeight(numberOfItems: feeds.count)
                case .comment:
                    
                    return comments.isEmpty ?
                        defaultHeight :
                        self.updateCollectionViewHeight(numberOfItems: comments.count)
                }
            }
            
            return CGSize(width: width, height: height)
        }
    }
    
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        
        // currentOffset <= 0 && isRefreshing == false 일 때, 테이블 뷰 새로고침 가능
        self.isRefreshEnabled = (offset <= 0) && (self.reactor?.currentState.isRefreshing == false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        
        // 당겨서 새로고침
        if self.isRefreshEnabled, offset < self.initialOffset {
            
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
            self.collectionView.refreshControl?.beginRefreshing()
        }
    }
}
