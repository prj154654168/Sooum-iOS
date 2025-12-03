//
//  BlockUsersViewController.swift
//  SOOUM
//
//  Created by 오현식 on 11/9/25.
//

import UIKit

import SnapKit
import Then

import ReactorKit
import RxCocoa
import RxSwift

class BlockUsersViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let navigationTitle: String = "차단 사용자 관리"
        
        static let unBlockUserDialogTitle: String = "차단 해제하시겠어요?"
        static let unBlockUserDialogMessage: String = "님을 팔로우하고, 카드를 볼 수 있어요."
        
        static let cancelActionButtonTitle: String = "취소"
        static let unBlockActionButtonTitle: String = "차단 해제"
    }
    
    enum Section: Int, CaseIterable {
        case main
        case empty
    }
    
    enum Item: Hashable {
        case main(BlockUserInfo)
        case empty
    }
    
    
    // MARK: Views
    
    private lazy var tableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.indicatorStyle = .black
        $0.separatorStyle = .none
        
        $0.contentInsetAdjustmentBehavior = .never
        
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        
        $0.register(BlockUserViewCell.self, forCellReuseIdentifier: BlockUserViewCell.cellIdentifier)
        $0.register(BlockUserPlaceholderViewCell.self, forCellReuseIdentifier: BlockUserPlaceholderViewCell.cellIdentifier)
        
        $0.refreshControl = SOMRefreshControl()
        
        $0.delegate = self
    }
    
    
    // MARK: Variables
    
    typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private lazy var dataSource = DataSource(tableView: self.tableView) { [weak self] tableView, indexPath, item -> UITableViewCell? in
        
        guard let self = self, let reactor = self.reactor else { return nil }
        
        switch item {
        case let .main(blockUserInfo):
            
            let cell: BlockUserViewCell = tableView.dequeueReusableCell(
                withIdentifier: BlockUserViewCell.cellIdentifier,
                for: indexPath
            ) as! BlockUserViewCell
            
            cell.setModel(blockUserInfo)
            
            cell.profileBackgroundButton.rx.throttleTap(.seconds(3))
                .subscribe(with: self) { object, _ in
                    let profileViewController = ProfileViewController()
                    profileViewController.reactor = reactor.reactorForProfile(blockUserInfo.userId)
                    object.navigationPush(profileViewController, animated: true, bottomBarHidden: true)
                }
                .disposed(by: cell.disposeBag)
            
            cell.unBlockUserButton.rx.throttleTap
                .subscribe(with: self) { object, _ in
                    object.showUnblockDialog(
                        nickname: blockUserInfo.nickname,
                        with: blockUserInfo.userId
                    )
                }
                .disposed(by: cell.disposeBag)
            
            return cell
        case .empty:
            
            let placeholder: BlockUserPlaceholderViewCell = tableView.dequeueReusableCell(
                withIdentifier: BlockUserPlaceholderViewCell.cellIdentifier,
                for: indexPath
            ) as! BlockUserPlaceholderViewCell
            
            return placeholder
        }
    }
    
    private(set) var blockUserInfos: [BlockUserInfo] = []
    
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
        
        self.navigationBar.title = Text.navigationTitle
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: BlockUsersViewReactor) {
        
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
        
        reactor.state.map(\.blockUserInfos)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, blockUserInfos in
                
                var snapshot = Snapshot()
                snapshot.appendSections(Section.allCases)
                
                if blockUserInfos.isEmpty {
                    snapshot.appendItems([.empty], toSection: .empty)
                } else {
                    let new = blockUserInfos.map { Item.main($0) }
                    snapshot.appendItems(new, toSection: .main)
                }
                
                object.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isCanceled)
            .filterNil()
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in Reactor.Action.landing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }
}


// MARK: Show dialog

extension BlockUsersViewController {
    
    func showUnblockDialog(nickname: String, with userId: String) {
        
        let cancelAction = SOMDialogAction(
            title: Text.cancelActionButtonTitle,
            style: .gray,
            action: {
                UIApplication.topViewController?.dismiss(animated: true)
            }
        )
        
        let unBlockAction = SOMDialogAction(
            title: Text.unBlockActionButtonTitle,
            style: .red,
            action: {
                UIApplication.topViewController?.dismiss(animated: true) {
                    self.reactor?.action.onNext(.cancelBlock(userId: userId))
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


// MARK: UITableViewDelegate

extension BlockUsersViewController: UITableViewDelegate {
    
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
        
        let lastItemIndexPath = tableView.numberOfRows(inSection: Section.main.rawValue) - 1
        if self.blockUserInfos.isEmpty == false,
           indexPath.section == Section.main.rawValue,
           indexPath.row == lastItemIndexPath,
           let lastId = self.blockUserInfos.last?.userId {
            
            reactor.action.onNext(.moreFind(lastId: lastId))
        }
    }
    
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        
        // currentOffset <= 0 && isRefreshing == false 일 때, 테이블 뷰 새로고침 가능
        self.isRefreshEnabled = (offset <= 0) && (self.reactor?.currentState.isRefreshing == false)
        self.shouldRefreshing = false
        self.initialOffset = offset
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
            self.tableView.refreshControl?.beginRefreshing()
        }
    }
}
