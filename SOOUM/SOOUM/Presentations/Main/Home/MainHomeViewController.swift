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
    
    enum Text {
        static let title: String = "아직 등록된 카드가 없어요"
        static let subTitle: String = "사소하지만 말 못 한 이야기를\n카드로 만들어 볼까요?"
    }
    
    let logo = UIImageView().then {
        $0.image = .init(.logo)
        $0.tintColor = .som.p300
        $0.contentMode = .scaleAspectFit
    }
    
    let rightAlamButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .init(.icon(.outlined(.alarm)))
        config.image?.withTintColor(.som.gray700)
        config.imageColorTransformer = UIConfigurationColorTransformer { _ in .som.gray700 }
        $0.configuration = config
    }
    
    let headerView = MainHomeHeaderView()
    
    let moveTopButton = MoveTopButtonView().then {
        $0.isHidden = true
    }
    
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .clear
        $0.indicatorStyle = .black
        $0.separatorStyle = .none
        
        $0.register(MainHomeViewCell.self, forCellReuseIdentifier: "cell")
        
        $0.refreshControl = SOMRefreshControl()
        $0.dataSource = self
        $0.delegate = self
    }
    
    let placeholderView = UIView().then {
        $0.isHidden = true
    }
    
    /// tableView에 표시될 카드 정보
    var cards = [Card]()
    
    var tableViewTopConstraint: Constraint?
    
    
    // MARK: - Life Cycles
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.titleView = self.logo
        self.navigationBar.titlePosition = .left
        
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
        
        self.view.addSubview(self.placeholderView)
        self.placeholderView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        let placeholderTitleLabel = UILabel().then {
            $0.typography = .som.body1WithBold
            $0.text = Text.title
            $0.textColor = .som.black
            $0.textAlignment = .center
        }
        self.placeholderView.addSubview(placeholderTitleLabel)
        placeholderTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        let placeholderSubTitleLabel = UILabel().then {
            $0.typography = .som.body2WithBold
            $0.numberOfLines = 0
            $0.text = Text.subTitle
            $0.textColor = .som.gray500
            $0.textAlignment = .center
        }
        self.placeholderView.addSubview(placeholderSubTitleLabel)
        placeholderSubTitleLabel.snp.makeConstraints {
            $0.top.equalTo(placeholderTitleLabel.snp.bottom).offset(14)
            $0.bottom.equalToSuperview()
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
        self.moveTopButton.backgroundButton.rx.tap
            .subscribe(with: self) { object, _ in
                let indexPath = IndexPath(row: 0, section: 0)
                object.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }
            .disposed(by: self.disposeBag)
    }
    
    
    // MARK: Bind
    
    func bind(reactor: MainHomeViewReactor) {
        
        // Action
        self.rx.viewDidLoad
            .map { _ in
                print("\(type(of: self)) - \(#function)")
                return Reactor.Action.landing
            }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.tableView.refreshControl?.rx.controlEvent(.valueChanged)
            .withLatestFrom(reactor.state.map(\.isLoading))
            .filter { $0.isLoading == false }
            .map { _ in Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.headerView.homeTabBarDidTap
            .distinctUntilChanged()
            .map { index in Reactor.Action.homeTabBarItemDidTap(index: index) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.headerView.locationFilterDidTap
            .distinctUntilChanged()
            .map { Reactor.Action.distanceFilter($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        let isLoading = reactor.state.map(\.isLoading)
            .distinctUntilChanged({ $0.isLoading == $1.isLoading })
            .share()
        isLoading
            .filter { $0.isOffset == false }
            .subscribe(with: self.tableView) { tableView, isLoading in
                if isLoading.isLoading {
                    tableView.refreshControl?.beginRefreshing()
                } else {
                    tableView.refreshControl?.endRefreshing()
                }
            }
            .disposed(by: self.disposeBag)
        isLoading
            .filter { $0.isOffset }
            .subscribe(with: self.tableView) { tableView, isLoading in
                if isLoading.isLoading {
                    tableView.refreshControl?.beginRefreshingFromTop()
                } else {
                    tableView.refreshControl?.endRefreshing()
                }
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isProcessing)
            .distinctUntilChanged()
            .bind(to: self.activityIndicatorView.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.cards)
            .distinctUntilChanged()
            .subscribe(with: self) { object, cards in
                object.cards = cards
                self.placeholderView.isHidden = !cards.isEmpty
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
        
        let model = SOMCardModel(data: self.cards[indexPath.row])
        
        let cell: MainHomeViewCell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        ) as! MainHomeViewCell
        cell.selectionStyle = .none
        cell.setModel(model)
        /// card content stack order change
        cell.changeOrderInCardContentStack(self.reactor?.currentState.selectedIndex ?? 0)
        
        return cell
    }
}

 extension MainHomeViewController: UITableViewDelegate {
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let selectedId = self.cards[indexPath.row].id
         
         let detailViewController = DetailViewController()
         detailViewController.reactor = self.reactor?.reactorForDetail(selectedId)
         self.navigationPush(detailViewController, animated: true)
     }
     
     func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
     ) {
         let lastSectionIndex = tableView.numberOfSections - 1
         let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
         
         if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
             
             if let cell = cell as? MainHomeViewCell {
                 let lastId = cell.cardView.model?.data.id
                 let selectedIndex = self.reactor?.currentState.selectedIndex ?? 0
                 self.reactor?.action.onNext(.moreFind(lastId: lastId, selectedIndex: selectedIndex))
             }
         }
     }
     
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         let width: CGFloat = (UIScreen.main.bounds.width - 20 * 2) * 0.9
         let height: CGFloat = width + 10 /// 가로 + top inset
         return height
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
