//
//  TagSearchViewController.swift
//  SOOUM
//
//  Created by 오현식 on 11/22/25.
//

import UIKit

import SnapKit
import Then

import ReactorKit
import RxCocoa
import RxSwift

class TagSearchViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let placeholderText: String = "태그를 검색하세요"
    }
    
    
    // MARK: Views
    
    private let searchTextFieldView = SearchTextFieldView().then {
        $0.placeholder = Text.placeholderText
    }
    
    private let searchTermsView = SearchTermsView().then {
        $0.isHidden = true
    }
    
    
    // MARK: Override func
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { }
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.searchTextFieldView.snp.makeConstraints {
            let width = (UIScreen.main.bounds.width - 16 * 2) - 24 - 12
            $0.width.equalTo(width)
            $0.height.equalTo(44)
        }
        self.navigationBar.titleView = self.searchTextFieldView
        self.navigationBar.titlePosition = .left
        
        self.navigationBar.setRightButtons([])
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.searchTermsView)
        self.searchTermsView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(8)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
    }
    /// 기본 뒤로가기 기능 제거
    override func bind() { }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: TagSearchViewReactor) {
        
        // 검색 화면 진입 시 포커스
        self.rx.viewDidAppear
            .subscribe(with: self) { object, _ in
                object.searchTextFieldView.becomeFirstResponder()
            }
            .disposed(by: self.disposeBag)
        
        let searchTerms = reactor.state.map(\.searchTerms).share()
        /// 뒤로가기로 시 TagViewController를 표시할 때, 관심 태그만 리로드 및 검색 초기화
        self.navigationBar.backButton.rx.throttleTap
            .withLatestFrom(searchTerms)
            .map { $0 == nil }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, isNil in
                // 검색 결과가 없을 때만
                if isNil {
                    /// 뒤로가기로 TagViewController를 표시할 때, 관심 태그만 리로드
                    NotificationCenter.default.post(
                        name: .reloadFavoriteTagData,
                        object: nil,
                        userInfo: nil
                    )
                    object.navigationPop()
                } else {
                    object.reactor?.action.onNext(.reset)
                    object.searchTextFieldView.text = nil
                    object.searchTextFieldView.resignFirstResponder()
                }
            }
            .disposed(by: self.disposeBag)
        
        // 태그 카드 모아보기 화면 전환
        self.searchTermsView.backgroundDidTap
            .throttle(.seconds(3), scheduler: MainScheduler.instance)
            .subscribe(with: self) { object, model in
                object.searchTextFieldView.text = nil
                reactor.action.onNext(.reset)
                
                let tagSearchCollectViewController = TagSearchCollectViewController()
                tagSearchCollectViewController.reactor = reactor.reactorForSearchCollect(
                    with: model.id,
                    title: model.name
                )
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak object] in
                    object?.navigationPush(
                        tagSearchCollectViewController,
                        animated: true
                    )
                }
            }
            .disposed(by: self.disposeBag)
        
        // 스크롤 시 키보드 내림
        self.searchTermsView.didScrolled.asObservable()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, _ in object.view.endEditing(true) }
            .disposed(by: self.disposeBag)
        
        // Action
        let searchText = self.searchTextFieldView.textField.rx.text.orEmpty.distinctUntilChanged().share()
        // 태그 검색
        searchText
            .skip(1)
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .map(Reactor.Action.search)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        searchTerms
            .filter { $0 == nil }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, _ in
                object.searchTermsView.isHidden = true
            }
            .disposed(by: self.disposeBag)
        
        searchTerms
            .filterNil()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, searchTerms in
                object.searchTermsView.setModels(searchTerms)
                object.searchTermsView.isHidden = false
            }
            .disposed(by: self.disposeBag)
        
        Observable.combineLatest(
            searchTerms.filterNil(),
            self.searchTextFieldView.textFieldDidReturn,
            resultSelector: { ($0, $1) }
        )
        .observe(on: MainScheduler.asyncInstance)
        .subscribe(with: self) { object, searchTermInfos in
            let (searchTerms, returnKeyDidTap) = searchTermInfos
            
            object.searchTermsView.setModels(searchTerms, with: returnKeyDidTap != nil)
            object.searchTermsView.isHidden = false
        }
        .disposed(by: self.disposeBag)
    }
}
