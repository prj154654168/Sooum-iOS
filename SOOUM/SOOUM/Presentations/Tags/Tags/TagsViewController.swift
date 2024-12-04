//
//  TagsViewController.swift
//  SOOUM
//
//  Created by JDeoks on 11/24/24.
//

import UIKit

import ReactorKit

class TagsViewController: BaseViewController, View {
    
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
                object.present(searchVC, animated: false)
            }
            .disposed(by: self.disposeBag)
    }
    
    func bind(reactor: TagsViewReactor) {
        self.rx.viewDidLoad
            .subscribe(with: self) { object, _ in
                reactor.action.onNext(.fetchTags)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.favoriteTags)
            .subscribe(with: self) { object, _ in
                object.tableView.reloadData()
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.favoriteTags)
            .subscribe(with: self) { object, _ in
                object.tableView.reloadData()
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
        guard let reactor = self.reactor else {
            return 0
        }
        return reactor.isFavoriteTagsEmpty ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let reactor = self.reactor else {
            return 0
        }
        if reactor.isFavoriteTagsEmpty {
            return reactor.currentState.recommendTags.count
        } 
        
        switch TagType.allCases[section] {
        case .favorite:
            return reactor.currentState.favoriteTags.count
            
        case .recommend:
            return reactor.currentState.recommendTags.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let reactor = self.reactor else {
            return UITableViewCell()
        }
        if reactor.isFavoriteTagsEmpty {
            return createRecommendTagTableViewCell(indexPath: indexPath)
        }
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
        
        guard let reactor = self.reactor else {
            return cell
        }
        if reactor.currentState.favoriteTags.indices.contains(indexPath.row) {
            cell.setData(favoriteTag: reactor.currentState.favoriteTags[indexPath.row])
        }
        return cell
    }
    
    private func createRecommendTagTableViewCell(indexPath: IndexPath) -> RecommendTagTableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: RecommendTagTableViewCell.self),
            for: indexPath
        ) as! RecommendTagTableViewCell
        guard let reactor = self.reactor else {
            return cell
        }
        if reactor.currentState.recommendTags.indices.contains(indexPath.row) {
            cell.setData(recommendTag: reactor.currentState.recommendTags[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let favoriteTagHeight = CGFloat(228 + 12)
        let recommendTagHeight = CGFloat(57 + 12)
        guard let reactor = self.reactor else {
            return 0
        }
        if reactor.isFavoriteTagsEmpty {
            return recommendTagHeight
        }
        switch TagType.allCases[indexPath.section] {
        case .favorite:
            return favoriteTagHeight
            
        case .recommend:
            return recommendTagHeight
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return TagsHeaderView(type: TagType.allCases[section])
    }
}
