//
//  TagSearchViewController.swift
//  SOOUM
//
//  Created by JDeoks on 11/26/24.
//

import UIKit

class TagSearchViewController: BaseViewController {
    
    let tagSearchTextFieldView = TagSearchTextFieldView(isInteractive: true)

    lazy var tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.sectionHeaderTopPadding = 0
        $0.contentInset.top = 28
        $0.register(
            RecommendTagTableViewCell.self,
            forCellReuseIdentifier: String(
                describing: RecommendTagTableViewCell.self
            )
        )
        $0.dataSource = self
        $0.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tagSearchTextFieldView.textField.becomeFirstResponder()
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

extension TagSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        createRecommendTagTableViewCell(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57 + 12
    }
    
    private func createRecommendTagTableViewCell(indexPath: IndexPath) -> RecommendTagTableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: RecommendTagTableViewCell.self),
            for: indexPath
        ) as! RecommendTagTableViewCell
        
        return cell
    }
}
