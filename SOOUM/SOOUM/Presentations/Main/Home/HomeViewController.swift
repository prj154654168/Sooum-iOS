//
//  HomeViewController.swift
//  SOOUM
//
//  Created by 오현식 on 9/22/25.
//

import UIKit

import SnapKit
import Then

import ReactorKit
import RxCocoa
import RxSwift

class HomeViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let tabLatestTitle: String = "최신카드"
        static let tabPopularityTitle: String = "인기카드"
        static let tabDistanceTitle: String = "주변카드"
        
        static let distanceFilternder1km: String = "1km"
        static let distanceFilternder5km: String = "5km"
        static let distanceFilternder10km: String = "10km"
        static let distanceFilternder20km: String = "20km"
        static let distanceFilternder50km: String = "50km"
        
        static let dialogTitle: String = "위치 정보 사용 설정"
        static let dialogMessage: String = "내 위치 확인을 위해 ‘설정 > 앱 > 숨 > 위치’에서 위치 정보 사용을 허용해 주세요."
        
        static let pungedCardDialogTitle: String = "삭제된 카드예요"
        
        static let cancelActionTitle: String = "취소"
        static let settingActionTitle: String = "설정"
        static let confirmActionTitle: String = "확인"
    }
    
    enum Section: Int, CaseIterable {
        case latest
        case popular
        case distance
        case empty
    }
    
    enum Item: Hashable {
        case latest(BaseCardInfo)
        case popular(BaseCardInfo)
        case distance(BaseCardInfo)
        case empty
    }
    
    
    // MARK: Views
    
    private let logo = UIImageView().then {
        $0.image = .init(.logo(.v2(.logo_black)))
        $0.contentMode = .scaleAspectFit
    }
    
    private let rightAlamButton = UIButton()
    private let rightAlamImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.bell))))
        $0.tintColor = .som.v2.black
    }
    
    private let dotWithoutReadView = UIView().then {
        $0.backgroundColor = .som.v2.rMain
        $0.layer.cornerRadius = 5 * 0.5
        $0.isHidden = true
    }
    
    private let headerContainer = UIStackView().then {
        $0.backgroundColor = .som.v2.white
        $0.axis = .vertical
    }
    
    private lazy var stickyTabBar = SOMStickyTabBar().then {
        $0.items = [Text.tabLatestTitle, Text.tabPopularityTitle, Text.tabDistanceTitle]
        $0.spacing = 24
        $0.delegate = self
    }
    
    private lazy var distanceFilterView = SOMSwipableTabBar().then {
        $0.items = [
            Text.distanceFilternder1km,
            Text.distanceFilternder5km,
            Text.distanceFilternder10km,
            Text.distanceFilternder20km,
            Text.distanceFilternder50km
        ]
        $0.isHidden = true
        $0.delegate = self
    }
    
    private lazy var topNoticeView = SOMPageViews().then {
        $0.delegate = self
    }
    
    private lazy var tableView = UITableView().then {
        $0.backgroundColor = .som.v2.gray100
        $0.indicatorStyle = .black
        $0.separatorStyle = .none
        
        $0.contentInset.top = self.headerViewHeight + 16
        $0.contentInset.bottom = 54 + 16
        
        $0.verticalScrollIndicatorInsets.bottom = 54
        
        $0.isHidden = true
        
        $0.refreshControl = SOMRefreshControl()
        
        $0.register(HomeViewCell.self, forCellReuseIdentifier: HomeViewCell.cellIdentifier)
        $0.register(HomePlaceholderViewCell.self, forCellReuseIdentifier: HomePlaceholderViewCell.cellIdentifier)
        
        $0.delegate = self
    }
    
    
    // MARK: Variables
    
    typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private lazy var dataSource = DataSource(tableView: self.tableView) { [weak self] tableView, indexPath, item -> UITableViewCell? in
        
        guard let self = self else { return nil }
        
        switch item {
        case let .latest(cardInfo):
            
            let cell: HomeViewCell = self.cellForCard(tableView, with: indexPath)
            cell.bind(cardInfo)
            
            return cell
        case let .popular(cardInfo):
            
            let cell: HomeViewCell = self.cellForCard(tableView, with: indexPath)
            cell.bind(cardInfo)
            
            return cell
        case let .distance(cardInfo):
            
            let cell: HomeViewCell = self.cellForCard(tableView, with: indexPath)
            cell.bind(cardInfo)
            
            return cell
        case .empty:
            
            return self.cellForPlaceholder(tableView, with: indexPath)
        }
    }
    
    private var isRefreshEnabled: Bool = true
    private var shouldRefreshing: Bool = false
    private var isLoadingMore: Bool = false
    
    private var hidesHeaderView: Bool = false
    private var headerViewHeight: CGFloat = SOMStickyTabBar.Constants.height
    private var initialOffset: CGFloat = 0
    private var currentOffset: CGFloat = 0
    
    private var cellHeight: CGFloat {
        let width: CGFloat = (UIScreen.main.bounds.width - 16 * 2) * 0.5
        /// (가로 : 세로 = 2 : 1) + bottom contents container height + bottom inset
        return width + 34 + 10
    }
    
    
    // MARK: Constraints
    
    private var headerViewContainerTopConstraint: Constraint?
    
    
    // MARK: Variables + Rx
    
    private let willPushCardId = PublishRelay<String>()
    
    
    // MARK: Override func
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 제스처 뒤로가기를 위한 델리게이트 설정
        self.parent?.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.reloadHomeData(_:)),
            name: .reloadHomeData,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.addedFavoriteWithCardId(_:)),
            name: .addedFavoriteWithCardId,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.addedCommentWithCardId(_:)),
            name: .addedCommentWithCardId,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.deletedFeedCardWithId(_:)),
            name: .deletedFeedCardWithId,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updatedBlockUser(_:)),
            name: .updatedBlockUser,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.scollingToTopWithAnimation(_:)),
            name: .scollingToTopWithAnimation,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.changedLocationAuthorization(_:)),
            name: .changedLocationAuthorization,
            object: nil
        )
    }
    
    override func bind() {
        super.bind()
        #if DEVELOP
        self.setupDebugging()
        #endif
    }
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.titleView = self.logo
        self.navigationBar.titlePosition = .left
        
        self.navigationBar.hidesBackButton = true
        
        self.rightAlamButton.addSubview(self.rightAlamImageView)
        self.rightAlamButton.addSubview(self.dotWithoutReadView)
        self.rightAlamImageView.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        self.dotWithoutReadView.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.size.equalTo(5)
        }
        self.rightAlamButton.snp.makeConstraints {
            $0.edges.equalTo(self.rightAlamImageView.snp.edges)
        }
        
        self.navigationBar.setRightButtons([self.rightAlamButton])
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
        
        self.view.addSubview(self.headerContainer)
        self.headerContainer.snp.makeConstraints {
            self.headerViewContainerTopConstraint = $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).priority(.high).constraint
            $0.horizontalEdges.equalToSuperview()
        }
        self.headerContainer.addArrangedSubview(self.stickyTabBar)
        self.headerContainer.addArrangedSubview(self.distanceFilterView)
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: HomeViewReactor) {
        
        // navigation
        self.rightAlamButton.rx.throttleTap(.seconds(3))
            .subscribe(with: self) { object, _ in
                let viewController = NotificationViewController()
                viewController.reactor = reactor.reactorForNotification()
                object.parent?.navigationPush(viewController, animated: true)
            }
            .disposed(by: self.disposeBag)
        
        // Action
        self.rx.viewDidLoad
            .map { _ in Reactor.Action.landing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        let isRefreshing = reactor.state.map(\.isRefreshing).distinctUntilChanged().share()
        self.tableView.refreshControl?.rx.controlEvent(.valueChanged)
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
            .subscribe(with: self.tableView) { tableView, _ in
                tableView.refreshControl?.endRefreshing()
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.hasUnreadNotifications)
            .distinctUntilChanged()
            .map { $0 == false }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: self.dotWithoutReadView.rx.isHidden)
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.noticeInfos)
            .distinctUntilChanged()
            .filterNil()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, noticeInfos in
                let models: [SOMPageModel] = noticeInfos.map { SOMPageModel(data: $0) }
                object.topNoticeView.frame = CGRect(
                    origin: .zero,
                    size: .init(width: UIScreen.main.bounds.width - 16 * 2, height: 81)
                )
                object.topNoticeView.setModels(models)
                object.tableView.tableHeaderView = noticeInfos.isEmpty ? nil : object.topNoticeView
            }
            .disposed(by: self.disposeBag)
        
        let cardIsDeleted = reactor.state.map(\.cardIsDeleted)
            .distinctUntilChanged(reactor.canPushToDetail)
            .filterNil()
        cardIsDeleted
            .filter { $0.isDeleted }
            .map { $0.selectedId }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, selectedId in
                object.showPungedCardDialog(reactor, with: selectedId)
            }
            .disposed(by: self.disposeBag)
        cardIsDeleted
            .filter { $0.isDeleted == false }
            .map { $0.selectedId }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, selectedId in
                let detailViewController = DetailViewController()
                detailViewController.reactor = reactor.reactorForDetail(with: selectedId)
                object.parent?.navigationPush(detailViewController, animated: true) { _ in
                    reactor.action.onNext(.cleanup)
                }
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map {
            HomeViewReactor.DisplayStates(
                displayType: $0.displayType,
                latests: $0.latestCards,
                populars: $0.popularCards,
                distances: $0.distanceCards
            )
        }
        .observe(on: MainScheduler.instance)
        .subscribe(with: self) { object, displayStats in
            
            var snapshot = Snapshot()
            snapshot.appendSections(Section.allCases)
            
            switch displayStats.displayType {
            case .latest:
                
                guard let latests = displayStats.latests else { return }
                
                guard latests.isEmpty == false else {
                    snapshot.appendItems([.empty], toSection: .empty)
                    break
                }
                
                let new = latests.map { Item.latest($0) }
                snapshot.appendItems(new, toSection: .latest)
            case .popular:
                
                guard let populars = displayStats.populars else { return }
                
                guard populars.isEmpty == false else {
                    snapshot.appendItems([.empty], toSection: .empty)
                    break
                }
                
                let new = populars.map { Item.popular($0) }
                snapshot.appendItems(new, toSection: .popular)
            case .distance:
                
                guard let distances = displayStats.distances else { return }
                
                guard distances.isEmpty == false else {
                    snapshot.appendItems([.empty], toSection: .empty)
                    break
                }
                
                let new = distances.map { Item.distance($0) }
                snapshot.appendItems(new, toSection: .distance)
            }
            
            object.dataSource.apply(snapshot, animatingDifferences: false)
            
            object.tableView.isHidden = false
        }
        .disposed(by: self.disposeBag)
    }
    
    
    // MARK: Objc func
    
    @objc
    private func reloadHomeData(_ notification: Notification) {
        
        self.reactor?.action.onNext(.landing)
    }
    
    /// 피드카드 좋아요 업데이트 시, 최신/인기/거리 해당 카드만 업데이트
    @objc
    private func addedFavoriteWithCardId(_ notification: Notification) {
        
        guard let cardId = notification.userInfo?["cardId"] as? String,
            let addedFavorite = notification.userInfo?["addedFavorite"] as? Bool
        else { return }
        
        var latests = self.reactor?.currentState.latestCards ?? []
        var populars = self.reactor?.currentState.popularCards ?? []
        var distances = self.reactor?.currentState.distanceCards ?? []
        
        if let index = latests.firstIndex(where: { $0.id == cardId }) {
            let curr = latests[index].likeCnt
            let new = addedFavorite ? curr + 1 : curr - 1
            latests[index] = latests[index].updateLikeCnt(new)
        }
        
        if let index = populars.firstIndex(where: { $0.id == cardId }) {
            let curr = populars[index].likeCnt
            let new = addedFavorite ? curr + 1 : curr - 1
            populars[index] = populars[index].updateLikeCnt(new)
        }
        
        if let index = distances.firstIndex(where: { $0.id == cardId }) {
            let curr = distances[index].likeCnt
            let new = addedFavorite ? curr + 1 : curr - 1
            distances[index] = distances[index].updateLikeCnt(new)
        }
        
        self.reactor?.action.onNext(
            .updateCards(
                latests: latests,
                populars: populars,
                distances: distances
            )
        )
    }
    /// 피드카드 댓글카드 작성 및 삭제 시, 최신/인기/거리 해당 카드만 업데이트
    @objc
    private func addedCommentWithCardId(_ notification: Notification) {
        
        guard let cardId = notification.userInfo?["cardId"] as? String,
            let addedComment = notification.userInfo?["addedComment"] as? Bool
        else { return }
        
        var latests = self.reactor?.currentState.latestCards ?? []
        var populars = self.reactor?.currentState.popularCards ?? []
        var distances = self.reactor?.currentState.distanceCards ?? []
        
        if let index = latests.firstIndex(where: { $0.id == cardId }) {
            let curr = latests[index].commentCnt
            let new = addedComment ? curr + 1 : curr - 1
            latests[index] = latests[index].updateCommentCnt(new)
        }
        
        if let index = populars.firstIndex(where: { $0.id == cardId }) {
            let curr = populars[index].commentCnt
            let new = addedComment ? curr + 1 : curr - 1
            populars[index] = populars[index].updateCommentCnt(new)
        }
        
        if let index = distances.firstIndex(where: { $0.id == cardId }) {
            let curr = distances[index].commentCnt
            let new = addedComment ? curr + 1 : curr - 1
            distances[index] = distances[index].updateCommentCnt(new)
        }
        
        self.reactor?.action.onNext(
            .updateCards(
                latests: latests,
                populars: populars,
                distances: distances
            )
        )
    }
    /// 피드카드 삭제 시, 최신/인기/거리 해당 카드만 업데이트
    @objc
    private func deletedFeedCardWithId(_ notification: Notification) {
        
        guard let cardId = notification.userInfo?["cardId"] as? String,
            notification.userInfo?["isDeleted"] as? Bool == true
        else { return }
        
        var latests = self.reactor?.currentState.latestCards ?? []
        var populars = self.reactor?.currentState.popularCards ?? []
        var distances = self.reactor?.currentState.distanceCards ?? []
        
        latests.removeAll(where: { $0.id == cardId })
        populars.removeAll(where: { $0.id == cardId })
        distances.removeAll(where: { $0.id == cardId })
        
        self.reactor?.action.onNext(
            .updateCards(
                latests: latests,
                populars: populars,
                distances: distances
            )
        )
    }
    /// 특정 사용자 차단 시, 최신/인기/거리 특정 사용자 카드 숨김 처리
    @objc
    private func updatedBlockUser(_ notification: Notification) {
        
        guard notification.userInfo?["isBlocked"] as? Bool != nil else { return }
        
        self.reactor?.action.onNext(.landing)
    }
    
    @objc
    private func scollingToTopWithAnimation(_ notification: Notification) {
        
        guard let displayType = self.reactor?.currentState.displayType else { return }
        
        var section: Int {
            switch displayType {
            case .latest: return Section.latest.rawValue
            case .popular: return Section.popular.rawValue
            case .distance: return Section.distance.rawValue
            }
        }
        
        let toTop = CGPoint(x: 0, y: -(self.tableView.contentInset.top))
        self.tableView.setContentOffset(toTop, animated: true)
    }
    
    @objc
    private func changedLocationAuthorization(_ notification: Notification) {
        
        self.reactor?.action.onNext(.updateLocationPermission)
    }
}


// MARK: Cells

private extension HomeViewController {
    
    func cellForPlaceholder(
        _ tableView: UITableView,
        with indexPath: IndexPath
    ) -> HomePlaceholderViewCell {
        
        return tableView.dequeueReusableCell(
            withIdentifier: HomePlaceholderViewCell.cellIdentifier,
            for: indexPath
        ) as! HomePlaceholderViewCell
    }
    
    func cellForCard(
        _ tableView: UITableView,
        with indexPath: IndexPath
    ) -> HomeViewCell {
        
        return tableView.dequeueReusableCell(
            withIdentifier: HomeViewCell.cellIdentifier,
            for: indexPath
        ) as! HomeViewCell
    }
}


// MARK: show Dialog

private extension HomeViewController {
    
    func showLocationPermissionDialog() {
        
        let cancelAction = SOMDialogAction(
            title: Text.cancelActionTitle,
            style: .gray,
            action: {
                SOMDialogViewController.dismiss {
                    let prevIdx = self.stickyTabBar.previousIndex
                    let currInx = self.stickyTabBar.selectedIndex
                    
                    self.stickyTabBar.didSelectTabBarItem(prevIdx == currInx ? 0 : prevIdx)
                }
            }
        )
        let settingAction = SOMDialogAction(
            title: Text.settingActionTitle,
            style: .primary,
            action: {
                SOMDialogViewController.dismiss {
                    let application = UIApplication.shared
                    let openSettingsURLString: String = UIApplication.openSettingsURLString
                    if let settingsURL = URL(string: openSettingsURLString),
                       application.canOpenURL(settingsURL) {
                        application.open(settingsURL)
                    }
                }
            }
        )
        
        SOMDialogViewController.show(
            title: Text.dialogTitle,
            message: Text.dialogMessage,
            textAlignment: .left,
            actions: [cancelAction, settingAction]
        )
    }
    
    func showPungedCardDialog(_ reactor: HomeViewReactor, with selectedId: String) {
        
        let confirmAction = SOMDialogAction(
            title: Text.confirmActionTitle,
            style: .primary,
            action: {
                SOMDialogViewController.dismiss {
                    reactor.action.onNext(.cleanup)
                    
                    reactor.action.onNext(
                        .updateCards(
                            latests: (reactor.currentState.latestCards ?? []).filter { $0.id != selectedId },
                            populars: (reactor.currentState.popularCards ?? []).filter { $0.id != selectedId },
                            distances: (reactor.currentState.distanceCards ?? []).filter { $0.id != selectedId }
                        )
                    )
                }
            }
        )
        
        SOMDialogViewController.show(
            title: Text.pungedCardDialogTitle,
            messageView: nil,
            textAlignment: .left,
            actions: [confirmAction]
        )
    }
}


// MARK: SOMStickyTabBarDelegate

extension HomeViewController: SOMStickyTabBarDelegate {
    
    func tabBar(_ tabBar: SOMStickyTabBar, shouldSelectTabAt index: Int) -> Bool {
        // TODO: 주변카드 선택 시 위치권한이 없어도 탭 전환 허용
        return true
    }
    
    func tabBar(_ tabBar: SOMStickyTabBar, didSelectTabAt index: Int) {
        
        let hidesDistanceFilter = index != 2
        self.distanceFilterView.isHidden = hidesDistanceFilter
        self.headerViewHeight = hidesDistanceFilter ?
            SOMStickyTabBar.Constants.height :
            SOMStickyTabBar.Constants.height + SOMSwipableTabBar.Constants.height
        self.tableView.contentInset.top = self.headerViewHeight + 16
        
        let toTop = CGPoint(x: 0, y: -(self.headerViewHeight + 16))
        self.tableView.setContentOffset(toTop, animated: false)
        
        var displayType: HomeViewReactor.DisplayType {
            switch index {
            case 1: return .popular
            case 2: return .distance
            default: return .latest
            }
        }
        self.reactor?.action.onNext(.updateDisplayType(displayType))
        
        if index == 2, self.reactor?.currentState.hasPermission == false {
            self.showLocationPermissionDialog()
        }
    }
}


// MARK: SOMSwipeTabBarDelegate

extension HomeViewController: SOMSwipableTabBarDelegate {
    
    func tabBar(_ tabBar: SOMSwipableTabBar, didSelectTabAt index: Int) {
        
        let distanceFilter = tabBar.items[index]
        self.reactor?.action.onNext(.updateDistanceFilter(distanceFilter))
    }
}


extension HomeViewController: SOMPageViewsDelegate {
    
    func pages(_ tags: SOMPageViews, didTouch model: SOMPageModel) {
        
        guard let reactorForNotification = self.reactor?.reactorForNotification(with: .notice) else { return }
        
        let viewController = NotificationViewController()
        viewController.reactor = reactorForNotification
        self.parent?.navigationPush(viewController, animated: true)
    }
}


// MARK: UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let item = self.dataSource.itemIdentifier(for: indexPath),
              let reactor = self.reactor
        else { return }
        
        var isPunged: Bool {
            switch item {
            case let .latest(selectedCard):
                guard let expireAt = selectedCard.storyExpirationTime else { return false }
                return expireAt < Date()
            case let .popular(selectedCard):
                guard let expireAt = selectedCard.storyExpirationTime else { return false }
                return expireAt < Date()
            case let .distance(selectedCard):
                guard let expireAt = selectedCard.storyExpirationTime else { return false }
                return expireAt < Date()
            case .empty:
                return false
            }
        }
        
        var selectedId: String? {
            switch item {
            case let .latest(selectedCard):
                return selectedCard.id
            case let .popular(selectedCard):
                return selectedCard.id
            case let .distance(selectedCard):
                return selectedCard.id
            case .empty:
                return nil
            }
        }
        
        guard let selectedId = selectedId else { return }
        
        guard isPunged == false else {
            self.showPungedCardDialog(reactor, with: selectedId)
            return
        }
        
        reactor.action.onNext(.hasDetailCard(selectedId))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else {
            return tableView.bounds.height
        }
        
        switch item {
        case .empty:
            return (UIScreen.main.bounds.height * 0.2) + 113 + 20 + 42
        default:
            return self.cellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let reactor = self.reactor, reactor.currentState.isRefreshing == false else { return }
        
        switch reactor.currentState.displayType {
        case .latest:
            
            let lastRowIndexPath = tableView.numberOfRows(inSection: Section.latest.rawValue) - 1
            if self.isLoadingMore,
               reactor.currentState.latestCards?.isEmpty == false,
               indexPath.section == Section.latest.rawValue,
               indexPath.row == lastRowIndexPath {
                
                let lastId = reactor.currentState.latestCards?.last?.id ?? ""
                reactor.action.onNext(.moreFind(lastId))
            }
        case .distance:
            
            let lastRowIndexPath = tableView.numberOfRows(inSection: Section.distance.rawValue) - 1
            if self.isLoadingMore,
               reactor.currentState.distanceCards?.isEmpty == false,
               indexPath.section == Section.distance.rawValue,
               indexPath.row == lastRowIndexPath {
                
                let lastId = reactor.currentState.distanceCards?.last?.id ?? ""
                reactor.action.onNext(.moreFind(lastId))
            }
        default:
            return
        }
    }
    
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        
        // currentOffset <= 0 && isLoading == false 일 때, 테이블 뷰 새로고침 가능
        self.isRefreshEnabled = (offset <= 0) && (self.reactor?.currentState.isRefreshing == false)
        self.shouldRefreshing = false
        self.initialOffset = offset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        let delta = offset - self.currentOffset
        
        let isScrollingDown = delta > 0
        
        // 당겨서 새로고침
        if self.isRefreshEnabled, offset < self.initialOffset,
            let refreshControl = self.tableView.refreshControl as? SOMRefreshControl {
            
            refreshControl.updateProgress(
                offset: scrollView.contentOffset.y,
                topInset: scrollView.adjustedContentInset.top
            )
            
            let pulledOffset = self.initialOffset - offset
            /// refreshControl heigt + top padding
            let refreshingOffset: CGFloat = 44 + 12
            self.shouldRefreshing = abs(pulledOffset) >= refreshingOffset
        }
        
        // 당겨서 새로고침 시 무시
        guard offset > 0,
              // 스크롤이 맨 아래에 도달했을 때, 헤더뷰 숨김 로직을 무시
              offset <= (scrollView.contentSize.height - scrollView.frame.height)
        else {
            self.currentOffset = offset
            return
        }
        
        if isScrollingDown {
            // 현재 constraint를 직접 비교
            let currentTopConstraint = self.headerViewContainerTopConstraint?.layoutConstraints.first?.constant ?? 0
            // 헤더 뷰 높이의 70% 만큼 스크롤될 때, 숨김
            let targetOffset = self.headerViewHeight * 0.7 <= delta - currentTopConstraint ?
                -self.headerViewHeight :
                (currentTopConstraint - delta)
            self.headerViewContainerTopConstraint?.update(offset: targetOffset).update(priority: .high)
        }
        
        if isScrollingDown == false {
            
            self.headerViewContainerTopConstraint?.update(offset: 0).update(priority: .high)
        }

        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.view.layoutIfNeeded()
        }
        
        // 아래로 스크롤 중일 때, 데이터 추가로드 가능
        self.isLoadingMore = isScrollingDown
        
        self.currentOffset = offset
    }
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        
        if self.shouldRefreshing {
            self.tableView.refreshControl?.beginRefreshing()
        }
    }
}


// MARK: Download log history for debugging

private extension HomeViewController {
    
    func setupDebugging() {
        
        self.logo.rx.longPressGesture()
            .when(.began)
            .flatMapLatest { _ in Log.extract() }
            .subscribe(
                with: self,
                onNext: { object, viewController in
                    object.navigationController?.present(viewController, animated: true)
                },
                onError: { _, error in
                    Log.error(error.localizedDescription)
                }
            )
            .disposed(by: self.disposeBag)
    }
}
