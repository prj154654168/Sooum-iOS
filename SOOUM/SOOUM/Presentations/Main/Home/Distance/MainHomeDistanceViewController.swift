//
//  MainHomeDistanceViewController.swift
//  SOOUM
//
//  Created by 오현식 on 12/23/24.
//

import UIKit

import SnapKit
import Then

import ReactorKit
import RxCocoa
import RxSwift


class MainHomeDistanceViewController: BaseViewController, View {
    
    
    // MARK: Views
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .clear
        $0.indicatorStyle = .black
        $0.separatorStyle = .none
        
        $0.contentInset.bottom = 100
        $0.verticalScrollIndicatorInsets.bottom = 80
        
        $0.register(MainHomeViewCell.self, forCellReuseIdentifier: "cell")
        
        $0.refreshControl = SOMRefreshControl()
        
        $0.dataSource = self
        $0.prefetchDataSource = self
        
        $0.delegate = self
    }
    
    private let moveTopButton = MoveTopButtonView().then {
        $0.isHidden = true
    }
    
    private let placeholderView = PlaceholderView()
    
    
    // MARK: Variables
    
    // tableView에 표시될 카드 정보
    private var displayedCards = [Card]()
    
    // tableView 정보
    private var currentOffset: CGFloat = 0
    private var isRefreshEnabled: Bool = true
    
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
        
        self.view.addSubview(self.placeholderView)
        self.placeholderView.snp.makeConstraints {
            let offset = UIScreen.main.bounds.height * 0.4 - (SOMSwipeTabBar.Height.mainHome + SOMLocationFilter.height)
            $0.top.equalToSuperview().offset(offset)
            $0.centerX.equalToSuperview()
        }
        
        self.view.addSubview(self.moveTopButton)
        self.view.bringSubviewToFront(self.moveTopButton)
        self.moveTopButton.snp.makeConstraints {
            let bottomOffset: CGFloat = 24 + 60 + 4
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-bottomOffset)
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
    
    func bind(reactor: MainHomeDistanceViewReactor) {
        
        // Action
        // 테이블 뷰가 스크롤이 되어 있을 시에 새로고침 X
        self.rx.viewWillAppear
            .withUnretained(self)
            .filter { object, _ in object.tableView.contentOffset.y <= 0 }
            .map { _ in Reactor.Action.landing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.tableView.refreshControl?.rx.controlEvent(.valueChanged)
            .withLatestFrom(reactor.state.map(\.isLoading))
            .filter { $0 == false }
            .map { _ in Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map(\.isLoading)
            .distinctUntilChanged()
            .subscribe(with: self.tableView) { tableView, isLoading in
                if isLoading {
                    tableView.refreshControl?.beginRefreshingFromTop()
                } else {
                    tableView.refreshControl?.endRefreshing()
                }
            }
            .disposed(by: self.disposeBag)
        
      let displayedCardsWithUpdate = reactor.state
          .map(\.displayedCardsWithUpdate)
          .distinctUntilChanged({ reactor.canUpdateCells(prev: $0, curr: $1) })
          .share()
      
        let isProcessing = reactor.state.map(\.isProcessing).distinctUntilChanged().share()
        isProcessing
            .filter { $0 }
            .withLatestFrom(displayedCardsWithUpdate.map { $0.isUpdate })
            .subscribe(with: self) { object, isUpdate in
                object.tableView.isHidden = isUpdate == false
                object.placeholderView.isHidden = true
            }
            .disposed(by: self.disposeBag)
        
        isProcessing
            .filter { $0 == false }
            .withLatestFrom(displayedCardsWithUpdate.map { $0.cards })
            .subscribe(with: self) { object, cards in
                object.tableView.isHidden = cards.isEmpty
                object.placeholderView.isHidden = cards.isEmpty == false
            }
            .disposed(by: self.disposeBag)
      
        isProcessing
            .distinctUntilChanged()
            .bind(to: self.activityIndicatorView.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        displayedCardsWithUpdate
            .subscribe(with: self) { object, displayedCardsWithUpdate in
                let displayedCards = displayedCardsWithUpdate.cards
                let isUpdate = displayedCardsWithUpdate.isUpdate
                
                // isUpdate == true 일 때, 추가된 카드만 로드
                if isUpdate {
                    let indexPathForInsert: [IndexPath] = displayedCards.enumerated()
                        .filter { object.displayedCards.contains($0.element) == false }
                        .map { IndexPath(row: $0.offset, section: 0) }
                    
                    object.displayedCards = displayedCards
                    
                    object.tableView.performBatchUpdates {
                        object.tableView.insertRows(at: indexPathForInsert, with: .automatic)
                    }
                } else {
                    object.displayedCards = displayedCards
                    object.tableView.reloadData()
                }
            }
            .disposed(by: self.disposeBag)
    }
}


// MARK: MainHomeViewController DataSource and Delegate

extension MainHomeDistanceViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayedCards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = SOMCardModel(data: self.displayedCards[indexPath.row])
        
        let cell: MainHomeViewCell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        ) as! MainHomeViewCell
        cell.selectionStyle = .none
        cell.setModel(model)
        // 카드 하단 contents 스택 순서 변경 (거리순)
        cell.changeOrderInCardContentStack(2)
        
        return cell
    }
}

extension MainHomeDistanceViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        if let rowIndex = indexPaths.map({ $0.row }).max(),
            rowIndex >= Int(Double(self.displayedCards.count) * 0.8),
            let reactor = self.reactor {
            
            if let loadedCards = reactor.simpleCache.loadMainHomeCards(type: .latest),
               self.displayedCards.count < loadedCards.count {
                reactor.action.onNext(.moreFind(lastId: nil))
            }
        }
    }
}

extension MainHomeDistanceViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedId = self.displayedCards[indexPath.row].id
        
        self.willPushCardId.accept(selectedId)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        
        if self.currentOffset > 0,
           indexPath.section == lastSectionIndex,
           indexPath.row == lastRowIndex,
           let reactor = self.reactor {
            
            // 캐시된 데이터가 존재하고, 현재 표시된 수보다 캐시된 수가 같거나 적으면
            if let loadedCards = reactor.simpleCache.loadMainHomeCards(type: .distance),
               self.displayedCards.count >= loadedCards.count {
                let lastId = self.displayedCards[indexPath.row].id
                reactor.action.onNext(.moreFind(lastId: lastId))
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        // currentOffset <= 0 일 때, 테이블 뷰 새로고침 가능
        self.isRefreshEnabled = self.currentOffset <= 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        
        // offset이 currentOffset보다 크면 아래로 스크롤, 반대일 경우 위로 스크롤
        // 위로 스크롤 중일 때 헤더뷰 표시, 아래로 스크롤 중일 때 헤더뷰 숨김
        // 메인 큐에서 실행 명시
        DispatchQueue.main.async {
            self.hidesHeaderContainer.accept(offset <= 0 ? false : offset > self.currentOffset)
        }
        
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
