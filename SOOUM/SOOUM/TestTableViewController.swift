//
//  TestTableViewController.swift
//  SOOUM
//
//  Created by JDeoks on 9/12/24.
//

import RxSwift
import UIKit

struct Card {
    let id: Int
    let pungTime: Date
}

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
        print(cell.id, "\(String(describing: cell.card?.id)) 구독 됨")
        cell.didpung
            .subscribe { _ in
                if let cardIndex = self.cards.firstIndex(where: { $0.id == card.id }) {
                    self.cards.remove(at: cardIndex)
                    // TODO: - 행 삭제 오류 너무 남... 일단 임시로 리로드
//                    tableView.deleteRows(
//                        at: [IndexPath(row: cardIndex, section: 0)],
//                        with: .fade
//                    )
                    tableView.reloadData()
                }
                print("카드 \(card.id)가 펑됨")
            }
            .disposed(by: cell.disposeBag)
        
        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        (tableView.bounds.width - 40) * 0.9 + 10
    }
    
    override func tableView(
        _ tableView: UITableView,
        didEndDisplaying cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if let cell = cell as? SOMCardTableViewCell {
            print(cell.id, "\(String(describing: cell.card?.id)) 구독 해제")
            cell.disposeBag = DisposeBag()
        }
    }
}
