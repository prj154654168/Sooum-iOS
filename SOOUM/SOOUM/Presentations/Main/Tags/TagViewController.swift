//
//  TagViewController.swift
//  SOOUM
//
//  Created by 오현식 on 11/18/25.
//

import UIKit

import SnapKit
import Then

import SwiftEntryKit

import ReactorKit
import RxCocoa
import RxSwift

class TagViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let navigationTitle: String = "태그"
        
        static let placeholderText: String = "태그를 검색하세요"
        
        static let favoriteTagHeaderTitle: String = "님의 관심 태그"
        static let popularTagHeaderTitle: String = "인기 태그"
        
        static let bottomToastEntryName: String = "bottomToastEntryName"
        static let addToastMessage: String = "을 관심 태그에 추가했어요"
        static let deleteToastMessage: String = "을 관심 태그에서 삭제했어요"
        
        static let bottomToastEntryNameWithAction: String = "bottomToastEntryNameWithAction"
        static let failedToastMessage: String = "네트워크 확인 후 재시도해주세요."
        static let failToastActionTitle: String = "재시도"
    }
    
    
    // MARK: Views
    
    private let searchViewButtonView = SearchViewButton().then {
        $0.placeholder = Text.placeholderText
    }
    
    private lazy var scrollView = UIScrollView().then {
        $0.isScrollEnabled = true
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        
        $0.contentInsetAdjustmentBehavior = .never
        
        $0.refreshControl = SOMRefreshControl()
        
        $0.delegate = self
    }
    
    private let container = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fillProportionally
    }
    
    private let favoriteTagHeaderView = FavoriteTagHeaderView()
    private let favoriteTagsView = FavoriteTagsView()
    
    private let popularTagHeaderView = PopularTagHeaderView(title: Text.popularTagHeaderTitle).then {
        $0.isHidden = true
    }
    private let popularTagsView = PopularTagsView().then {
        $0.isHidden = true
    }
    
    
    // MARK: Variables
    
    private var initialOffset: CGFloat = 0
    private var currentOffset: CGFloat = 0
    private var isRefreshEnabled: Bool = true
    private var shouldRefreshing: Bool = false
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
        self.navigationBar.titlePosition = .left
        
        self.navigationBar.hidesBackButton = true
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
        
        self.scrollView.addSubview(self.searchViewButtonView)
        self.searchViewButtonView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        self.scrollView.addSubview(self.container)
        self.container.snp.makeConstraints {
            $0.top.equalTo(self.searchViewButtonView.snp.bottom)
            $0.bottom.horizontalEdges.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width)
        }
        
        self.container.addArrangedSubview(self.favoriteTagHeaderView)
        self.container.addArrangedSubview(self.favoriteTagsView)
        
        self.container.addArrangedSubview(self.popularTagHeaderView)
        self.container.addArrangedSubview(self.popularTagsView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 제스처 뒤로가기를 위한 델리게이트 설정
        self.parent?.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.reloadData(_:)),
            name: .reloadFavoriteTagData,
            object: nil
        )
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: TagViewReactor) {
        
        self.searchViewButtonView.rx.didTap
            .subscribe(with: self) { object, _ in
                let tagSearchViewController = TagSearchViewController()
                tagSearchViewController.reactor = reactor.reactorForSearch()
                object.parent?.navigationPush(tagSearchViewController, animated: true)
            }
            .disposed(by: self.disposeBag)
        
        self.favoriteTagsView.backgroundDidTap
            .subscribe(with: self) { object, model in
                let tagCollectViewController = TagCollectViewController()
                tagCollectViewController.reactor = reactor.reactorForCollect(
                    with: model.id,
                    title: model.text,
                    isFavorite: model.isFavorite
                )
                object.parent?.navigationPush(tagCollectViewController, animated: true)
            }
            .disposed(by: self.disposeBag)
        
        self.popularTagsView.backgroundDidTap
            .throttle(.seconds(2), scheduler: MainScheduler.instance)
            .subscribe(with: self) { object, model in
                let tagCollectViewController = TagCollectViewController()
                tagCollectViewController.reactor = reactor.reactorForCollect(
                    with: model.id,
                    title: model.name,
                    isFavorite: reactor.currentState.favoriteTags.contains(where: { $0.id == model.id })
                )
                object.parent?.navigationPush(tagCollectViewController, animated: true)
            }
            .disposed(by: self.disposeBag)
        
        // Action
        self.rx.viewDidLoad
            .map { _ in Reactor.Action.landing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.favoriteTagsView.favoriteIconDidTap
            .map(Reactor.Action.updateIsFavorite)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        let isRefreshing = reactor.state.map(\.isRefreshing).distinctUntilChanged().share()
        self.scrollView.refreshControl?.rx.controlEvent(.valueChanged)
            .withLatestFrom(isRefreshing)
            .filter { $0 == false }
            .delay(.milliseconds(1000), scheduler: MainScheduler.instance)
            .map { _ in Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        isRefreshing
            .observe(on: MainScheduler.asyncInstance)
            .filter { $0 == false }
            .subscribe(with: self.scrollView) { scrollView, _ in
                scrollView.refreshControl?.endRefreshing()
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map {
            TagViewReactor.DisplayStates(
                favoriteTags: $0.favoriteTags,
                popularTags: $0.popularTags
            )
        }
        .distinctUntilChanged(reactor.canUpdateCells)
        .observe(on: MainScheduler.asyncInstance)
        .subscribe(with: self) { object, displayStats in
            
            object.favoriteTagHeaderView.title = (UserDefaults.standard.nickname ?? "") + Text.favoriteTagHeaderTitle
            
            guard let favoriteTags = displayStats.favoriteTags else { return }
            
            object.favoriteTagsView.setModels(favoriteTags)
            
            guard let popularTags = displayStats.popularTags else { return }
            
            object.popularTagHeaderView.isHidden = popularTags.isEmpty
            object.popularTagsView.isHidden = popularTags.isEmpty
            
            object.popularTagsView.setModels(popularTags)
        }
        .disposed(by: self.disposeBag)
        
        let isUpdatedWithInfo = reactor.pulse(\.$isUpdatedWithInfo).filterNil()
        isUpdatedWithInfo
            .filter { $0.isUpdated }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, isUpdatedWithInfo in
                
                let message = isUpdatedWithInfo.model.isFavorite ? Text.addToastMessage : Text.deleteToastMessage
                let bottomToastView = SOMBottomToastView(
                    title: "‘\(isUpdatedWithInfo.model.text)’" + message,
                    actions: nil
                )
                
                var wrapper: SwiftEntryKitViewWrapper = bottomToastView.sek
                wrapper.entryName = Text.bottomToastEntryName
                wrapper.showBottomToast(verticalOffset: 34 + 54 + 8)
            }
            .disposed(by: self.disposeBag)
        
        isUpdatedWithInfo
            .filter { $0.isUpdated == false }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, isUpdatedWithInfo in
                
                let actions = [
                    SOMBottomToastView.ToastAction(title: Text.failToastActionTitle, action: {
                       SwiftEntryKit.dismiss(.specific(entryName: Text.bottomToastEntryNameWithAction)) {
                           reactor.action.onNext(.updateIsFavorite(isUpdatedWithInfo.model))
                       }
                   })
                ]
                let bottomToastView = SOMBottomToastView(title: Text.failedToastMessage, actions: actions)
                
                var wrapper: SwiftEntryKitViewWrapper = bottomToastView.sek
                wrapper.entryName = Text.bottomToastEntryName
                wrapper.showBottomToast(verticalOffset: 34 + 54 + 8)
            }
            .disposed(by: self.disposeBag)
    }
    
    
    // MARK: Objc func
    
    @objc
    private func reloadData(_ notification: Notification) {
        
        self.reactor?.action.onNext(.favoriteTags)
    }
}


// MARK: UIScrollViewDelegate

extension TagViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        
        // currentOffset <= 0 && isRefreshing == false 일 때, 테이블 뷰 새로고침 가능
        self.isRefreshEnabled = (offset <= 0) && (self.reactor?.currentState.isRefreshing == false)
        self.shouldRefreshing = false
        self.initialOffset = offset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        
        // 당겨서 새로고침
        if self.isRefreshEnabled, offset < self.initialOffset,
           let refreshControl = self.scrollView.refreshControl as? SOMRefreshControl {
           
           refreshControl.updateProgress(
               offset: scrollView.contentOffset.y,
               topInset: scrollView.adjustedContentInset.top
           )
            
            let pulledOffset = self.initialOffset - offset
            /// refreshControl heigt + top padding
            let refreshingOffset: CGFloat = 44 + 12
            self.shouldRefreshing = abs(pulledOffset) >= refreshingOffset
        }
        
        self.currentOffset = offset
    }
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        
        if self.shouldRefreshing {
            self.scrollView.refreshControl?.beginRefreshing()
        }
    }
}
