//
//  TagsViewController.swift
//  SOOUM
//
//  Created by JDeoks on 11/24/24.
//

import UIKit

import ReactorKit

class TagsViewController: BaseNavigationViewController, View {
    
    enum TagType: Int, CaseIterable {
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
        $0.refreshControl = SOMRefreshControl()
    }
    
    private let loadMoreTrigger = PublishSubject<Void>()
    private var currentOffset: CGFloat = 0
    private var isRefreshEnabled: Bool = false
    private var isLoadingMore: Bool = false
    
    func bind(reactor: TagsViewReactor) {
        
        tagSearchTextFieldView.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self) { object, _ in
                let searchVC = TagSearchViewController()
                searchVC.reactor = reactor.reactorForSearch()
                self.navigationPush(searchVC, animated: false)
            }
            .disposed(by: self.disposeBag)
        
        self.rx.viewDidLoad
            .subscribe(with: self) { object, _ in
              reactor.action.onNext(.initialize)
            }
            .disposed(by: self.disposeBag)
        
        let isLoading = reactor.state.map(\.isLoading).distinctUntilChanged().share()
        self.tableView.refreshControl?.rx.controlEvent(.valueChanged)
            .withLatestFrom(isLoading)
            .filter { $0 == false }
            .map { _ in Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
      
      loadMoreTrigger
          .throttle(.milliseconds(500), scheduler: MainScheduler.instance) // 0.5초 동안 한 번만 실행
          .subscribe(with: self) { object, _ in
              guard let reactor = object.reactor, !reactor.currentState.isLoading else { return }
              reactor.action.onNext(.moreFind)
          }
          .disposed(by: disposeBag)

        reactor.state.map(\.favoriteTags)
            .subscribe(with: self) { object, _ in
                object.tableView.reloadData()
            }
            .disposed(by: self.disposeBag)
        
        isLoading
            .do(onNext: { [weak self] isLoading in
                if isLoading { self?.isLoadingMore = false }
            })
            .subscribe(with: self.tableView) { tableView, isLoading in
                if isLoading {
                    tableView.refreshControl?.beginRefreshingFromTop()
                } else {
                    tableView.refreshControl?.endRefreshing()
                }
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isProcessing)
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(with: self) { object, _ in
                object.isLoadingMore = false
            }
            .disposed(by: self.disposeBag)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
      
        isNavigationBarHidden = true
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
        
        guard let reactor = self.reactor, reactor.currentState.favoriteTags.indices.contains(indexPath.row) else {
            return cell
        }
        let favoriteTag = reactor.currentState.favoriteTags[indexPath.row]
        
        cell.setData(favoriteTag: favoriteTag)
        
        cell.favoriteTagView.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self) { object, gesture in
                if cell.favoriteTagView.isTappedDirectly(gesture: gesture) {
                    object.pushTagdetailVC(reactor: reactor, tagID: favoriteTag.id)
                }
            }
            .disposed(by: cell.disposeBag)
        
        cell.favoriteTagView.moreButtonStackView.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self) { object, gesture in
                object.pushTagdetailVC(reactor: reactor, tagID: favoriteTag.id)
            }
            .disposed(by: cell.disposeBag)

        cell.previewCardTapped
            .subscribe(with: self) { object, previewCardID in
                let detailViewController = DetailViewController()
                detailViewController.reactor = reactor.reactorForDetail(previewCardID)
                object.navigationPush(detailViewController, animated: true)
            }
            .disposed(by: cell.disposeBag)
        
        return cell
    }
    
    private func pushTagdetailVC(reactor: TagsViewReactor, tagID: String) {
        let tagDetailVC = TagDetailViewController()
        tagDetailVC.reactor = reactor.reactorForTagDetail(tagID)
        self.navigationPush(tagDetailVC, animated: true)
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
            
            cell.contentView.rx.tapGesture()
                .when(.recognized)
                .subscribe(with: self) { object, _ in
                    let tagID = reactor.currentState.recommendTags[indexPath.row].tagID
                    let tagDetailVC = TagDetailViewController()
                    tagDetailVC.reactor = reactor.reactorForTagDetail(tagID)
                    object.navigationPush(tagDetailVC, animated: true)
                }
                .disposed(by: cell.disposeBag)
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
        guard let reactor = self.reactor else {
            return nil
        }
        if reactor.isFavoriteTagsEmpty {
            return TagsHeaderView(type: TagType.recommend)
        }
        return TagsHeaderView(type: TagType.allCases[section])
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let reactor = self.reactor else {
            return 0
        }
        let height = 58 + 6 + self.additionalSafeAreaInsets.bottom
        if reactor.currentState.favoriteTags.isEmpty {
            return height
        }
        switch TagType.allCases[section] {
        case .favorite:
            return 0
        case .recommend:
            return height
        }
    }
    

    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        
        // currentOffset <= 0 && isLoading == false 일 때, 테이블 뷰 새로고침 가능
        self.isRefreshEnabled = (offset <= 0 && self.reactor?.currentState.isLoading == false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 1200 {
            loadMoreTrigger.onNext(())
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let offset = scrollView.contentOffset.y
        
        // isRefreshEnabled == true 이고, 스크롤이 끝났을 경우에만 테이블 뷰 새로고침
        if self.isRefreshEnabled,
           let refreshControl = self.tableView.refreshControl,
           offset <= -(refreshControl.frame.origin.y + 40) {
            
            refreshControl.beginRefreshingFromTop()
        }
    }
}
