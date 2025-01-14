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


class NotificationViewController: BaseViewController, View {
    
    enum Text {
        static let withoutReadHeaderTitle: String = "읽지 않음"
    }
    
    enum Section: Int, CaseIterable {
        case withoutRead
        case read
        case empty
    }
    
    
    // MARK: Views
    
    private lazy var tableView = UITableView().then {
        $0.backgroundColor = .clear
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
            NotificationWithReportViewCell.self,
            forCellReuseIdentifier: NotificationWithReportViewCell.cellIdentifier
        )
        $0.register(
            NotiPlaceholderViewCell.self,
            forCellReuseIdentifier: NotiPlaceholderViewCell.cellIdentifier
        )
        
        $0.dataSource = self
        $0.delegate = self
    }
    
    
    // MARK: Variables
    
    private var notificationsWithoutRead = [CommentHistoryInNoti]()
    private var notifications = [CommentHistoryInNoti]()
    private var withoutReadNotisCount = "0"
    
    private var currentOffset: CGFloat = 0
    private var isRefreshEnabled: Bool = true
    private var isLoadingMore: Bool = false
    
    
    // MARK: Variables + Rx
    
    let willPushCardId = PublishRelay<String>()
    
    
    // MARK: Override func
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: NotificationViewReactor) {
        
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
        
        reactor.state.map(\.withoutReadNotisCount)
            .distinctUntilChanged()
            .subscribe(with: self) { object, withoutReadNotisCount in
                object.withoutReadNotisCount = withoutReadNotisCount
                
                UIView.performWithoutAnimation {
                    object.tableView.reloadData()
                }
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.notificationsWithoutRead)
            .distinctUntilChanged()
            .filterNil()
            .subscribe(with: self) { object, notificationsWithoutRead in
                object.tableView.isHidden = false
                
                object.notificationsWithoutRead = notificationsWithoutRead
                
                let indexSetForEmpty = IndexSet(integer: Section.empty.rawValue)
                let indexSetForWithoutRead = IndexSet(integer: Section.withoutRead.rawValue)
                UIView.performWithoutAnimation {
                    object.tableView.performBatchUpdates {
                        object.tableView.reloadSections(indexSetForEmpty, with: .none)
                        object.tableView.reloadSections(indexSetForWithoutRead, with: .none)
                    }
                }
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.notifications)
            .distinctUntilChanged()
            .filterNil()
            .subscribe(with: self) { object, notifications in
                object.tableView.isHidden = false
                
                object.notifications = notifications
                
                let indexSetForEmpty = IndexSet(integer: Section.empty.rawValue)
                let indexSetForRead = IndexSet(integer: Section.read.rawValue)
                UIView.performWithoutAnimation {
                    object.tableView.performBatchUpdates {
                        object.tableView.reloadSections(indexSetForEmpty, with: .none)
                        object.tableView.reloadSections(indexSetForRead, with: .none)
                    }
                }
            }
            .disposed(by: self.disposeBag)
    }
}

extension NotificationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch Section.allCases[section] {
        case .withoutRead:
            return self.notificationsWithoutRead.count
        case .read:
            return self.notifications.count
        case .empty:
            return (self.notificationsWithoutRead.isEmpty && self.notifications.isEmpty) ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch Section.allCases[indexPath.section] {
        case .withoutRead:
            
            let model: CommentHistoryInNoti = self.notificationsWithoutRead[indexPath.row]
            switch model.type {
            case .blocked, .delete:
                
                let cell: NotificationWithReportViewCell = tableView.dequeueReusableCell(
                    withIdentifier: NotificationWithReportViewCell.cellIdentifier,
                    for: indexPath
                ) as! NotificationWithReportViewCell
                cell.selectionStyle = .none
                cell.bind(model)
                
                return cell
                
            default:
                
                let cell: NotificationViewCell = tableView.dequeueReusableCell(
                    withIdentifier: NotificationViewCell.cellIdentifier,
                    for: indexPath
                ) as! NotificationViewCell
                cell.selectionStyle = .none
                cell.bind(model, isReaded: false)
                
                return cell
            }
            
        case .read:
            
            let cell: NotificationViewCell = tableView.dequeueReusableCell(
                withIdentifier: NotificationViewCell.cellIdentifier,
                for: indexPath
            ) as! NotificationViewCell
            cell.selectionStyle = .none
            cell.bind(self.notifications[indexPath.row], isReaded: true)
            
            return cell
            
        case .empty:
            
            let placeholder: NotiPlaceholderViewCell = tableView.dequeueReusableCell(
                withIdentifier: NotiPlaceholderViewCell.cellIdentifier,
                for: indexPath
            ) as! NotiPlaceholderViewCell
            
            return placeholder
        }
    }
}

extension NotificationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch Section.allCases[indexPath.section] {
        case .withoutRead:
            let selectedId = self.notificationsWithoutRead[indexPath.row].id
            
            self.reactor?.action.onNext(.requestRead("\(selectedId)"))
            let targetCardId = self.notificationsWithoutRead[indexPath.row].targetCardId
            self.willPushCardId.accept("\(targetCardId ?? 0)")
        case .read:
            let targetCardId = self.notifications[indexPath.row].targetCardId
            self.willPushCardId.accept("\(targetCardId ?? 0)")
        case .empty:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch Section.allCases[section] {
        case .withoutRead:
            
            let backgroundView = UIView().then {
                $0.backgroundColor = .som.white
            }
            
            let typography = Typography.som.body2WithBold
            let frame = CGRect(x: 20, y: 16, width: UIScreen.main.bounds.width, height: typography.lineHeight)
            let label = UILabel().then {
                $0.text = Text.withoutReadHeaderTitle + " (\(self.withoutReadNotisCount)개)"
                $0.textColor = .som.black
                $0.typography = typography
                
                $0.frame = frame
            }
            backgroundView.addSubview(label)
            
            return self.notificationsWithoutRead.isEmpty ? nil : backgroundView
            
        case .read:
            
            let backgroundView = UIView().then {
                $0.backgroundColor = .som.white
            }
            
            let frame = CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width, height: 4)
            let seperator = UIView().then {
                $0.backgroundColor = .som.gray100
                
                $0.frame = frame
            }
            backgroundView.addSubview(seperator)
            
            return self.notificationsWithoutRead.isEmpty ? nil : backgroundView
            
        case .empty:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch Section.allCases[indexPath.section] {
        case .withoutRead:
            if self.notificationsWithoutRead.isEmpty == false {
                let type = self.notificationsWithoutRead[indexPath.row].type
                switch type {
                case .blocked, .delete:
                    return 55
                default:
                    return 64
                }
            } else {
                return 64
            }
        case .read:
            return 64
        case .empty:
            return self.tableView.bounds.height
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch Section.allCases[section] {
        case .withoutRead:
            return self.notificationsWithoutRead.isEmpty ? 0 : 46
        case .read:
            return self.notificationsWithoutRead.isEmpty ? 10 : 24
        case .empty:
            return 0
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        guard self.notificationsWithoutRead.isEmpty == false ||
                self.notifications.isEmpty == false
        else { return }
        
        let sectionIndexForWithoutRead = Section.withoutRead.rawValue
        let lastRowIndexForWithoutRead = tableView.numberOfRows(inSection: sectionIndexForWithoutRead) - 1
        let sectionIndexForRead = Section.read.rawValue
        let lastRowIndexForRead = tableView.numberOfRows(inSection: sectionIndexForRead) - 1
        
        
        if self.isLoadingMore,
           indexPath.section == sectionIndexForWithoutRead,
           indexPath.row == lastRowIndexForWithoutRead {
            
            let withoutReadLastId = self.notificationsWithoutRead.last?.id.description
            self.reactor?.action.onNext(.moreFind(withoutReadLastId: withoutReadLastId, readLastId: nil))
        }
        
        if self.isLoadingMore,
           indexPath.section == sectionIndexForRead,
           indexPath.row == lastRowIndexForRead {
            
            let readLastId = self.notifications.last?.id.description
            self.reactor?.action.onNext(.moreFind(withoutReadLastId: nil, readLastId: readLastId))
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        
        // currentOffset <= 0 && isLoading == false 일 때, 테이블 뷰 새로고침 가능
        self.isRefreshEnabled = (offset <= 0 && self.reactor?.currentState.isLoading == false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        
        // 당겨서 새로고침 상황일 때
        guard offset > 0 else { return }
        
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
