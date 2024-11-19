//
//  MainHomeViewController.swift
//  SOOUM
//
//  Created by 오현식 on 9/25/24.
//

import UIKit

import ReactorKit
import RxCocoa
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
    
    private let rightAlamButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .init(.icon(.outlined(.alarm)))
        config.image?.withTintColor(.som.gray700)
        config.imageColorTransformer = UIConfigurationColorTransformer { _ in .som.gray700 }
        $0.configuration = config
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
    
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .clear
        $0.indicatorStyle = .black
        $0.separatorStyle = .none
        
        $0.register(MainHomeViewCell.self, forCellReuseIdentifier: "cell")
        
        $0.refreshControl = SOMRefreshControl()
        $0.dataSource = self
        $0.delegate = self
    }
    
    private let placeholderView = UIView().then {
        $0.isHidden = true
    }
    
    
    /// tableView에 표시될 카드 정보
    private var cards = [Card]()
    
    private var headerContainerHeightConstraint: Constraint?
    private var locationFilterHeightConstraint: Constraint?
    private var tableViewTopConstraint: Constraint?
    
    private var currentOffset: CGFloat = 0
    
    
    // MARK: - Life Cycles
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.titleView = self.logo
        self.navigationBar.titlePosition = .left
        
        self.navigationBar.isHideBackButton = true
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
            self.locationFilterHeightConstraint = $0.height.equalTo(SOMLocationFilter.height).constraint
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
        
        // homeTabBar 시작 인덱스
        self.headerHomeTabBar.didSelectTab(0)
        
        // tableView 상단 이동
        self.moveTopButton.backgroundButton.rx.tap
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
            }
            .disposed(by: self.disposeBag)
        #endif
    }
    
    
    // MARK: Bind
    
    func bind(reactor: MainHomeViewReactor) {
        
        // Action
        self.rx.viewDidLoad
            .map { _ in
                return Reactor.Action.landing
            }
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
                if (tableView.refreshControl?.isRefreshing ?? false) && isLoading {
                    tableView.refreshControl?.beginRefreshingFromTop()
                } else {
                    tableView.refreshControl?.endRefreshing()
                }
            }
            .disposed(by: self.disposeBag)
        
        let isProcessing = reactor.state.map(\.isProcessing).distinctUntilChanged().share()
        isProcessing
            .filter { $0 }
            .subscribe(with: self) { object, _ in
                object.tableView.isHidden = true
                object.placeholderView.isHidden = true
            }
            .disposed(by: self.disposeBag)
        
        isProcessing
            .distinctUntilChanged()
            .bind(to: self.activityIndicatorView.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.cards)
            .distinctUntilChanged()
            .subscribe(with: self) { object, cards in
                object.cards = cards
                object.tableView.isHidden = cards.isEmpty
                object.placeholderView.isHidden = !cards.isEmpty
                object.tableView.reloadData()
            }
            .disposed(by: self.disposeBag)
    }
}


// MARK: MainHomeViewController DataSource and Delegate

extension MainHomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = SOMCardModel(data: self.cards[indexPath.row])
        
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

 extension MainHomeViewController: UITableViewDelegate {
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let selectedId = self.cards[indexPath.row].id
         
         let detailViewController = DetailViewController()
         detailViewController.reactor = self.reactor?.reactorForDetail(selectedId)
         self.navigationPush(detailViewController, animated: true)
     }
     
     func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
     ) {
         let lastSectionIndex = tableView.numberOfSections - 1
         let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
         
         if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
             
             if let cell = cell as? MainHomeViewCell {
                 let lastId = cell.cardView.model?.data.id
                 self.reactor?.action.onNext(.moreFind(lastId: lastId))
             }
         }
     }
     
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         let width: CGFloat = (UIScreen.main.bounds.width - 20 * 2) * 0.9
         let height: CGFloat = width + 10 /// 가로 + top inset
         return height
     }
     
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
         guard self.cards.isEmpty == false else { return }
         
         let offset = scrollView.contentOffset.y
         
         // offset이 currentOffset보다 크면 아래로 스크롤, 반대일 경우 위로 스크롤
         // 위로 스크롤 중일 때 헤더뷰 표시, 아래로 스크롤 중일 때 헤더뷰 숨김
         self.headerContainer.isHidden = offset <= 0 ? false : offset > self.currentOffset
         self.tableViewTopConstraint?.deactivate()
         self.tableView.snp.makeConstraints {
             let top = self.headerContainer.isHidden ? self.view.safeAreaLayoutGuide.snp.top : self.headerContainer.snp.bottom
             self.tableViewTopConstraint = $0.top.equalTo(top).constraint
         }
         
         // 최상단일 때만 moveToButton 숨김
         self.moveTopButton.isHidden = offset <= 0
         
         self.currentOffset = offset
     }
 }


// MARK: MainHomeHeaderView Delegate

extension MainHomeViewController: SOMHomeTabBarDelegate {
    
    func tabBar(_ tabBar: SOMHomeTabBar, shouldSelectTabAt index: Int) -> Bool {
        
        if index == 2, self.reactor?.locationManager.checkLocationAuthStatus() == .denied {
            
            let presented = SOMDialogViewController()
            presented.setData(
                title: Text.dialogTitle,
                subTitle: Text.dialogSubTitle,
                leftAction: .init(
                    mode: .cancel,
                    handler: { [weak self] in self?.dismiss(animated: true) }
                ),
                rightAction: .init(
                    mode: .setting,
                    handler: { [weak self] in
                        let application = UIApplication.shared
                        let openSettingsURLString: String = UIApplication.openSettingsURLString
                        if let settingsURL = URL(string: openSettingsURLString),
                            application.canOpenURL(settingsURL) {
                                application.open(settingsURL)
                        }
                        self?.dismiss(animated: false)
                    }
                ),
                dimViewAction: nil
            )
            presented.modalPresentationStyle = .custom
            presented.modalTransitionStyle = .crossDissolve
            
            self.present(presented, animated: true)
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
