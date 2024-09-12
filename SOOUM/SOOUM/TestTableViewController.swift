//
//  TestTableViewController.swift
//  SOOUM
//
//  Created by JDeoks on 9/12/24.
//

import UIKit

class TestTableViewController: UITableViewController {
    
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10
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
        )
        
        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        (tableView.bounds.width - 40) * 0.9 + 10
    }
}
