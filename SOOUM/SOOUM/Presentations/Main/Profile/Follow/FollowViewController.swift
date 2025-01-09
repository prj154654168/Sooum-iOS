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
    }
    
    private lazy var tableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.indicatorStyle = .black
        $0.separatorStyle = .none
        
        $0.decelerationRate = .fast
        
        $0.register(MyFollowingViewCell.self, forCellReuseIdentifier: MyFollowingViewCell.cellIdentifier)
        $0.register(MyFollowerViewCell.self, forCellReuseIdentifier: MyFollowerViewCell.cellIdentifier)
        $0.register(OtherFollowViewCell.self, forCellReuseIdentifier: OtherFollowViewCell.cellIdentifier)
        
        $0.refreshControl = SOMRefreshControl()
        
        $0.dataSource = self
        $0.delegate = self
    }
    
    override var navigationBarHeight: CGFloat {
        46
    }
    
    private(set) var follows = [Follow]()
    
    private var currentOffset: CGFloat = 0
    private var isRefreshEnabled: Bool = true
    private var isLoadingMore: Bool = false
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        let title = self.reactor?.entranceType == .following ? Text.followingTitle : Text.followerTitle
        self.navigationBar.title = title + " (0)"
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: FollowViewReactor) {
        
        // Action
        self.rx.viewDidLoad
            .map { _ in Reactor.Action.landing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        let isLoading = reactor.state.map(\.isLoading).distinctUntilChanged().share()
        self.tableView.refreshControl?.rx.controlEvent(.valueChanged)
            .withLatestFrom(isLoading)
            .filter { $0 == false }
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .map { _ in Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        isLoading
            .do(onNext: { [weak self] isLoading in
                if isLoading { self?.isLoadingMore = false }
            })
            .subscribe(with: self.tableView) { tableView, isLoading in
                if isLoading {
                    tableView.refreshControl?.beginRefreshingFromTop()
                } else {
                    tableView.refreshControl?.endRefreshing()
                }
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isProcessing)
            .distinctUntilChanged()
            .do(onNext: { [weak self] isProcessing in
                if isProcessing { self?.isLoadingMore = false }
            })
            .bind(to: self.activityIndicatorView.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        let follows = reactor.state.map(\.follows).distinctUntilChanged().share()
        follows
            .map {
                let title = reactor.entranceType == .following ? Text.followingTitle : Text.followerTitle
                return title + "(\($0.count))"
            }
            .bind(to: self.navigationBar.rx.title)
            .disposed(by: self.disposeBag)
        follows
            .subscribe(with: self) { object, follows in
                object.follows = follows
                object.tableView.reloadData()
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isRequest)
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in Reactor.Action.landing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isCancel)
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in Reactor.Action.landing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }
}

extension FollowViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.follows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let reactor = self.reactor else { return .init(frame: .zero) }
        
        switch reactor.viewType {
        case .my:
            switch reactor.entranceType {
            case .following:
                
                return self.cellForMyFollowing(indexPath, reactor: reactor)
            case .follower:
                
                return self.cellForMyFollower(indexPath, reactor: reactor)
            }
        case .other:
            
            return self.cellForOtherFollow(indexPath, reactor: reactor)
        }
    }
}

extension FollowViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        guard self.follows.isEmpty == false else { return }
        
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        
        if self.isLoadingMore, indexPath.section == lastSectionIndex, indexPath.row == lastRowIndex {
            let lastId = self.follows[indexPath.row].id
            self.reactor?.action.onNext(.moreFind(lastId: lastId))
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        // currentOffset <= 0 일 때, 테이블 뷰 새로고침 가능
        let offset = scrollView.contentOffset.y
        self.isRefreshEnabled = offset <= 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        
        // 아래로 스크롤 중일 때, 데이터 추가로드 가능
        self.isLoadingMore = offset > self.currentOffset
        self.currentOffset = offset
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let offset = scrollView.contentOffset.y
        
        // isRefreshEnabled == true 이고, 스크롤이 끝났을 경우에만 테이블 뷰 새로고침
        if self.isRefreshEnabled,
           let refreshControl = self.tableView.refreshControl,
           offset <= -(refreshControl.frame.origin.y + 40) {
            
            refreshControl.beginRefreshingFromTop()
        }
    }
}

extension FollowViewController {
    
    private func cellForMyFollowing(_ indexPath: IndexPath, reactor: FollowViewReactor) -> MyFollowingViewCell {
        
        let model = self.follows[indexPath.row]
        
        let cell: MyFollowingViewCell = self.tableView.dequeueReusableCell(
            withIdentifier: MyFollowingViewCell.cellIdentifier,
            for: indexPath
        ) as! MyFollowingViewCell
        cell.selectionStyle = .none
        cell.setModel(model)
        cell.updateButton(model.isFollowing)
        
        cell.profilBackgroundButton.rx.tap
            .subscribe(with: self) { object, _ in
                
                if model.isRequester {
                    
                    let profileViewController = ProfileViewController()
                    profileViewController.reactor = reactor.reactorForProfile(type: .myWithNavi, model.id)
                    object.navigationPush(profileViewController, animated: true, bottomBarHidden: true)
                } else {
                    
                    let profileViewController = ProfileViewController()
                    profileViewController.reactor = reactor.reactorForProfile(type: .other, model.id)
                    object.navigationPush(profileViewController, animated: true, bottomBarHidden: true)
                }
            }
            .disposed(by: cell.disposeBag)
        
        cell.cancelFollowButton.rx.throttleTap(.seconds(1))
            .subscribe(onNext: { _ in
                reactor.action.onNext(.cancel(model.id))
            })
            .disposed(by: cell.disposeBag)
        
        cell.followButton.rx.throttleTap(.seconds(1))
            .subscribe(onNext: { _ in
                reactor.action.onNext(.request(model.id))
            })
            .disposed(by: cell.disposeBag)
        
        return cell
    }
    
    private func cellForMyFollower(_ indexPath: IndexPath, reactor: FollowViewReactor) -> MyFollowerViewCell {
        
        let model = self.follows[indexPath.row]
        
        let cell: MyFollowerViewCell = self.tableView.dequeueReusableCell(
            withIdentifier: MyFollowerViewCell.cellIdentifier,
            for: indexPath
        ) as! MyFollowerViewCell
        cell.selectionStyle = .none
        cell.setModel(model)
        cell.updateButton(model.isFollowing)
        
        cell.profilBackgroundButton.rx.tap
            .subscribe(with: self) { object, _ in
                
                if model.isRequester {
                    
                    let profileViewController = ProfileViewController()
                    profileViewController.reactor = reactor.reactorForProfile(type: .myWithNavi, model.id)
                    object.navigationPush(profileViewController, animated: true, bottomBarHidden: true)
                } else {
                    
                    let profileViewController = ProfileViewController()
                    profileViewController.reactor = reactor.reactorForProfile(type: .other, model.id)
                    object.navigationPush(profileViewController, animated: true, bottomBarHidden: true)
                }
            }
            .disposed(by: cell.disposeBag)
        
        cell.followButton.rx.throttleTap(.seconds(1))
            .subscribe(onNext: { _ in
                reactor.action.onNext(model.isFollowing ? .cancel(model.id) : .request(model.id))
            })
            .disposed(by: cell.disposeBag)
        
        return cell
    }
    
    private func cellForOtherFollow(_ indexPath: IndexPath, reactor: FollowViewReactor) -> OtherFollowViewCell {
        
        let model = self.follows[indexPath.row]
        
        let cell: OtherFollowViewCell = self.tableView.dequeueReusableCell(
            withIdentifier: OtherFollowViewCell.cellIdentifier,
            for: indexPath
        ) as! OtherFollowViewCell
        cell.selectionStyle = .none
        cell.setModel(model)
        cell.updateButton(model.isFollowing)
        
        cell.profilBackgroundButton.rx.tap
            .subscribe(with: self) { object, _ in
                
                if model.isRequester {
                    
                    let profileViewController = ProfileViewController()
                    profileViewController.reactor = reactor.reactorForProfile(type: .myWithNavi, model.id)
                    object.navigationPush(profileViewController, animated: true, bottomBarHidden: true)
                } else {
                    
                    let profileViewController = ProfileViewController()
                    profileViewController.reactor = reactor.reactorForProfile(type: .other, model.id)
                    object.navigationPush(profileViewController, animated: true, bottomBarHidden: true)
                }
            }
            .disposed(by: cell.disposeBag)
        
        cell.followButton.rx.throttleTap(.seconds(1))
            .subscribe(with: self) { object, _ in
                reactor.action.onNext(model.isFollowing ? .cancel(model.id) : .request(model.id))
            }
            .disposed(by: cell.disposeBag)
        
        return cell
    }
}
