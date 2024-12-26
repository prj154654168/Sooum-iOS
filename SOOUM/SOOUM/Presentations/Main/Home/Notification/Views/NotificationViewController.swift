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
        
        static let placeholderLabelText: String = "알림이 아직 없어요"
    }
    
    enum Section: CaseIterable {
        case withoutRead
        case read
    }
    
    
    // MARK: Views
    
    private lazy var tableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.indicatorStyle = .black
        $0.separatorStyle = .none
        
        $0.sectionHeaderTopPadding = .zero
        
        $0.register(NotificationViewCell.self, forCellReuseIdentifier: NotificationViewCell.cellIdentifier)
        $0.register(NotificationWithReportViewCell.self, forCellReuseIdentifier: NotificationWithReportViewCell.cellIdentifier)
        
        $0.dataSource = self
        $0.delegate = self
    }
    
    private let placeholderLabel = UILabel().then {
        $0.text = Text.placeholderLabelText
        $0.textColor = .init(hex: "#B4B4B4")
        $0.typography = .som.body1WithBold
    }
    
    
    // MARK: Variables
    
    private var notificationsWithoutRead = [CommentHistoryInNoti]()
    private var notifications = [CommentHistoryInNoti]()
    
    
    // MARK: Variables + Rx
    
    let willPushCardId = PublishRelay<String>()
    
    
    // MARK: Override func
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.view.addSubview(self.placeholderLabel)
        self.placeholderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIScreen.main.bounds.height * 0.3)
            $0.centerX.equalToSuperview()
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: NotificationViewReactor) {
        
        // Action
        self.rx.viewWillAppear
            .withUnretained(self.tableView)
            .map { _ in Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        let notificationsWithoutRead = reactor.state.map(\.notificationsWithoutRead).distinctUntilChanged().share()
        let notifications = reactor.state.map(\.notifications).distinctUntilChanged().share()
        
        Observable.combineLatest(
            reactor.state.map(\.isProcessing).distinctUntilChanged(),
            notificationsWithoutRead,
            notifications,
            resultSelector: { $0 == false && ($1.isEmpty == false || $2.isEmpty == false) }
        )
        .skip(1)
        .subscribe(with: self) { object, isHidden in
            object.placeholderLabel.isHidden = isHidden
        }
        .disposed(by: self.disposeBag)
        
        notificationsWithoutRead
            .subscribe(with: self) { object, notificationsWithoutRead in
                object.notificationsWithoutRead = notificationsWithoutRead
                UIView.performWithoutAnimation {
                    object.tableView.reloadSections(IndexSet(0...0), with: .none)
                }
            }
            .disposed(by: self.disposeBag)
        
        notifications
            .subscribe(with: self) { object, notifications in
                object.notifications = notifications
                UIView.performWithoutAnimation {
                    object.tableView.reloadSections(IndexSet(1...1), with: .none)
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
        }
    }
}

extension NotificationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch Section.allCases[indexPath.section] {
        case .withoutRead:
            let selectedId = self.notificationsWithoutRead[indexPath.row].id
            
            self.reactor?.action.onNext(.requestRead("\(selectedId)"))
        case .read:
            break
        }
        
        let targetCardId = self.notificationsWithoutRead[indexPath.row].targetCardId
        
        self.willPushCardId.accept("\(targetCardId ?? 0)")
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
                $0.text = Text.withoutReadHeaderTitle + " (\(self.notificationsWithoutRead.count)개)"
                $0.textColor = .som.black
                $0.typography = typography
                
                $0.frame = frame
            }
            backgroundView.addSubview(label)
            
            return self.notificationsWithoutRead.isEmpty ? nil : backgroundView
            
        case .read:
            
            let frame = CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width, height: 4)
            let seperator = UIView().then {
                $0.backgroundColor = .som.gray100
                
                $0.frame = frame
            }
            
            return self.notifications.isEmpty ? nil : seperator
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch Section.allCases[indexPath.row] {
        case .withoutRead:
            let type = self.notificationsWithoutRead[indexPath.row].type
            switch type {
            case .blocked, .delete:
                return 55
            default:
                return 64
            }
        case .read:
            return 64
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch Section.allCases[section] {
        case .withoutRead:
            return self.notificationsWithoutRead.isEmpty ? 0 : 46
        case .read:
            return self.notifications.isEmpty ? 10 : 24
        }
    }
}
