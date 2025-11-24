//
//  TagCollectViewController.swift
//  SOOUM
//
//  Created by 오현식 on 11/20/25.
//

import UIKit

import SnapKit
import Then

import SwiftEntryKit

import ReactorKit
import RxCocoa
import RxSwift

class TagCollectViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let bottomToastEntryName: String = "bottomToastEntryName"
        static let addToastMessage: String = "을 관심 태그에 추가했어요"
        static let deleteToastMessage: String = "을 관심 태그에서 삭제했어요"
        
        static let bottomToastEntryNameWithAction: String = "bottomToastEntryNameWithAction"
        static let failedToastMessage: String = "네트워크 확인 후 재시도해주세요."
        static let failToastActionTitle: String = "재시도"
    }
    
    enum Section: Int, CaseIterable {
        case main
        case empty
    }
    
    enum Item: Hashable {
        case main(ProfileCardInfo)
        case empty
    }
    
    
    // MARK: Views
    
    private let rightFavoriteButton = SOMButton().then {
        $0.image = .init(.icon(.v2(.filled(.star))))
        $0.foregroundColor = .som.v2.yMain
    }
    
    private let tagCollectCardsView = TagCollectCardsView()
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = self.reactor?.title ?? ""
        
        self.rightFavoriteButton.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        self.navigationBar.setRightButtons([self.rightFavoriteButton])
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.tagCollectCardsView)
        self.tagCollectCardsView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
    }
    
    override func bind() {
        /// 뒤로가기로 TagViewController를 표시할 때, 관심 태그만 리로드
        self.navigationBar.backButton.rx.throttleTap
            .subscribe(with: self) { object, _ in
                object.navigationPop(animated: true, bottomBarHidden: true) {
                    NotificationCenter.default.post(
                        name: .reloadFavoriteTagData,
                        object: nil,
                        userInfo: nil
                    )
                }
            }
            .disposed(by: self.disposeBag)
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: TagCollectViewReactor) {
        
        // 상세화면 전환
        self.tagCollectCardsView.cardDidTapped
            .subscribe(with: self) { object, model in
                let detailViewController = DetailViewController()
                detailViewController.reactor = reactor.reactorForDetail(model.id)
                object.navigationPush(detailViewController, animated: true, bottomBarHidden: true)
            }
            .disposed(by: self.disposeBag)
        
        // Action
        self.rx.viewDidLoad
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
                wrapper.entryName = Text.bottomToastEntryName
                wrapper.showBottomToast(verticalOffset: 34 + 54 + 8)
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
