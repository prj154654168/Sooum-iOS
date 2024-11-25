//
//  TagsViewController.swift
//  SOOUM
//
//  Created by JDeoks on 11/24/24.
//

import UIKit

class TagsViewController: BaseViewController {
    
    let tagSearchTextFieldView = TagSearchTextFieldView()
    
    lazy var tableView = UITableView().then {
        $0.backgroundColor = .red
        $0.separatorStyle = .none
        $0.sectionHeaderTopPadding = 0
        $0.register(
            FavoriteTagCell.self,
            forCellReuseIdentifier: String(
                describing: FavoriteTagCell.self
            )
        )
        $0.dataSource = self
        $0.delegate = self
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(tagSearchTextFieldView)
        tagSearchTextFieldView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.tagSearchTextFieldView.snp.bottom).offset(4)
            $0.bottom.equalToSuperview()
        }
    }
}

extension TagsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: FavoriteTagCell.self), 
            for: indexPath
        ) as! FavoriteTagCell
        
        return cell
    }    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 228
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return TagsHeaderView()
    }
}
