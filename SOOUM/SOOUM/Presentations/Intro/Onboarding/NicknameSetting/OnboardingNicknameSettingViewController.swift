//
//  OnboardingNicknameSettingViewController.swift
//  SOOUM
//
//  Created by JDeoks on 11/6/24.
//

import UIKit

import SnapKit
import Then

import ReactorKit
import RxCocoa
import RxSwift


class OnboardingNicknameSettingViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let adjectives = [
            "공부하는", "생각하는", "사랑하는", "노래하는",
            "요리하는", "운동하는", "여행하는", "대화하는",
            "청소하는", "정리하는", "그리는", "사진하는",
            "연구하는", "설계하는", "개발하는", "관리하는",
            "발표하는", "수업하는", "교육하는", "상담하는",
            "치료하는", "분석하는", "조사하는", "기록하는",
            "편집하는", "제작하는", "수리하는", "판매하는",
            "구매하는", "투자하는", "기획하는", "운영하는",
            "지원하는", "협력하는", "참여하는", "소통하는",
            "개선하는", "실천하는", "실험하는", "탐구하는",
            "수집하는", "배달하는", "전달하는", "연결하는",
            "조정하는", "선택하는", "결정하는", "준비하는",
            "확인하는", "수업하는", "연습하는", "발표하는",
            "기록하는", "정리하는", "대처하는", "해결하는",
            "조율하는", "탐색하는", "분석하는", "실천하는"
        ]
        static let nouns = [
            "강아지", "고양이", "기린", "토끼",
            "사자", "호랑이", "악어", "코끼리",
            "판다", "부엉이", "까치", "앵무새",
            "여우", "오리", "수달", "다람쥐",
            "펭귄", "참새", "갈매기", "도마뱀",
            "우산", "책상", "가방", "의자",
            "시계", "안경", "컵", "접시",
            "전화기", "자전거", "냉장고", "라디오",
            "바나나", "케이크", "모자", "열쇠",
            "지도", "구두", "텀블러", "바구니",
            "공책", "거울", "청소기", "햄스터",
            "낙타", "두더지", "돌고래", "문어",
            "미어캣", "오소리", "다슬기", "해파리",
            "원숭이", "홍학", "물개", "바다표",
            "코뿔소", "물소", "개구리", "거북이"
        ]
        
        static let navigationTitle: String = "회원가입"
        
        static let title: String = "숨에서 사용할 닉네임을\n입력해주세요"
        static let guideMessage: String = "최대 8자까지 입력할 수 있어요"
        
        static let nextButtonTitle: String = "다음"
    }
    
    
    // MARK: Views

    private let guideMessageView = OnboardingGuideMessageView(title: Text.title, currentNumber: 2)
    
    private let nicknameTextField = OnboardingNicknameTextFieldView()
    
    private let nextButton = SOMButton().then {
        $0.title = Text.nextButtonTitle
        $0.typography = .som.v2.title1
        $0.foregroundColor = .som.v2.white
        $0.backgroundColor = .som.v2.black
    }
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
    }
    
    override func setupConstraints() {
        
        self.view.addSubview(self.guideMessageView)
        self.guideMessageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        self.view.addSubview(self.nicknameTextField)
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(self.guideMessageView.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview()
        }
        
        self.view.addSubview(self.nextButton)
        self.nextButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(56)
        }
    }
    
    // 키보드 상태 업데이트에 따른 버튼 위치 조정
    override func updatedKeyboard(withoutBottomSafeInset height: CGFloat) {
        super.updatedKeyboard(withoutBottomSafeInset: height)
        
        let height = height + 12
        self.nextButton.snp.updateConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-height)
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: OnboardingNicknameSettingViewReactor) {
        
        // Action
        let nickname = self.nicknameTextField.textField.rx.text.orEmpty.distinctUntilChanged().share()
        nickname
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .map(Reactor.Action.checkValidate)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.rx.viewDidLoad
            .map { _ in Text.adjectives.randomElement()! + " " + Text.nouns.randomElement()! }
            .subscribe(with: self) { object, randomText in
                object.nicknameTextField.text = randomText
                object.nicknameTextField.textField.sendActions(for: .editingChanged)
            }
            .disposed(by: self.disposeBag)
        
        self.nextButton.rx.tap
            .withLatestFrom(nickname)
            .subscribe(with: self) { object, nickname in
                let profileImageVC = OnboardingProfileImageSettingViewController()
                profileImageVC.reactor = reactor.reactorForProfileImage(nickname: nickname)
                object.navigationPush(profileImageVC, animated: true)
            }
            .disposed(by: disposeBag)

        // State
        reactor.state.map(\.isValid)
            .distinctUntilChanged()
            .bind(to: self.nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state.map(\.errorMessage)
            .distinctUntilChanged()
            .subscribe(with: self) { object, errorMessage in
                object.nicknameTextField.guideMessage = errorMessage == nil ? Text.guideMessage : errorMessage
                object.nicknameTextField.hasError = errorMessage != nil
            }
            .disposed(by: self.disposeBag)
    }
}
