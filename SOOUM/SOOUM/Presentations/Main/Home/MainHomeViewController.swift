//
//  MainHomeViewController.swift
//  SOOUM
//
//  Created by 오현식 on 9/25/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift

import SnapKit
import Then


class MainHomeViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let title: String = "아직 등록된 카드가 없어요"
        static let subTitle: String = "사소하지만 말 못 한 이야기를\n카드로 만들어 볼까요?"
        
        static let dialogTitle: String = "위치 정보 사용 설정"
        static let dialogSubTitle: String = "위치 확인을 위해 권한 설정이 필요해요"
    }
    
    private let logo = UIImageView().then {
        $0.image = .init(.logo)
        $0.tintColor = .som.p300
        $0.contentMode = .scaleAspectFit
    }
    
    private let rightAlamButton = SOMButton().then {
        $0.image = .init(.icon(.outlined(.alarm)))
        $0.foregroundColor = .som.gray700
    }
    
    private let headerContainer = UIStackView().then {
        $0.axis = .vertical
    }
    private lazy var headerHomeTabBar = SOMHomeTabBar().then {
        $0.delegate = self
    }
    private lazy var headerLocationFilter = SOMLocationFilter().then {
        $0.delegate = self
    }
    
    private let moveTopButton = MoveTopButtonView().then {
        $0.isHidden = true
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .clear
        $0.indicatorStyle = .black
        $0.separatorStyle = .none
        
        $0.isScrollEnabled = false
        
        $0.register(MainHomeViewCell.self, forCellReuseIdentifier: "cell")
        
        $0.refreshControl = SOMRefreshControl()
        
        $0.dataSource = self
        $0.prefetchDataSource = self
        
        $0.delegate = self
    }
    
    private let placeholderView = UIView().then {
        $0.isHidden = true
    }
    
    
    /// tableView에 표시될 카드 정보
    private var displayedCards = [Card]()
    
    private var headerContainerHeightConstraint: Constraint?
    private var locationFilterHeightConstraint: Constraint?
    private var tableViewTopConstraint: Constraint?
    
    private var currentOffset: CGFloat = 0
    private var isRefreshEnabled: Bool = true
    
    
    // MARK: - Life Cycles
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.titleView = self.logo
        self.navigationBar.titlePosition = .left
        
        self.navigationBar.hidesBackButton = true
        self.navigationBar.setRightButtons([self.rightAlamButton])
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.headerContainer)
        self.headerContainer.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).priority(.high)
            $0.leading.trailing.equalToSuperview().priority(.high)
            self.headerContainerHeightConstraint = $0.height.equalTo(SOMHomeTabBar.height).constraint
        }
        self.headerContainer.addArrangedSubview(self.headerHomeTabBar)
        self.headerHomeTabBar.snp.makeConstraints {
            $0.height.equalTo(SOMHomeTabBar.height)
        }
        self.headerContainer.addArrangedSubview(self.headerLocationFilter)
        self.headerLocationFilter.snp.makeConstraints {
            self.locationFilterHeightConstraint = $0.height.equalTo(0).constraint
        }
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            self.tableViewTopConstraint = $0.top.equalTo(self.headerContainer.snp.bottom).constraint
            $0.bottom.leading.trailing.equalToSuperview()
        }
        
        self.view.addSubview(self.placeholderView)
        self.placeholderView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        let placeholderTitleLabel = UILabel().then {
            $0.typography = .som.body1WithBold
            $0.text = Text.title
            $0.textColor = .som.black
            $0.textAlignment = .center
        }
        self.placeholderView.addSubview(placeholderTitleLabel)
        placeholderTitleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        let placeholderSubTitleLabel = UILabel().then {
            $0.typography = .som.body2WithBold
            $0.numberOfLines = 0
            $0.text = Text.subTitle
            $0.textColor = .som.gray500
            $0.textAlignment = .center
        }
        self.placeholderView.addSubview(placeholderSubTitleLabel)
        placeholderSubTitleLabel.snp.makeConstraints {
            $0.top.equalTo(placeholderTitleLabel.snp.bottom).offset(14)
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        self.view.addSubview(self.moveTopButton)
        self.view.bringSubviewToFront(self.moveTopButton)
        self.moveTopButton.snp.makeConstraints {
            let bottomOffset: CGFloat = 24 + 60 + 4
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-bottomOffset)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(MoveTopButtonView.height)
        }
    }
    
    override func bind() {
        super.bind()
        
        // 탭바 표시
        self.rx.viewWillAppear
            .subscribe(with: self) { object, _ in
                object.hidesBottomBarWhenPushed = false
            }
            .disposed(by: self.disposeBag)
        
        // 스와이프 제스처
        self.view.rx.swipeGesture(Set([.left, .right]))
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .when(.recognized)
            .withUnretained(self)
            .filter { object, gesture in
                let location = gesture.location(in: object.headerContainer)
                
                return object.headerContainer.bounds.contains(location) == false
            }
            .subscribe(onNext: { object, gesture in
                let currentIndex = object.headerHomeTabBar.selectedIndex
                
                switch gesture.direction {
                case .left:
                    guard currentIndex != 2 else { return }
                    object.headerHomeTabBar.didSelectTab(currentIndex + 1)
                case .right:
                    guard currentIndex != 0 else { return }
                    object.headerHomeTabBar.didSelectTab(currentIndex - 1)
                default:
                    return
                }
            })
            .disposed(by: self.disposeBag)
        
        // tableView 상단 이동
        self.moveTopButton.backgroundButton.rx.throttleTap(.seconds(3))
            .subscribe(with: self) { object, _ in
                let indexPath = IndexPath(row: 0, section: 0)
                object.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
            .disposed(by: self.disposeBag)
        
        #if DEVELOP
        logo.rx.longPressGesture()
            .when(.began)
            .subscribe(with: self) { object, _ in
                AuthKeyChain.shared.delete(.deviceId)
                AuthKeyChain.shared.delete(.refreshToken)
                AuthKeyChain.shared.delete(.accessToken)
                
                DispatchQueue.main.async {
                    if let windowScene: UIWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window: UIWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                        
                        let viewController = OnboardingViewController()
                        window.rootViewController = UINavigationController(rootViewController: viewController)
                    }
                }
            }
            .disposed(by: self.disposeBag)
        #endif
    }
    
    
    // MARK: Bind
    
    func bind(reactor: MainHomeViewReactor) {
        
        // Action
        self.rx.viewWillAppear
            .map { _ in Reactor.Action.landing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.tableView.refreshControl?.rx.controlEvent(.valueChanged)
            .withLatestFrom(reactor.state.map(\.isLoading))
            .filter { $0 == false }
            .map { _ in Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map(\.isLoading)
            .distinctUntilChanged()
            .subscribe(with: self.tableView) { tableView, isLoading in
                if isLoading {
                    tableView.refreshControl?.beginRefreshingFromTop()
                } else {
                    tableView.refreshControl?.endRefreshing()
                }
            }
            .disposed(by: self.disposeBag)
        
        let displayedCardsWithUpdate = reactor.state.map(\.displayedCardsWithUpdate)
            .distinctUntilChanged({ $0.cards == $1.cards && $0.isUpdate == $1.isUpdate })
            .share()
        let isProcessing = reactor.state.map(\.isProcessing).distinctUntilChanged().share()
        isProcessing
            .filter { $0 }
            .withLatestFrom(displayedCardsWithUpdate.map { $0.isUpdate })
            .subscribe(with: self) { object, isUpdate in
                object.tableView.isHidden = isUpdate == false
                object.placeholderView.isHidden = true
            }
            .disposed(by: self.disposeBag)
        isProcessing
            .distinctUntilChanged()
            .bind(to: self.activityIndicatorView.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        Observable.combineLatest(isProcessing, displayedCardsWithUpdate.map { $0.cards })
            .filter { $0.0 == false }
            .subscribe(with: self) { object, pair in
                object.tableView.isHidden = pair.1.isEmpty
                object.placeholderView.isHidden = pair.1.isEmpty == false
            }
            .disposed(by: self.disposeBag)
        
        displayedCardsWithUpdate
            .subscribe(with: self) { object, displayedCardsWithUpdate in
                let displayedCards = displayedCardsWithUpdate.cards
                let isUpdate = displayedCardsWithUpdate.isUpdate
                // cell들의 높이가 tableView의 높이를 초과할 때만 스크롤 가능
                let width: CGFloat = (UIScreen.main.bounds.width - 20 * 2) * 0.9
                let height: CGFloat = width + 10
                let isScrollEnabled: Bool = object.tableView.bounds.height < height * CGFloat(displayedCards.count)
                object.tableView.isScrollEnabled = isScrollEnabled
                
                // isUpdate == true 일 때, 추가된 카드만 로드
                if isUpdate {
                    let indexPathForInsert: [IndexPath] = displayedCards.enumerated()
                        .filter { object.displayedCards.contains($0.element) == false }
                        .map { IndexPath(row: $0.offset, section: 0) }
                    
                    object.displayedCards = displayedCards
                    
                    object.tableView.performBatchUpdates {
                        object.tableView.insertRows(at: indexPathForInsert, with: .automatic)
                    }
                } else {
                    object.displayedCards = displayedCards
                    object.tableView.reloadData()
                }
            }
            .disposed(by: self.disposeBag)
    }
}


// MARK: MainHomeViewController DataSource and Delegate

extension MainHomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayedCards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = SOMCardModel(data: self.displayedCards[indexPath.row])
        
        let cell: MainHomeViewCell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        ) as! MainHomeViewCell
        cell.selectionStyle = .none
        cell.setModel(model)
        // 카드 하단 contents 스택 순서 변경
        cell.changeOrderInCardContentStack(self.reactor?.currentState.selectedIndex ?? 0)
        
        return cell
    }
}

extension MainHomeViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        
        if indexPaths.first?.section == lastSectionIndex,
           indexPaths.last?.row == lastRowIndex,
           let reactor = self.reactor {
            
            var cardType: SimpleCache.CardType {
                switch reactor.currentState.selectedIndex {
                case 1: return .popular
                case 2: return .distance
                default: return .latest
                }
            }
            
            // 캐시된 데이터가 존재하고, 현재 표시된 수보다 캐시된 수가 많으면
            if let loadedCards = reactor.simpleCache.loadMainHomeCards(type: cardType),
               self.displayedCards.count < loadedCards.count {
                reactor.action.onNext(.moreFind(lastId: nil))
            } else {
                let lastId = self.displayedCards[indexPaths.last?.row ?? 0].id
                reactor.action.onNext(.moreFind(lastId: lastId))
            }
        }
    }
}

extension MainHomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedId = self.displayedCards[indexPath.row].id
        
        let detailViewController = DetailViewController()
        detailViewController.reactor = self.reactor?.reactorForDetail(selectedId)
        // 탭바 숨김처리, bottomBarHidden = true
        self.navigationPush(detailViewController, animated: true, bottomBarHidden: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let width: CGFloat = (UIScreen.main.bounds.width - 20 * 2) * 0.9
        let height: CGFloat = width + 10 /// 가로 + top inset
        return height
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        // currentOffset <= 0 일 때, 테이블 뷰 새로고침 가능
        self.isRefreshEnabled = self.currentOffset <= 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        
        // offset이 currentOffset보다 크면 아래로 스크롤, 반대일 경우 위로 스크롤
        // 위로 스크롤 중일 때 헤더뷰 표시, 아래로 스크롤 중일 때 헤더뷰 숨김
        self.headerContainer.isHidden = offset <= 0 ? false : offset > self.currentOffset
        self.tableViewTopConstraint?.deactivate()
        self.tableView.snp.makeConstraints {
            let top = self.headerContainer.isHidden ? self.view.safeAreaLayoutGuide.snp.top : self.headerContainer.snp.bottom
            self.tableViewTopConstraint = $0.top.equalTo(top).constraint
        }
        
        self.currentOffset = offset
        
        // 최상단일 때만 moveToButton 숨김
        self.moveTopButton.isHidden = self.currentOffset <= 0
        
        // Set homeTabBar hide animation
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let offset = scrollView.contentOffset.y
        
        // isRefreshEnabled == true 이고, 스크롤이 끝났을 경우에만 테이블 뷰 새로고침
        if self.isRefreshEnabled,
           let refreshControl = self.tableView.refreshControl,
           offset <= -(refreshControl.frame.origin.y + refreshControl.bounds.height) {
            
            refreshControl.beginRefreshingFromTop()
        }
    }
}


// MARK: MainHomeHeaderView Delegate

extension MainHomeViewController: SOMHomeTabBarDelegate {
    
    func tabBar(_ tabBar: SOMHomeTabBar, shouldSelectTabAt index: Int) -> Bool {
        
        if index == 2, self.reactor?.locationManager.checkLocationAuthStatus() == .denied {
            
            SOMDialogViewController.show(
                title: Text.dialogTitle,
                subTitle: Text.dialogSubTitle,
                leftAction: .init(
                    mode: .cancel,
                    handler: { UIApplication.topViewController?.dismiss(animated: true) }
                ),
                rightAction: .init(
                    mode: .setting,
                    handler: {
                        let application = UIApplication.shared
                        let openSettingsURLString: String = UIApplication.openSettingsURLString
                        if let settingsURL = URL(string: openSettingsURLString),
                           application.canOpenURL(settingsURL) {
                            application.open(settingsURL)
                        }
                        
                        UIApplication.topViewController?.dismiss(animated: true)
                    }
                )
            )
            return false
        }
        
        return true
    }
    
    func tabBar(_ tabBar: SOMHomeTabBar, didSelectTabAt index: Int) {
        
        self.headerLocationFilter.isHidden = index != 2
        self.locationFilterHeightConstraint?.deactivate()
        self.headerLocationFilter.snp.makeConstraints {
            let height: CGFloat = index != 2 ? 0 : SOMLocationFilter.height
            self.locationFilterHeightConstraint = $0.height.equalTo(height).priority(.high).constraint
        }
        self.headerContainerHeightConstraint?.deactivate()
        self.headerContainer.snp.makeConstraints {
            let height: CGFloat = index != 2 ? SOMHomeTabBar.height : SOMHomeTabBar.height + SOMLocationFilter.height
            self.headerContainerHeightConstraint = $0.height.equalTo(height).priority(.high).constraint
        }
        
        self.reactor?.action.onNext(.homeTabBarItemDidTap(index: index))
    }
}

extension MainHomeViewController: SOMLocationFilterDelegate {
    
    func filter(_ filter: SOMLocationFilter, didSelectDistanceAt distance: SOMLocationFilter.Distance) {
        guard filter.prevDistance != distance else { return }
        
        self.reactor?.action.onNext(.distanceFilter(distance.rawValue))
    }
}
