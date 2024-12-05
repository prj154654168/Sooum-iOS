//
//  TagDetailViewController.swift
//  SOOUM
//
//  Created by JDeoks on 12/4/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift

import SnapKit
import Then

class TagDetailViewController: BaseViewController, View {
    
    let navBarView = TagDetailNavigationBarView()
    
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .clear
        $0.indicatorStyle = .black
        $0.separatorStyle = .none
        
        $0.register(
            MainHomeViewCell.self,
            forCellReuseIdentifier: String(describing: MainHomeViewCell.self)
        )
        $0.dataSource = self
        $0.delegate = self
    }
    
    override func setupConstraints() {
        self.view.addSubview(navBarView)
        navBarView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(self.navBarView.snp.bottom)
        }
    }
    
    override func bind() {
        navBarView.backButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self) { object, _ in
                object.dismiss(animated: true)
            }
            .disposed(by: self.disposeBag)
    }
    
    func bind(reactor: TagDetailViewrReactor) {
        self.rx.viewDidLoad
            .subscribe(with: self) { object, _ in
                reactor.action.onNext(.fetchTagCards)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.tagCards)
            .subscribe(with: self) { object, cards in
                object.tableView.reloadData()
            }
            .disposed(by: self.disposeBag)
    }
}

extension TagDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let reactor = self.reactor else {
            return 0
        }
        return reactor.currentState.tagCards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MainHomeViewCell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: MainHomeViewCell.self),
            for: indexPath
        ) as! MainHomeViewCell
        
        guard let reactor = self.reactor else {
            return cell
        }
        if reactor.currentState.tagCards.indices.contains(indexPath.row) {
            cell.setData(tagCard: reactor.currentState.tagCards[indexPath.row])
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let width: CGFloat = (UIScreen.main.bounds.width - 20 * 2) * 0.9
        let height: CGFloat = width + 10 /// 가로 + top inset
        return height
    }
}