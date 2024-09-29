//
//  MainHomeViewController.swift
//  SOOUM
//
//  Created by 오현식 on 9/25/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

import SnapKit
import Then


class MainHomeViewController: BaseNavigationViewController, View {
    
    let logo = UIImageView().then {
        $0.image = .init(.logo)
        $0.tintColor = .som.primary
    }
    let rightAlamButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .init(.icon(.outlined(.alarm)))
        config.image?.withTintColor(.som.gray02)
        config.imageColorTransformer = UIConfigurationColorTransformer { _ in .som.gray02 }
        $0.configuration = config
    }
    
    let headerView = MainHomeHeaderView()
    
    let moveTopButton = MoveTopButtonView().then {
        $0.isHidden = true
    }
    
    let refreshControl = UIRefreshControl().then {
        $0.tintColor = .som.black
    }
    
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .clear
        $0.indicatorStyle = .black
        $0.separatorStyle = .none
        
        let width = UIScreen.main.bounds.width
        $0.rowHeight = (width - 20 * 2) * 0.9 + 10
        $0.sectionHeaderHeight = 0
        $0.sectionFooterHeight = 0
        
        $0.contentInset.top = 10
        
        $0.register(SOMCardTableViewCell.self, forCellReuseIdentifier: "cell")
        
        $0.refreshControl = self.refreshControl
        $0.dataSource = self
        $0.delegate = self
    }
    
    /// tableView에 표시될 카드 정보
    var cards = [Card]()
    
    var tableViewTopConstraint: Constraint?
    
    let coordinate = PublishSubject<(latitude: String, longitude: String)>()
    
    
    // MARK: - Life Cycles
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.titleView = self.logo
        
        self.navigationBar.isHideBackButton = true
        self.navigationBar.setRightButtons([self.rightAlamButton])
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.headerView)
        self.headerView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
        }
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            self.tableViewTopConstraint = $0.top.equalTo(self.headerView.snp.bottom).constraint
            $0.bottom.leading.trailing.equalToSuperview()
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
    
    
    // MARK: Bind
    
    func bind(reactor: MainHomeViewReactor) {
        
        /// tableView 상단 이동
        self.moveTopButton.backgroundButton.rx.tap
            .subscribe(with: self) { object, _ in
                let indexPath = IndexPath(row: 0, section: 0)
                object.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }
            .disposed(by: self.disposeBag)
        
        /// Action
        self.rx.viewDidLoad
            .map { _ in Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.tableView.refreshControl?.rx.controlEvent(.valueChanged)
            .map { _ in Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.coordinate
            .map { coordinate in
                Reactor.Action.coordinate(coordinate.latitude, coordinate.longitude)
            }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.headerView.homeTabBarDidTap
            .distinctUntilChanged()
            .map { index in Reactor.Action.homeTabBarItemDidTap(index: index) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        
        /// State
        reactor.state.map(\.isLoading)
            .distinctUntilChanged()
            .subscribe(with: self.tableView) { tableView, isLoading in
                if isLoading {
                    tableView.refreshControl?.manualyBeginRefreshing()
                } else {
                    tableView.refreshControl?.endRefreshing()
                }
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isProcessing)
            .distinctUntilChanged()
            .bind(to: self.activityIndicatorView.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.displayedCards)
            .distinctUntilChanged()
            .subscribe(with: self) { object, cards in
                object.cards = cards
                object.tableView.reloadData()
            }
            .disposed(by: self.disposeBag)
    }
}


// MARK: MainHomeViewController DataSource and Delegate

extension MainHomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: SOMCardTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        ) as! SOMCardTableViewCell
        cell.selectionStyle = .none
        cell.setData(card: self.cards[indexPath.row])
        /// card content stack order change
        cell.changeOrderInCardContentStack(self.reactor?.currentState.index ?? 0)
        
        return cell
    }
}

 extension MainHomeViewController: UITableViewDelegate {
     
     func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
     ) {
         let lastSectionIndex = tableView.numberOfSections - 1
         let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
         
         if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
             
             let currentState = self.reactor?.currentState
             if currentState?.cards.count == currentState?.displayedCards.count {
                 if let cell = cell as? SOMCardTableViewCell {
                     self.reactor?.action.onNext(.moreFindWithId(lastId: cell.card.id))
                 }
             } else {
                 self.reactor?.action.onNext(.moreFind)
             }
         }
     }
    
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
         let offsetY = scrollView.contentOffset.y
         let isTop = offsetY <= 0
         self.moveTopButton.isHidden = isTop ? true : false
         self.headerView.isHidden = !isTop
         self.tableViewTopConstraint?.deactivate()
         self.tableView.snp.makeConstraints {
             self.tableViewTopConstraint = $0.top.equalTo(
                isTop ? self.headerView.snp.bottom : self.view.safeAreaLayoutGuide.snp.top
             ).constraint
         }
         UIView.animate(withDuration: 0.1) {
             self.view.layoutIfNeeded()
         }
     }
 }
