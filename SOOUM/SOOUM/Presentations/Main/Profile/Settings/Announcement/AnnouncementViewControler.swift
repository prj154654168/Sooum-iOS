//
//  AnnouncementViewController.swift
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


class AnnouncementViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let navigationTitle: String = "공지사항"
    }
    
    private lazy var tableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.indicatorStyle = .black
        $0.separatorStyle = .none
        
        $0.rowHeight = UITableView.automaticDimension
        
        $0.register(AnnouncementViewCell.self, forCellReuseIdentifier: "cell")
        
        $0.refreshControl = SOMRefreshControl()
        
        $0.dataSource = self
        $0.delegate = self
    }
    
    private(set) var announcements = [NoticeInfo]()
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    
    // MARK: Variables
    
    private var initialOffset: CGFloat = 0
    private var currentOffset: CGFloat = 0
    private var isRefreshEnabled: Bool = true
    private var shouldRefreshing: Bool = false
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: AnnouncementViewReactor) {
        
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
        
        reactor.state.map(\.announcements)
            .distinctUntilChanged()
            .subscribe(with: self) { object, announcements in
                object.announcements = announcements
                
                object.tableView.reloadData()
            }
            .disposed(by: self.disposeBag)
    }
}

extension AnnouncementViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.announcements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let announcement = self.announcements[indexPath.row]
        
        let cell: AnnouncementViewCell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        ) as! AnnouncementViewCell
        
        cell.selectionStyle = .none
        cell.setModel(announcement)
        
        return cell
    }
}

extension AnnouncementViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if let strUrl = self.announcements[indexPath.row].url, let url = URL(string: strUrl) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
