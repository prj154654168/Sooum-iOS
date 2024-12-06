//
//  AnnouncementViewControler.swift
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


class AnnouncementViewControler: BaseNavigationViewController, View {
    
    enum Text {
        static let navigationTitle: String = "공지사항"
    }
    
    private lazy var tableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.indicatorStyle = .black
        $0.separatorStyle = .none
        
        $0.register(AnnouncementViewCell.self, forCellReuseIdentifier: "cell")
        
        $0.refreshControl = SOMRefreshControl()
        
        $0.dataSource = self
        $0.delegate = self
    }
    
    private(set) var announcements = [Announcement]()
    
    
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
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: AnnouncementViewReactor) {
        
        // Action
        self.rx.viewDidLoad
            .map { _ in Reactor.Action.landing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map(\.announcements)
            .distinctUntilChanged()
            .subscribe(with: self) { object, announcements in
                object.announcements = announcements
                object.tableView.reloadData()
            }
            .disposed(by: self.disposeBag)
    }
}

extension AnnouncementViewControler: UITableViewDataSource {
    
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

extension AnnouncementViewControler: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let link = self.announcements[indexPath.row].link
        if let url = URL(string: link) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 73
    }
}
