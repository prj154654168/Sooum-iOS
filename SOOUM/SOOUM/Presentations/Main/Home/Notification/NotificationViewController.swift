//
//  NotificationViewController.swift
//  SOOUM
//
//  Created by 오현식 on 12/23/24.
//

import UIKit

import SnapKit
import Then

import ReactorKit
import RxCocoa
import RxSwift

class NotificationViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let navigationTitle: String = "알림"
        
        static let activityTitle: String = "활동"
        static let noticeTitle: String = "공지사항"
        
        static let headerTextForRead: String = "지난 알림"
    }
    
    enum Section: Int, CaseIterable {
        case unread
        case read
        case notice
        case empty
    }
    
    enum Item: Hashable {
        case unread(CompositeNotificationInfo)
        case read(CompositeNotificationInfo)
        case notice(NoticeInfo)
        case empty
    }
    
    
    // MARK: Views
    
    private lazy var headerView = SOMSwipableTabBar().then {
        $0.items = [Text.activityTitle, Text.noticeTitle]
        $0.delegate = self
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .som.v2.white
        $0.indicatorStyle = .black
        $0.separatorStyle = .none
        
        $0.isHidden = true
        
        $0.sectionHeaderTopPadding = .zero
        $0.decelerationRate = .fast
        
        $0.refreshControl = SOMRefreshControl()
        
        $0.register(
            NotificationViewCell.self,
            forCellReuseIdentifier: NotificationViewCell.cellIdentifier
        )
        $0.register(
            NoticeViewCell.self,
            forCellReuseIdentifier: NoticeViewCell.cellIdentifier
        )
        $0.register(
            NotificationPlaceholderViewCell.self,
            forCellReuseIdentifier: NotificationPlaceholderViewCell.cellIdentifier
        )
        
        $0.delegate = self
    }
    
    
    // MARK: Variables
    
    typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private lazy var dataSource = DataSource(tableView: self.tableView) { [weak self] tableView, indexPath, item -> UITableViewCell? in
        
        guard let self = self else { return nil }
        
        switch item {
        case let .unread(notification):
            
            let cell: NotificationViewCell = self.cellForNotification(tableView, with: indexPath)
            cell.bind(notification, isReaded: false)
            
            return cell
        case let .read(notification):
            
            let cell: NotificationViewCell = self.cellForNotification(tableView, with: indexPath)
            cell.bind(notification, isReaded: true)
            
            return cell
        case let .notice(notice):
            
            let cell: NoticeViewCell = self.cellForNotice(tableView, with: indexPath)
            cell.bind(notice)
            
            return cell
        case .empty:
            
            return self.cellForPlaceholder(tableView, with: indexPath)
        }
    }
    
    private var initialOffset: CGFloat = 0
    private var currentOffset: CGFloat = 0
    private var isRefreshEnabled: Bool = true
    private var shouldRefreshing: Bool = false
    
    
    // MARK: Variables + Rx
    
    let willPushCardId = PublishRelay<String>()
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.headerView)
        self.headerView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
        }
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.top.equalTo(self.headerView.snp.bottom)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: NotificationViewReactor) {
        
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
        
        reactor.state.map(\.displayType)
            .filter { $0 == .notice }
            .take(1)
            .subscribe(with: self.headerView) { headerView, _ in
                headerView.didSelectTabBarItem(1, onlyUpdateApperance: true)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map {
            NotificationViewReactor.DisplayStates(
                displayType: $0.displayType,
                unreads: $0.notificationsForUnread,
                reads: $0.notifications,
                notices: $0.notices
            )
        }
        .observe(on: MainScheduler.asyncInstance)
        .subscribe(with: self) { object, displayStats in
            
            var snapshot = Snapshot()
            snapshot.appendSections(Section.allCases)
            
            switch displayStats.displayType {
            case .activity:
                
                guard let unreads = displayStats.unreads, let reads = displayStats.reads else { return }
                
                if unreads.isEmpty && reads.isEmpty {
                    snapshot.appendItems([.empty], toSection: .empty)
                    break
                }
                
                let newUnreads = unreads.map { Item.unread($0) }
                snapshot.appendItems(newUnreads, toSection: .unread)
                
                let newReads = reads.map { Item.read($0) }
                snapshot.appendItems(newReads, toSection: .read)
            case .notice:
                
                guard let notices = displayStats.notices else { return }
                
                guard notices.isEmpty == false else {
                    snapshot.appendItems([.empty], toSection: .empty)
                    break
                }
                
                let new = notices.map { Item.notice($0) }
                snapshot.appendItems(new, toSection: .notice)
            }
            
            object.dataSource.apply(snapshot, animatingDifferences: false)
            
            object.tableView.isHidden = false
        }
        .disposed(by: self.disposeBag)
    }
}


// MARK: Cells

private extension NotificationViewController {
    
    func cellForPlaceholder(
        _ tableView: UITableView,
        with indexPath: IndexPath
    ) -> NotificationPlaceholderViewCell {
        
        return tableView.dequeueReusableCell(
            withIdentifier: NotificationPlaceholderViewCell.cellIdentifier,
            for: indexPath
        ) as! NotificationPlaceholderViewCell
    }
    
    func cellForNotification(
        _ tableView: UITableView,
        with indexPath: IndexPath
    ) -> NotificationViewCell {
        
        return tableView.dequeueReusableCell(
            withIdentifier: NotificationViewCell.cellIdentifier,
            for: indexPath
        ) as! NotificationViewCell
    }
    
    func cellForNotice(
        _ tableView: UITableView,
        with indexPath: IndexPath
    ) -> NoticeViewCell {
        
        return tableView.dequeueReusableCell(
            withIdentifier: NoticeViewCell.cellIdentifier,
            for: indexPath
        ) as! NoticeViewCell
    }
}


// MARK: UITableViewDelegate

extension NotificationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // TODO: 상세보기 or 공지사항 화면 전환 필요
        // switch Section.allCases[indexPath.section] {
        // case .withoutRead:
        //     let selectedId = self.notificationsWithoutRead[indexPath.row].id
        //
        //     self.reactor?.action.onNext(.requestRead("\(selectedId)"))
        //     let targetCardId = self.notificationsWithoutRead[indexPath.row].targetCardId
        //     self.willPushCardId.accept("\(targetCardId ?? 0)")
        // case .read:
        //     let targetCardId = self.notifications[indexPath.row].targetCardId
        //     self.willPushCardId.accept("\(targetCardId ?? 0)")
        // case .empty:
        //     break
        // }
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case let .notice(notice):
            
            if let urlString = notice.url, let url = URL(string: urlString),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case let .unread(notification):
            
            var detailInfo: (detailType: DetailViewReactor.DetailType, id: String)? {
                switch notification {
                case let .default(notification):
                    if case .feedLike = notification.notificationInfo.notificationType {
                        return (.feed, notification.targetCardId)
                    }
                    if case .commentLike = notification.notificationInfo.notificationType {
                        return (.comment, notification.targetCardId)
                    }
                    if case .commentWrite = notification.notificationInfo.notificationType {
                        return (.comment, notification.targetCardId)
                    }
                    return nil
                default:
                    return nil
                }
            }
            guard let detailInfo = detailInfo else { return }
            
            let detailViewController = DetailViewController()
            detailViewController.reactor = self.reactor?.reactorForDetail(
                detailType: detailInfo.detailType,
                with: detailInfo.id
            )
            self.navigationPush(detailViewController, animated: true, bottomBarHidden: true)
        case let .read(notification):
            
            var detailInfo: (detailType: DetailViewReactor.DetailType, id: String)? {
                switch notification {
                case let .default(notification):
                    if case .feedLike = notification.notificationInfo.notificationType {
                        return (.feed, notification.targetCardId)
                    }
                    if case .commentLike = notification.notificationInfo.notificationType {
                        return (.comment, notification.targetCardId)
                    }
                    if case .commentWrite = notification.notificationInfo.notificationType {
                        return (.comment, notification.targetCardId)
                    }
                    return nil
                default:
                    return nil
                }
            }
            guard let detailInfo = detailInfo else { return }
            
            let detailViewController = DetailViewController()
            detailViewController.reactor = self.reactor?.reactorForDetail(
                detailType: detailInfo.detailType,
                with: detailInfo.id
            )
            self.navigationPush(detailViewController, animated: true, bottomBarHidden: true)
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sections = self.dataSource.snapshot().sectionIdentifiers
        guard sections.isEmpty == false, self.headerView.selectedIndex != 1 else { return nil }
        
        switch sections[section] {
        case .read:
            
            let backgroundView = UIView().then {
                $0.backgroundColor = .som.v2.white
            }
            
            let label = UILabel().then {
                $0.text = Text.headerTextForRead
                $0.textColor = .som.v2.black
                
                let typography = Typography.som.v2.subtitle3.withAlignment(.left)
                $0.typography = typography
                
                let frame = CGRect(
                    x: 25,
                    y: 32,
                    width: UIScreen.main.bounds.width,
                    height: typography.lineHeight
                )
                $0.frame = frame
            }
            backgroundView.addSubview(label)
            
            return backgroundView
        default:
            
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let sections = self.dataSource.snapshot().sectionIdentifiers
        guard sections.isEmpty == false, self.headerView.selectedIndex != 1 else { return 0 }
        
        switch sections[section] {
        case .read:
            
            return (self.reactor?.currentState.notifications?.isEmpty ?? true) ? 0 : 53
        default:
            
            return 0
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        
        guard let reactor = self.reactor, reactor.currentState.isRefreshing == false else { return }
        
        switch reactor.currentState.displayType {
        case let .activity(activityType):
            
            switch activityType {
            case .unread:
                
                let lastRowIndexPath = tableView.numberOfRows(inSection: Section.unread.rawValue) - 1
                if reactor.currentState.notificationsForUnread?.isEmpty == false,
                   indexPath.section == Section.unread.rawValue,
                   indexPath.row == lastRowIndexPath {
                    
                    var lastId: String {
                        switch reactor.currentState.notificationsForUnread?.last {
                        case let .default(notification):
                            return notification.notificationInfo.notificationId
                        case let .follow(notification):
                            return notification.notificationInfo.notificationId
                        case let .deleted(notification):
                            return notification.notificationInfo.notificationId
                        case let .blocked(notification):
                            return notification.notificationInfo.notificationId
                        default:
                            return ""
                        }
                    }
                    reactor.action.onNext(.moreFind(lastId: lastId, displayType: .activity(.unread)))
                }
            case .read:
                
                let lastRowIndexPath = tableView.numberOfRows(inSection: Section.read.rawValue) - 1
                if reactor.currentState.notifications?.isEmpty == false,
                   indexPath.section == Section.read.rawValue,
                   indexPath.row == lastRowIndexPath {
                    
                    var lastId: String {
                        switch reactor.currentState.notificationsForUnread?.last {
                        case let .default(notification):
                            return notification.notificationInfo.notificationId
                        case let .follow(notification):
                            return notification.notificationInfo.notificationId
                        case let .deleted(notification):
                            return notification.notificationInfo.notificationId
                        case let .blocked(notification):
                            return notification.notificationInfo.notificationId
                        default:
                            return ""
                        }
                    }
                    reactor.action.onNext(.moreFind(lastId: lastId, displayType: .activity(.read)))
                }
            }
        case .notice:
            
            let lastRowIndexPath = tableView.numberOfRows(inSection: Section.notice.rawValue) - 1
            if reactor.currentState.notices?.isEmpty == false,
               indexPath.section == Section.notice.rawValue,
               indexPath.row == lastRowIndexPath {
                
                let lastId = reactor.currentState.notices?.last?.id ?? ""
                reactor.action.onNext(.moreFind(lastId: lastId, displayType: .notice))
            }
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
        
        // 당겨서 새로고침
        if self.isRefreshEnabled, offset < self.initialOffset {
            guard let refreshControl = self.tableView.refreshControl else {
                self.currentOffset = offset
                return
            }
            
            let pulledOffset = self.initialOffset - offset
            let refreshingOffset = refreshControl.frame.origin.y + refreshControl.frame.height
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


// MARK: SOMSwipableTabBarDelegate

extension NotificationViewController: SOMSwipableTabBarDelegate {
    
    func tabBar(_ tabBar: SOMSwipableTabBar, didSelectTabAt index: Int) {
        
        self.tableView.reloadData()
        
        self.reactor?.action.onNext(.updateDisplayType(index == 1 ? .notice : .activity(.unread)))
    }
}
