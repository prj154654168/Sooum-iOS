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
        
        static let cancelActionTitle: String = "취소"
        static let settingActionTitle: String = "설정"
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
    
    private let rightAlamButton = SOMButton().then {
        $0.image = .init(.icon(.v2(.outlined(.bell))))
        $0.foregroundColor = .som.v2.black
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
    
    let willPushCardId = PublishRelay<String>()
    
    
    // MARK: Override func
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 제스처 뒤로가기를 위한 델리게이트 설정
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.scollingToTopWithAnimation(_:)),
            name: .scollingToTopWithAnimation,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.reloadData(_:)),
            name: .reloadData,
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
        
        self.rightAlamButton.addSubview(self.dotWithoutReadView)
        self.dotWithoutReadView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
            $0.size.equalTo(5)
        }
        self.rightAlamButton.snp.makeConstraints {
            $0.size.equalTo(48)
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
        self.rightAlamButton.rx.throttleTap()
            .subscribe(with: self) { object, _ in
                let viewController = NotificationViewController()
                viewController.reactor = reactor.reactorForNotification()
                object.navigationPush(viewController, animated: true, bottomBarHidden: true)
            }
            .disposed(by: self.disposeBag)
        
        // tabBar 표시
        self.rx.viewDidAppear
            .subscribe(with: self) { object, _ in
                object.hidesBottomBarWhenPushed = false
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
            .bind(to: self.dotWithoutReadView.rx.isHidden)
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.noticeInfos)
            .filterNil()
            .distinctUntilChanged()
            .subscribe(with: self) { object, noticeInfos in
                let models: [SOMPageModel] = noticeInfos
                    .enumerated()
                    .map { SOMPageModel(data: $1, index: ($0, noticeInfos.count)) }
                object.topNoticeView.frame = CGRect(origin: .zero, size: .init(width: UIScreen.main.bounds.width, height: 81))
                object.topNoticeView.setModels(models)
                object.tableView.tableHeaderView = noticeInfos.isEmpty ? nil : object.topNoticeView
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
        .observe(on: MainScheduler.asyncInstance)
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
    private func reloadData(_ notification: Notification) {
        
        self.reactor?.action.onNext(.landing)
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
                UIApplication.topViewController?.dismiss(animated: true)
            }
        )
        let settingAction = SOMDialogAction(
            title: Text.settingActionTitle,
            style: .primary,
            action: {
                let application = UIApplication.shared
                let openSettingsURLString: String = UIApplication.openSettingsURLString
                if let settingsURL = URL(string: openSettingsURLString),
                   application.canOpenURL(settingsURL) {
                    application.open(settingsURL)
                }
                
                UIApplication.topViewController?.dismiss(animated: true)
            }
        )
        
        SOMDialogViewController.show(
            title: Text.dialogTitle,
            message: Text.dialogMessage,
            actions: [cancelAction, settingAction]
        )
    }
}


// MARK: SOMStickyTabBarDelegate

extension HomeViewController: SOMStickyTabBarDelegate {
    
    func tabBar(_ tabBar: SOMStickyTabBar, shouldSelectTabAt index: Int) -> Bool {
        
        if index == 2, self.reactor?.locationManager.checkLocationAuthStatus() == .denied {
            
            self.showLocationPermissionDialog()
            return false
        }
        
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
        self.navigationPush(viewController, animated: true, bottomBarHidden: true)
    }
}


// MARK: UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: 상세보기 화면 전환 필요
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
        if self.isRefreshEnabled, offset < self.initialOffset {
            guard let refreshControl = self.tableView.refreshControl else {
                self.currentOffset = offset
                return
            }
            
            let pulledOffset = self.initialOffset - offset
            let refreshingOffset = refreshControl.frame.origin.y + refreshControl.frame.height + 16
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
            let targetOffset = max(-self.headerViewHeight, currentTopConstraint - delta)
            self.headerViewContainerTopConstraint?.update(offset: targetOffset).update(priority: .high)
        }
        
        if isScrollingDown == false {
            
            self.headerViewContainerTopConstraint?.update(offset: 0).update(priority: .high)
        }

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
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
            self.tableView.refreshControl?.beginRefreshingFromTop()
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
