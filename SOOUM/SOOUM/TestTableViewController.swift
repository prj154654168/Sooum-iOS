//
//  TestTableViewController.swift
//  SOOUM
//
//  Created by JDeoks on 9/12/24.
//

import UIKit

import RxSwift

class TestTableViewController: UITableViewController {
    
    var cards = [
        Card(id: 1, pungTime: Date(timeIntervalSinceNow: 5)),
        Card(id: 2, pungTime: Date(timeIntervalSinceNow: 10)),
        Card(id: 3, pungTime: Date(timeIntervalSinceNow: 15)),
        Card(id: 4, pungTime: Date(timeIntervalSinceNow: 20)),
        Card(id: 5, pungTime: Date(timeIntervalSinceNow: 25)),
        Card(id: 6, pungTime: Date(timeIntervalSinceNow: 30)),
        Card(id: 7, pungTime: Date(timeIntervalSinceNow: 35)),
        Card(id: 8, pungTime: Date(timeIntervalSinceNow: 40))
    ]

    override func viewDidLoad() {
        print("\(type(of: self)) - \(#function)")
        
        super.viewDidLoad()
        tableView.register(
            SOMCardTableViewCell.self,
            forCellReuseIdentifier: String(
                describing: SOMCardTableViewCell.self
            )
        )
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cards.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(
                describing: SOMCardTableViewCell.self
            ),
            for: indexPath
        ) as! SOMCardTableViewCell
        
        let card = cards[indexPath.row]
        /// 펑타임 설정
        cell.setData(card: card)
//        cell.didpung
//            .subscribe { _ in
//                cell.showDidPung()
//                print("카드 \(card.id)가 펑됨")
//            }
//            .disposed(by: cell.disposeBag)
        
        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        (tableView.bounds.width - 40) * 0.9 + 10
    }
}
