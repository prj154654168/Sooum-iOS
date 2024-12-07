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
            .map { _ in Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        isLoading
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
        
        cell.cancelFollowButton.rx.throttleTap(.seconds(3))
            .subscribe(onNext: { _ in
                cell.updateButton(false)
                reactor.action.onNext(.cancel(model.id))
            })
            .disposed(by: cell.disposeBag)
        
        cell.followButton.rx.throttleTap(.seconds(3))
            .subscribe(onNext: { _ in
                cell.updateButton(true)
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
        
        cell.followButton.rx.throttleTap(.seconds(3))
            .subscribe(onNext: { _ in
                cell.updateButton(!model.isFollowing)
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
        
        return cell
    }
}