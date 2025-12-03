//
//  TagSearchCollectViewController.swift
//  SOOUM
//
//  Created by 오현식 on 11/24/25.
//

import UIKit

import SnapKit
import Then

import SwiftEntryKit

import ReactorKit
import RxCocoa
import RxSwift

class TagSearchCollectViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let bottomToastEntryName: String = "bottomToastEntryName"
        static let addToastMessage: String = "을 관심 태그에 추가했어요"
        static let deleteToastMessage: String = "을 관심 태그에서 삭제했어요"
        
        static let bottomToastEntryNameWithAction: String = "bottomToastEntryNameWithAction"
        static let failedToastMessage: String = "네트워크 확인 후 재시도해주세요."
        static let failToastActionTitle: String = "재시도"
        
        static let bottomToastEntryNameWithoutAction: String = "bottomToastEntryNameWithoutAction"
        static let addAdditionalLimitedFloatMessage: String = "관심 태그는 9개까지 추가할 수 있어요"
    }
    
    
    // MARK: Views
    
    private let searchViewButtonView = SearchViewButton()
    
    private let rightFavoriteButton = SOMButton().then {
        $0.image = .init(.icon(.v2(.filled(.star))))
        $0.foregroundColor = .som.v2.yMain
    }
    
    private let tagCollectCardsView = TagCollectCardsView()
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.searchViewButtonView.snp.makeConstraints {
            let leftAndRightButtonsWidth: CGFloat = 24 * 2
            let leftAndRightPadding: CGFloat = 12 * 2
            let width = UIScreen.main.bounds.width - leftAndRightButtonsWidth - leftAndRightPadding
            $0.width.equalTo(width)
            $0.height.equalTo(44)
        }
        self.rightFavoriteButton.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        
        self.navigationBar.titleView = self.searchViewButtonView
        
        self.navigationBar.setLeftButtons([])
        self.navigationBar.setRightButtons([self.rightFavoriteButton])
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.tagCollectCardsView)
        self.tagCollectCardsView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(8)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: TagSearchCollectViewReactor) {
        
        // 상세 화면 전환
        self.tagCollectCardsView.cardDidTapped
            .throttle(.seconds(3), scheduler: MainScheduler.instance)
            .subscribe(with: self) { object, model in
                let detailViewController = DetailViewController()
                detailViewController.reactor = reactor.reactorForDetail(with: model.id)
                object.navigationPush(detailViewController, animated: true, bottomBarHidden: true)
            }
            .disposed(by: self.disposeBag)
        
        let viewDidLoad = self.rx.viewDidLoad
        // 네비게이션 타이틀
        viewDidLoad
            .subscribe(with: self) { object, _ in
                object.searchViewButtonView.placeholder = reactor.title
            }
            .disposed(by: self.disposeBag)
        
        // Action
        viewDidLoad
            .map { _ in Reactor.Action.landing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.tagCollectCardsView.moreFindWithId
            .map(Reactor.Action.more)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        let isFavorite = reactor.state.map(\.isFavorite).share()
        self.rightFavoriteButton.rx.throttleTap
            .withLatestFrom(isFavorite)
            .map(Reactor.Action.updateIsFavorite)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        let isRefreshing = reactor.state.map(\.isRefreshing).distinctUntilChanged().share()
        self.tagCollectCardsView.refreshControl.rx.controlEvent(.valueChanged)
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
            .subscribe(with: self.tagCollectCardsView) { tagCollectCardsView, _ in
                tagCollectCardsView.isRefreshing = false
            }
            .disposed(by: self.disposeBag)
        
        isFavorite
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, isFavorite in
                object.rightFavoriteButton.foregroundColor = isFavorite ? .som.v2.yMain : .som.v2.gray200
            }
            .disposed(by: self.disposeBag)
        
        let isUpdated = reactor.state.map(\.isUpdated).distinctUntilChanged().filterNil()
        isUpdated
            .filter { $0 }
            .withLatestFrom(isFavorite)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, isFavorite in
                
                let message = isFavorite ? Text.addToastMessage : Text.deleteToastMessage
                let bottomToastView = SOMBottomToastView(
                    title: "‘\(reactor.title)’" + message,
                    actions: nil
                )
                
                var wrapper: SwiftEntryKitViewWrapper = bottomToastView.sek
                wrapper.entryName = Text.bottomToastEntryName
                wrapper.showBottomToast(verticalOffset: 34 + 8)
            }
            .disposed(by: self.disposeBag)
        
        isUpdated
            .filter { $0 == false }
            .withLatestFrom(isFavorite)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, isFavorite in
                
                let actions = [
                    SOMBottomToastView.ToastAction(title: Text.failToastActionTitle, action: {
                       SwiftEntryKit.dismiss(.specific(entryName: Text.bottomToastEntryNameWithAction)) {
                           reactor.action.onNext(.updateIsFavorite(isFavorite))
                       }
                   })
                ]
                let bottomToastView = SOMBottomToastView(title: Text.failedToastMessage, actions: actions)
                
                var wrapper: SwiftEntryKitViewWrapper = bottomToastView.sek
                wrapper.entryName = Text.bottomToastEntryNameWithAction
                wrapper.showBottomToast(verticalOffset: 34 + 8)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.hasErrors)
            .distinctUntilChanged()
            .filterNil()
            .filter { $0 }
            .subscribe(with: self) { object, _ in
                
                let bottomToastView = SOMBottomToastView(title: Text.addAdditionalLimitedFloatMessage, actions: nil)
                
                var wrapper: SwiftEntryKitViewWrapper = bottomToastView.sek
                wrapper.entryName = Text.bottomToastEntryNameWithoutAction
                wrapper.showBottomToast(verticalOffset: 34 + 8)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.tagCardInfos)
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, tagCardInfos in
                
                object.tagCollectCardsView.setModels(tagCardInfos)
            }
            .disposed(by: self.disposeBag)
    }
}
