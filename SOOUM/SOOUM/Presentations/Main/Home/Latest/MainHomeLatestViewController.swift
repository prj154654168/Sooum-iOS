//
//  MainHomeLatestViewController.swift
//  SOOUM
//
//  Created by 오현식 on 12/23/24.
//

import UIKit

import Kingfisher
import SnapKit
import Then

import ReactorKit
import RxCocoa
import RxSwift


class MainHomeLatestViewController: BaseViewController, View {
    
    
    // MARK: Views
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .clear
        $0.indicatorStyle = .black
        $0.separatorStyle = .none
        
        $0.contentInset.top = SOMSwipeTabBar.Height.mainHome
        
        $0.isHidden = true
        
        $0.register(MainHomeViewCell.self, forCellReuseIdentifier: "cell")
        $0.register(PlaceholderViewCell.self, forCellReuseIdentifier: "placeholder")
        
        $0.refreshControl = SOMRefreshControl()
        
        $0.dataSource = self
        $0.prefetchDataSource = self
        
        $0.delegate = self
    }
    
    private let moveTopButton = MoveTopButtonView().then {
        $0.isHidden = true
    }
    
    
    // MARK: Variables
    
    // tableView 정보
    private var currentOffset: CGFloat = 0
    private var isRefreshEnabled: Bool = true
    private var isLoadingMore: Bool = false
    
    private let cellHeight: CGFloat = {
        let width: CGFloat = (UIScreen.main.bounds.width - 20 * 2) * 0.9
        return width + 10  /// 가로 + top inset
    }()
    
    
    // MARK: Variables + Rx
    
    let hidesHeaderContainer = PublishRelay<Bool>()
    let willPushCardId = PublishRelay<String>()
    
    
    // MARK: Override func
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.view.addSubview(self.moveTopButton)
        self.view.bringSubviewToFront(self.moveTopButton)
        self.moveTopButton.snp.makeConstraints {
            let bottomOffset: CGFloat = 24 + 60 + 4 + 20
            $0.bottom.equalTo(self.tableView.snp.bottom).offset(-bottomOffset)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(MoveTopButtonView.height)
        }
    }
    
    override func bind() {
        super.bind()
        
        // tableView 상단 이동
        self.moveTopButton.backgroundButton.rx.throttleTap(.seconds(3))
            .subscribe(with: self) { object, _ in
                let indexPath = IndexPath(row: 0, section: 0)
                object.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
            .disposed(by: self.disposeBag)
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: MainHomeLatestViewReactor) {
        
        // Action
        self.rx.viewWillAppear
            .map { _ in Reactor.Action.landing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        let isLoading = reactor.state.map(\.isLoading).distinctUntilChanged().share()
        // isLoading == true && isRefreshing == false 일 때, 이벤트 무시
        self.tableView.refreshControl?.rx.controlEvent(.valueChanged)
            .withLatestFrom(isLoading)
            .filter { $0 == false }
            .map { _ in Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
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
            .do(onNext: { [weak self] isProcessing in
                if isProcessing { self?.isLoadingMore = false }
            })
            .bind(to: self.activityIndicatorView.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.displayedCardsWithUpdate)
            .filterNil()
            .distinctUntilChanged(reactor.canUpdateCells)
            .subscribe(with: self) { object, displayedCardsWithUpdate in
                let displayedCards = displayedCardsWithUpdate.cards
                let hasMoreUpdate = displayedCardsWithUpdate.hasMoreUpdate
                
                object.tableView.isHidden = false
                
                // hasMoreUpdate == true일 때, 추가된 데이터만 로드
                if hasMoreUpdate {
                    
                    let lastSectionIndex = object.tableView.numberOfSections - 1
                    let lastRowIndex = object.tableView.numberOfRows(inSection: lastSectionIndex) - 1
                    let loadedDisplayedCards = displayedCards[0...lastRowIndex]
                    let indexPathForInsert = displayedCards.enumerated()
                        .filter { loadedDisplayedCards.contains($0.element) == false }
                        .map { IndexPath(row: $0.offset, section: 0) }
                    
                    object.tableView.performBatchUpdates {
                        object.tableView.insertRows(at: indexPathForInsert, with: .fade)
                    }
                } else {
                    
                    object.tableView.reloadData()
                }
            }
            .disposed(by: self.disposeBag)
    }
}


// MARK: Set UITableView cell

extension MainHomeLatestViewController {
    
    private func cellForPlaceholder(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        
        let placeholder = tableView.dequeueReusableCell(
            withIdentifier: "placeholder",
            for: indexPath
        ) as! PlaceholderViewCell
        
        return placeholder
    }
    
    private func cellForMainHome(
        _ tableView: UITableView,
        for indexPath: IndexPath,
        with reactor: MainHomeLatestViewReactor
    ) -> UITableViewCell {
        
        let displayedCards = reactor.currentState.displayedCards
        let model = SOMCardModel(data: displayedCards[indexPath.row])
        let cell: MainHomeViewCell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        ) as! MainHomeViewCell
        cell.setModel(model)
        // 카드 하단 contents 스택 순서 변경 (최신순)
        cell.changeOrderInCardContentStack(0)
        
        return cell
    }
}


// MARK: MainHomeViewController DataSource and Delegate

extension MainHomeLatestViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reactor?.currentState.displayedCardsCount ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let reactor = self.reactor else { return .init(frame: .zero) }
        
        if reactor.currentState.isDisplayedCardsEmpty {
            
            return self.cellForPlaceholder(tableView, for: indexPath)
        } else {
            
            return self.cellForMainHome(tableView, for: indexPath, with: reactor)
        }
    }
}

extension MainHomeLatestViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let reactor = self.reactor else { return }
        
        indexPaths.forEach { indexPath in
            // 데이터 로드 전, 이미지 캐싱
            let strUrl = reactor.currentState.displayedCards[indexPath.row].backgroundImgURL.url
            KingfisherManager.shared.download(strUrl: strUrl) { _ in }
        }
    }
}

extension MainHomeLatestViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let reactor = self.reactor else { return }
        
        let selectedId = reactor.currentState.displayedCards[indexPath.row].id
        self.willPushCardId.accept(selectedId)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (self.reactor?.currentState.isDisplayedCardsEmpty ?? true) ? tableView.bounds.height : self.cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard self.reactor?.currentState.isDisplayedCardsEmpty == false else { return }
        
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        
        if self.isLoadingMore,
           indexPath.section == lastSectionIndex,
           indexPath.row == lastRowIndex,
           let reactor = self.reactor {
            
            let lastId = reactor.currentState.displayedCards[indexPath.row].id
            reactor.action.onNext(.moreFind(lastId))
        }
    }
    
    
    // MARK: UIScrollView Delegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        // currentOffset <= 0 && isLoading == false 일 때, 테이블 뷰 새로고침 가능
        self.isRefreshEnabled = (self.currentOffset <= 0 && self.reactor?.currentState.isLoading == false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        
        // 당겨서 새로고침 상황일 때
        guard offset > 0 else {
            
            self.hidesHeaderContainer.accept(false)
            self.currentOffset = offset
            self.moveTopButton.isHidden = true
            
            return
        }
        
        // 정상적인 스크롤 상황일 때, 헤더뷰 숨김
        guard offset <= (scrollView.contentSize.height - scrollView.frame.height) else { return }
        
        // offset이 currentOffset보다 크면 아래로 스크롤, 반대일 경우 위로 스크롤
        // 위로 스크롤 중일 때 헤더뷰 표시, 아래로 스크롤 중일 때 헤더뷰 숨김
        self.hidesHeaderContainer.accept(offset > self.currentOffset)
        
        // 아래로 스크롤 중일 때, 데이터 추가로드 가능
        self.isLoadingMore = offset > self.currentOffset
        
        self.currentOffset = offset
        
        // 최상단일 때만 moveToButton 숨김
        self.moveTopButton.isHidden = self.currentOffset <= 0
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
