//
//  TagsViewController.swift
//  SOOUM
//
//  Created by JDeoks on 11/24/24.
//

import UIKit

class TagsViewController: BaseViewController {
    
    enum TagType: CaseIterable {
        case favorite
        case recommend
        
        var headerText: String {
            switch self {
            case .favorite:
                return "내가 즐겨찾기한 태그"
            case .recommend:
                return "추천태그"
            }
        }
    }
    
    let tagSearchTextFieldView = TagSearchTextFieldView(isInteractive: false)
    
    lazy var tableView = UITableView().then {
        $0.backgroundColor = .red
        $0.separatorStyle = .none
        $0.sectionHeaderTopPadding = 0
        $0.register(
            FavoriteTagTableViewCell.self,
            forCellReuseIdentifier: String(
                describing: FavoriteTagTableViewCell.self
            )
        )
        $0.register(
            RecommendTagTableViewCell.self,
            forCellReuseIdentifier: String(
                describing: RecommendTagTableViewCell.self
            )
        )
        $0.dataSource = self
        $0.delegate = self
    }
    
    override func bind() {
        tagSearchTextFieldView.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self) { object, _ in
                let searchVC = TagSearchViewController()
                searchVC.modalTransitionStyle = .crossDissolve
                searchVC.modalPresentationStyle = .overFullScreen
                object.present(searchVC, animated: true)
            }
            .disposed(by: self.disposeBag)
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
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TagType.allCases[section] {
        case .favorite: 4
        case .recommend: 12
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch TagType.allCases[indexPath.section] {
        case .favorite:
            return createFavoriteTagCell(indexPath: indexPath)
            
        case .recommend:
            return createRecommendTagTableViewCell(indexPath: indexPath)
        }
    }    
    
    private func createFavoriteTagCell(indexPath: IndexPath) -> FavoriteTagTableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: FavoriteTagTableViewCell.self),
            for: indexPath
        ) as! FavoriteTagTableViewCell
        
        return cell
    }
    
    private func createRecommendTagTableViewCell(indexPath: IndexPath) -> RecommendTagTableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: RecommendTagTableViewCell.self),
            for: indexPath
        ) as! RecommendTagTableViewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch TagType.allCases[indexPath.section] {
        case .favorite:
            return 228 + 12
            
        case .recommend:
            return 57 + 12
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return TagsHeaderView(type: TagType.allCases[section])
    }
}
