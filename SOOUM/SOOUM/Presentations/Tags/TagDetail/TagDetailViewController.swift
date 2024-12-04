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

class TagDetailViewController: BaseViewController {
    
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
}

extension TagDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let model = SOMCardModel(data: self.cards[indexPath.row])
        
        let cell: MainHomeViewCell = tableView.dequeueReusableCell(
            withIdentifier: String(describing:  MainHomeViewCell.self),
            for: indexPath
        ) as! MainHomeViewCell
//        cell.selectionStyle = .none
//        cell.setModel(model)
        // 카드 하단 contents 스택 순서 변경
//        cell.changeOrderInCardContentStack(self.reactor?.currentState.selectedIndex ?? 0)
        
        return cell
    }
    
}
