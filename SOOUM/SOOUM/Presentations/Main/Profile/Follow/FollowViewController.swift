//
//  FollowViewController.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import UIKit

import SnapKit
import Then

import ReactorKit
import RxCocoa
import RxSwift

class FollowViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let followerTitle: String = "팔로워"
        static let followingTitle: String = "팔로잉"
        
        static let followerPlaceholderMessage: String = "팔로우하는 사람이 없어요"
        static let followingPlaceholderMessage: String = "팔로우하고 있는 사람이 없어요"
    }
    
    enum Section: Int, CaseIterable {
        case follower
        case following
        case empty
    }
    
    enum Item: Hashable {
        case follower(FollowInfo)
        case following(FollowInfo)
        case empty
    }
    
    
    // MARK: Views
    
    private lazy var stickyTabBar = SOMStickyTabBar(alignment: .center).then {
        $0.items = [Text.followerTitle, Text.followingTitle]
        $0.spacing = 24
        $0.delegate = self
    }
    
    private lazy var tableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.indicatorStyle = .black
        $0.separatorStyle = .none
        
        $0.contentInsetAdjustmentBehavior = .never
        
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        
        $0.register(FollowerViewCell.self, forCellReuseIdentifier: FollowerViewCell.cellIdentifier)
        $0.register(MyFollowingViewCell.self, forCellReuseIdentifier: MyFollowingViewCell.cellIdentifier)
        $0.register(FollowPlaceholderViewCell.self, forCellReuseIdentifier: FollowPlaceholderViewCell.cellIdentifier)
        
        $0.refreshControl = SOMRefreshControl()
        
        $0.delegate = self
    }
    
    
    // MARK: Variables
    
    typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private lazy var dataSource = DataSource(tableView: self.tableView) { [weak self] tableView, indexPath, item -> UITableViewCell? in
        
        guard let self = self, let reactor = self.reactor else { return nil }
        
        switch item {
        case let .follower(follower):
            
            let cell: FollowerViewCell = tableView.dequeueReusableCell(
                withIdentifier: FollowerViewCell.cellIdentifier,
                for: indexPath
            ) as! FollowerViewCell
            
            cell.setModel(follower)
            
            cell.profileBackgroundButton.rx.throttleTap
                .subscribe(with: self) { object, _ in
                    if follower.isRequester {
                        guard let navigationController = object.navigationController,
                            let tabBarController = navigationController.parent as? SOMTabBarController
                        else { return }
                        
                        if navigationController.viewControllers.first?.isKind(of: ProfileViewController.self) == true {
                            
                            object.navigationPopToRoot(animated: false, bottomBarHidden: false)
                        } else {
                            
                            tabBarController.didSelectedIndex(3)
                            navigationController.viewControllers.removeAll(where: { $0.isKind(of: HomeViewController.self) == false })
                        }
                    } else {
                        let profileViewController = ProfileViewController()
                        profileViewController.reactor = reactor.reactorForProfile(follower.memberId)
                        object.navigationPush(profileViewController, animated: true, bottomBarHidden: true)
                    }
                }
                .disposed(by: cell.disposeBag)
            
            cell.followButton.rx.throttleTap
                .subscribe(onNext: { _ in
                    reactor.action.onNext(.updateFollow(follower.memberId, !follower.isFollowing))
                })
                .disposed(by: cell.disposeBag)
            
            return cell
        case let .following(following):
            
            switch reactor.viewType {
            case .my:
                
                let cell: MyFollowingViewCell = tableView.dequeueReusableCell(
                    withIdentifier: MyFollowingViewCell.cellIdentifier,
                    for: indexPath
                ) as! MyFollowingViewCell
                
                cell.setModel(following)
                
                cell.profileBackgroundButton.rx.throttleTap
                    .subscribe(with: self) { object, _ in
                        let profileViewController = ProfileViewController()
                        profileViewController.reactor = reactor.reactorForProfile(following.memberId)
                        object.navigationPush(profileViewController, animated: true, bottomBarHidden: true)
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.cancelFollowButton.rx.throttleTap
                    .subscribe(onNext: { _ in
                        reactor.action.onNext(.updateFollow(following.memberId, false))
                    })
                    .disposed(by: cell.disposeBag)
                
                return cell
            case .other:
                
                let cell: FollowerViewCell = tableView.dequeueReusableCell(
                    withIdentifier: FollowerViewCell.cellIdentifier,
                    for: indexPath
                ) as! FollowerViewCell
                
                cell.setModel(following)
                
                cell.profileBackgroundButton.rx.throttleTap
                    .subscribe(with: self) { object, _ in
                        if following.isRequester {
                            guard let navigationController = object.navigationController,
                                let tabBarController = navigationController.parent as? SOMTabBarController
                            else { return }
                            
                            if navigationController.viewControllers.first?.isKind(of: ProfileViewController.self) == true {
                                
                                object.navigationPopToRoot(animated: false, bottomBarHidden: false)
                            } else {
                                
                                tabBarController.didSelectedIndex(3)
                                navigationController.viewControllers.removeAll(where: { $0.isKind(of: HomeViewController.self) == false })
                            }
                        } else {
                            let profileViewController = ProfileViewController()
                            profileViewController.reactor = reactor.reactorForProfile(following.memberId)
                            object.navigationPush(profileViewController, animated: true, bottomBarHidden: true)
                        }
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.followButton.rx.throttleTap
                    .subscribe(onNext: { _ in
                        reactor.action.onNext(.updateFollow(following.memberId, !following.isFollowing))
                    })
                    .disposed(by: cell.disposeBag)
                
                return cell
            }
        case .empty:
            
            let placeholder: FollowPlaceholderViewCell = tableView.dequeueReusableCell(
                withIdentifier: FollowPlaceholderViewCell.cellIdentifier,
                for: indexPath
            ) as! FollowPlaceholderViewCell
            
            placeholder.placeholderText = reactor.entranceType == .follower ?
                Text.followerPlaceholderMessage :
                Text.followingPlaceholderMessage
            
            return placeholder
        }
    }
    
    private(set) var followers: [FollowInfo] = []
    private(set) var followings: [FollowInfo] = []
    
    private var initialOffset: CGFloat = 0
    private var currentOffset: CGFloat = 0
    private var isRefreshEnabled: Bool = true
    private var shouldRefreshing: Bool = false
    
    
    // MARK: Override variables
    
    override var bottomToastMessageOffset: CGFloat {
        /// bottom safe layout guide + padding
        return 34 + 8
    }
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        guard let reactor = self.reactor else { return }
        
        self.navigationBar.title = reactor.nickname
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.stickyTabBar)
        self.stickyTabBar.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview()
        }
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.top.equalTo(self.stickyTabBar.snp.bottom)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
    }
    
    override func bind() {
        // 뒤로가기 시 상대 팔로우 화면이면 하단 네비바 숨김
        self.navigationBar.backButton.rx.throttleTap
            .subscribe(with: self) { object, _ in
                object.navigationPop(
                    animated: true,
                    bottomBarHidden: object.reactor?.viewType == .other
                )
            }
            .disposed(by: self.disposeBag)
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: FollowViewReactor) {
        
        // 팔로우 == 0, 팔로잉 == 1
        self.stickyTabBar.didSelectTabBarItem(reactor.entranceType == .follower ? 0 : 1)
        
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
            .filter { $0 == false }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self.tableView) { tableView, _ in
                tableView.refreshControl?.endRefreshing()
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map {
            FollowViewReactor.DisplayStates(
                followType: $0.followType,
                followers: $0.followers,
                followings: $0.followings
            )
        }
        .observe(on: MainScheduler.asyncInstance)
        .subscribe(with: self) { object, displayStates in
            
            var followerTabItem: String {
                if displayStates.followers.isEmpty == false {
                    return Text.followerTitle + " \(displayStates.followers.count)"
                }
                return Text.followerTitle
            }
            var followingTabItem: String {
                if displayStates.followings.isEmpty == false {
                    return Text.followingTitle + " \(displayStates.followings.count)"
                }
                return Text.followingTitle
            }
            
            object.stickyTabBar.items = [followerTabItem, followingTabItem]
            
            var snapshot = Snapshot()
            snapshot.appendSections(Section.allCases)
            
            switch displayStates.followType {
            case .follower:
                
                guard displayStates.followers.isEmpty == false else {
                    snapshot.appendItems([.empty], toSection: .empty)
                    break
                }
                
                let new = displayStates.followers.map { Item.follower($0) }
                snapshot.appendItems(new, toSection: .follower)
            case .following:
                
                guard displayStates.followings.isEmpty == false else {
                    snapshot.appendItems([.empty], toSection: .empty)
                    break
                }
                
                let new = displayStates.followings.map { Item.following($0) }
                snapshot.appendItems(new, toSection: .following)
            }
            
            object.dataSource.apply(snapshot, animatingDifferences: false)
        }
        .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isUpdated)
            .filterNil()
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(with: self) { object, _ in
                reactor.action.onNext(.landing)
                NotificationCenter.default.post(name: .reloadProfileData, object: nil, userInfo: nil)
            }
            .disposed(by: self.disposeBag)
    }
}


// MARK: UITableViewDelegate

extension FollowViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return 0 }
        
        switch item {
        case .empty:
            return tableView.bounds.height
        default:
            return 60
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        
        guard let reactor = self.reactor else { return }
        
        switch reactor.currentState.followType {
        case .follower:
            
            let lastItemIndexPath = tableView.numberOfRows(inSection: Section.follower.rawValue) - 1
            if self.followers.isEmpty == false,
               indexPath.section == Section.follower.rawValue,
               indexPath.row == lastItemIndexPath,
               let lastId = self.followers.last?.id {
                
                reactor.action.onNext(.moreFind(type: .follower, lastId: lastId))
            }
        case .following:
            
            let lastItemIndexPath = tableView.numberOfRows(inSection: Section.following.rawValue) - 1
            if self.followings.isEmpty == false,
               indexPath.section == Section.following.rawValue,
               indexPath.item == lastItemIndexPath,
               let lastId = self.followings.last?.id {
                
                reactor.action.onNext(.moreFind(type: .following, lastId: lastId))
            }
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
            guard let refreshControl = self.tableView.refreshControl else {
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
            self.tableView.refreshControl?.beginRefreshing()
        }
    }
}

extension FollowViewController: SOMStickyTabBarDelegate {
    
    func tabBar(_ tabBar: SOMStickyTabBar, didSelectTabAt index: Int) {
        
        self.reactor?.action.onNext(.updateFollowType(index == 0 ? .follower : .following))
    }
}
