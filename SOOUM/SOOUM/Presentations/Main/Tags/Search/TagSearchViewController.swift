//
//  TagSearchViewController.swift
//  SOOUM
//
//  Created by 오현식 on 11/22/25.
//

import UIKit

import SnapKit
import Then

import SwiftEntryKit

import ReactorKit
import RxCocoa
import RxSwift

class TagSearchViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let placeholderText: String = "태그를 검색하세요"
        
        static let bottomToastEntryName: String = "bottomToastEntryName"
        static let addToastMessage: String = "을 관심 태그에 추가했어요"
        static let deleteToastMessage: String = "을 관심 태그에서 삭제했어요"
        
        static let bottomToastEntryNameWithAction: String = "bottomToastEntryNameWithAction"
        static let failedToastMessage: String = "네트워크 확인 후 재시도해주세요."
        static let failToastActionTitle: String = "재시도"
        
        static let bottomToastEntryNameWithoutAction: String = "bottomToastEntryNameWithoutAction"
        static let addAdditionalLimitedFloatMessage: String = "관심 태그는 9개까지 추가할 수 있어요"
        
        static let pungedCardDialogTitle: String = "삭제된 카드예요"
        static let confirmActionTitle: String = "확인"
    }
    
    
    // MARK: Views
    
    private let searchTextFieldView = SearchTextFieldView().then {
        $0.placeholder = Text.placeholderText
    }
    
    private let rightFavoriteButton = SOMButton().then {
        $0.image = .init(.icon(.v2(.filled(.star))))
        $0.foregroundColor = .som.v2.gray200
    }
    
    private let searchTermsView = SearchTermsView().then {
        $0.isHidden = true
    }
    
    private let tagCollectCardsView = TagCollectCardsView().then {
        $0.isHidden = true
    }
    
    
    // MARK: Constraints
    
    private var searchTextFieldWidthConstraint: Constraint?
    
    
    // MARK: Override func
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { }
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        var width: CGFloat
        if self.reactor?.currentState.tagCardInfos == nil {
            width = (UIScreen.main.bounds.width - 16 * 2) - 24 - 12
            self.navigationBar.setRightButtons([])
        } else {
            width = UIScreen.main.bounds.width - 24 * 2 - 12 * 2
            self.navigationBar.setRightButtons([self.rightFavoriteButton])
        }
        
        self.searchTextFieldView.snp.makeConstraints {
            self.searchTextFieldWidthConstraint = $0.width.equalTo(width).constraint
            $0.height.equalTo(44)
        }
        self.navigationBar.titleView = self.searchTextFieldView
        self.navigationBar.titlePosition = .left
        
        self.rightFavoriteButton.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        
        self.navigationBar.setLeftButtons([])
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.searchTermsView)
        self.searchTermsView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(8)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
        
        self.view.addSubview(self.tagCollectCardsView)
        self.tagCollectCardsView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(8)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
    }
    /// 기본 뒤로가기 기능 제거
    override func bind() { }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: TagSearchViewReactor) {
        
        // 검색 화면 진입 및 태그 관련 카드 정보가 없을 때, 검색 필드 포커스
        let tagCardInfos = reactor.state.map(\.tagCardInfos).share()
        self.rx.viewDidAppear
            .withLatestFrom(
                tagCardInfos,
                resultSelector: { $0 && ($1?.isEmpty ?? true) }
            )
            .filter { $0 }
            .subscribe(with: self) { object, _ in
                object.searchTextFieldView.becomeFirstResponder()
            }
            .disposed(by: self.disposeBag)
        
        let searchTerms = reactor.state.map(\.searchTerms).share()
        /// 뒤로가기로 시 TagViewController를 표시할 때, 관심 태그만 리로드 및 검색 초기화
        self.navigationBar.backButton.rx.throttleTap
            .withLatestFrom(Observable.combineLatest(searchTerms, tagCardInfos))
            .map { ($0 == nil, $1 == nil) }
            .subscribe(with: self) { object, combined in
                let width = (UIScreen.main.bounds.width - 16 * 2) - 24 - 12
                object.searchTextFieldWidthConstraint?.update(offset: width)
                
                object.navigationBar.setRightButtons([])
                
                let (isSearchTermsNil, isTagCardInfosNil) = combined
                // 검색 결과가 없을 때만
                if isSearchTermsNil && isTagCardInfosNil {
                    /// 뒤로가기로 TagViewController를 표시할 때, 관심 태그만 리로드
                    NotificationCenter.default.post(
                        name: .reloadFavoriteTagData,
                        object: nil,
                        userInfo: nil
                    )
                    object.navigationPop()
                } else {
                    object.searchTextFieldView.text = nil
                    
                    reactor.action.onNext(.cleanup(.search))
                    reactor.action.onNext(.cleanup(.tagCard))
                }
            }
            .disposed(by: self.disposeBag)
        
        // 검색 필드에 포커스 됐을 때, 네비게이션 바 및 태그 모아보기 초기화
        self.searchTextFieldView.textField.rx.controlEvent(.editingDidBegin)
            .do(onNext: { _ in reactor.action.onNext(.cleanup(.tagCard)) })
            .subscribe(with: self) { object, _ in
                object.searchTermsView.isHidden = false
                object.tagCollectCardsView.isHidden = true
                
                let width = (UIScreen.main.bounds.width - 16 * 2) - 24 - 12
                object.searchTextFieldWidthConstraint?.update(offset: width)
                
                object.navigationBar.setRightButtons([])
            }
            .disposed(by: self.disposeBag)
        
        // 태그 카드 모아보기 전환
        self.searchTermsView.backgroundDidTap
            .throttle(.seconds(3), scheduler: MainScheduler.instance)
            .do(onNext: { model in
                reactor.action.onNext(.cardsWithTag(.init(id: model.id, title: model.name)))
            })
            .subscribe(with: self) { object, model in
                object.view.endEditing(true)
                
                object.searchTermsView.isHidden = true
                object.tagCollectCardsView.isHidden = false
                
                object.searchTextFieldView.text = model.name
                
                let leftAndRightButtonsWidth: CGFloat = 24 * 2
                let leftAndRightPadding: CGFloat = 12 * 2
                let width = UIScreen.main.bounds.width - leftAndRightButtonsWidth - leftAndRightPadding
                object.searchTextFieldWidthConstraint?.update(offset: width)
                
                object.navigationBar.setRightButtons([object.rightFavoriteButton])
            }
            .disposed(by: self.disposeBag)
        
        // 상세 화면 전환
        self.tagCollectCardsView.cardDidTapped
            .map(\.id)
            .throttle(.seconds(3), scheduler: MainScheduler.instance)
            .map(Reactor.Action.hasDetailCard)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // 스크롤 시 키보드 내림
        Observable.merge(
            self.searchTermsView.didScrolled.asObservable(),
            self.tagCollectCardsView.didScrolled.asObservable()
        )
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, _ in object.view.endEditing(true) }
            .disposed(by: self.disposeBag)
        
        // Action
        self.searchTextFieldView.rx.text
            .skip(1)
            .filterNil()
            .distinctUntilChanged()
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .map(Reactor.Action.search)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.tagCollectCardsView.moreFindWithId
            .map(Reactor.Action.more)
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
        
        let isFavorite = reactor.state.map(\.isFavorite).share()
        self.rightFavoriteButton.rx.throttleTap
            .withLatestFrom(isFavorite)
            .map(Reactor.Action.updateIsFavorite)
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
        
        Observable.combineLatest(
            searchTerms.distinctUntilChanged(),
            tagCardInfos.distinctUntilChanged()
        )
        .observe(on: MainScheduler.asyncInstance)
        .subscribe(with: self) { object, combined in
            let (searchTerms, tagCardInfos) = combined
            
            if let searchTerms = searchTerms { object.searchTermsView.setModels(searchTerms) }
            if let tagCardInfos = tagCardInfos { object.tagCollectCardsView.setModels(tagCardInfos) }
            
            object.searchTermsView.isHidden = tagCardInfos?.isEmpty ?? false
            object.tagCollectCardsView.isHidden = tagCardInfos?.isEmpty ?? true
        }
        .disposed(by: self.disposeBag)
        Observable.combineLatest(searchTerms, tagCardInfos)
            .map { ($0 == nil, $1 == nil) }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, combined in
                let (isSearchTermsNil, isTagCardInfosNil) = combined
                
                object.searchTermsView.isHidden = isSearchTermsNil
                object.tagCollectCardsView.isHidden = isTagCardInfosNil
            }
            .disposed(by: self.disposeBag)
        
        self.searchTextFieldView.textFieldDidReturn
            .withLatestFrom(searchTerms.filterNil())
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, models in
                object.searchTermsView.setModels(models, with: true)
                object.searchTermsView.isHidden = false
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
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { isFavorite in
                if isFavorite {
                    GAHelper.shared.logEvent(event: GAEvent.TagView.favoriteTagRegister_btnClick)
                }
                
                let message = isFavorite ? Text.addToastMessage : Text.deleteToastMessage
                let bottomToastView = SOMBottomToastView(
                    title: "‘\(reactor.currentState.selectedTagInfo?.title ?? "")’" + message,
                    actions: nil
                )
                
                var wrapper: SwiftEntryKitViewWrapper = bottomToastView.sek
                wrapper.entryName = Text.bottomToastEntryName
                wrapper.showBottomToast(verticalOffset: 34 + 8)
            })
            .disposed(by: self.disposeBag)
        
        isUpdated
            .filter { $0 == false }
            .withLatestFrom(isFavorite)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { isFavorite in
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
            })
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.hasErrors)
            .distinctUntilChanged()
            .filterNil()
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { _ in
                let bottomToastView = SOMBottomToastView(title: Text.addAdditionalLimitedFloatMessage, actions: nil)
                
                var wrapper: SwiftEntryKitViewWrapper = bottomToastView.sek
                wrapper.entryName = Text.bottomToastEntryNameWithoutAction
                wrapper.showBottomToast(verticalOffset: 34 + 8)
            })
            .disposed(by: self.disposeBag)
        
        let cardIsDeleted = reactor.state.map(\.cardIsDeleted)
            .distinctUntilChanged(reactor.canPushToDetail)
            .filterNil()
        cardIsDeleted
            .filter { $0.isDeleted }
            .map { $0.selectedId }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, selectedId in
                object.showPungedCardDialog(reactor, with: selectedId)
            }
            .disposed(by: self.disposeBag)
        cardIsDeleted
            .filter { $0.isDeleted == false }
            .map { $0.selectedId }
            .do(onNext: { _ in
                reactor.action.onNext(.cleanup(.push))
                
                GAHelper.shared.logEvent(
                    event: GAEvent.DetailView.cardDetail_tracePathClick(
                        previous_path: .tag_search_collect
                    )
                )
            })
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, selectedId in
                let detailViewController = DetailViewController()
                detailViewController.reactor = reactor.reactorForDetail(with: selectedId)
                object.navigationPush(detailViewController, animated: true)
            }
            .disposed(by: self.disposeBag)
    }
}


// MARK: Show dialog

private extension TagSearchViewController {
    
    func showPungedCardDialog(_ reactor: TagSearchViewReactor, with selectedId: String) {
        
        let confirmAction = SOMDialogAction(
            title: Text.confirmActionTitle,
            style: .primary,
            action: {
                SOMDialogViewController.dismiss {
                    reactor.action.onNext(.cleanup(.push))
                    
                    let tagCardInfos = reactor.currentState.tagCardInfos ?? []
                    reactor.action.onNext(
                        .updateTagCards(
                            tagCardInfos.filter { $0.id != selectedId }
                        )
                    )
                }
            }
        )
        
        SOMDialogViewController.show(
            title: Text.pungedCardDialogTitle,
            messageView: nil,
            textAlignment: .left,
            actions: [confirmAction]
        )
    }
}
