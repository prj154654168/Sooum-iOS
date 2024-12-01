//
//  OnboardingNicknameSettingViewController.swift
//  SOOUM
//
//  Created by JDeoks on 11/6/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift

import SnapKit
import Then

class OnboardingNicknameSettingViewController: BaseNavigationViewController, View {
    
    private let adjectives = [
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

    private let nouns = [
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

    private let maxCount = 8

    private let guideLabelView = OnboardingGuideLabelView().then {
        $0.titleLabel.text = "반가워요!\n당신을 어떻게 부르면 될까요?"
        $0.descLabel.text = "닉네임은 추후 변경이 가능해요"
    }
    
    private lazy var nicknameTextField = OnboardingNicknameTextFieldView()
    
    private let errorLogStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
        
        let imageView = UIImageView().then {
            $0.image = .error
            $0.contentMode = .scaleAspectFit
        }
        $0.addArrangedSubviews(imageView)
        $0.isHidden = true
    }
    
    private let errorLogLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: BuiltInFont(
                size: 14,
                weight: .regular
            ),
            lineHeight: 19.6,
            letterSpacing: 0
        )
        $0.textColor = .som.red
    }
    
    private let nicknameCountLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: BuiltInFont(
                size: 14,
                weight: .regular
            ),
            lineHeight: 19.6,
            letterSpacing: 0
        )
        $0.textColor = .som.gray500
        $0.text = "1/8"
    }
    
    private let nextButtonView = PrimaryButtonView()
    
    // Reactor를 연결하고, 액션과 상태를 바인딩합니다.
    func bind(reactor: OnboardingNicknameSettingViewReactor) {
        
        let nickname = nicknameTextField.textField.rx.text.orEmpty.distinctUntilChanged().share()
        nickname
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, str in
                object.nicknameCountLabel.text = "\(str.count)/\(object.maxCount)"
            }
            .disposed(by: disposeBag)
        
        nickname
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { Reactor.Action.textChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.rx.viewDidLoad
            .subscribe(with: self) { object, _ in
                object.nicknameTextField.textField.text = object.adjectives.randomElement()! +
                " " +
                object.nouns.randomElement()!
                object.nicknameTextField.textField.sendActions(for: .editingChanged)
            }
            .disposed(by: self.disposeBag)
        
        nicknameTextField.clearButtonView.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self) { object, _ in
                object.nicknameCountLabel.text = "0/\(object.maxCount)"
                object.nicknameTextField.textField.text?.removeAll()
                object.reactor?.action.onNext(.textChanged(""))
            }
            .disposed(by: disposeBag)
        
        nextButtonView.rx.tapGesture()
            .when(.recognized)
            .withLatestFrom(reactor.state.map(\.isNicknameValid))
            .filter { $0 == .vaild }
            .subscribe(with: self) { object, _ in
                let profileImageVC = ProfileImageSettingViewController()
                let profileImageReactor = ProfileImageSettingViewReactor(nickname: object.nicknameTextField.textField.text!)
                profileImageVC.reactor = profileImageReactor
                object.navigationController?.pushViewController(profileImageVC, animated: true)
            }
            .disposed(by: disposeBag)

        // MARK: - State Binding
        // 닉네임 유효성 검사 결과에 따라 nextButton의 활성화 상태 업데이트
        reactor.state
            .compactMap { $0.isNicknameValid }
            .subscribe(with: self, onNext: { object, isValid in
                object.nextButtonView.updateState(state: isValid == .vaild)
                object.errorLogStackView.isHidden = isValid == .vaild
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.errorMessage }
            .subscribe(with: self) { object, errorMessage in
                if let message = errorMessage {
                    object.errorLogLabel.text = message
                }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Setup
    override func setupConstraints() {
        view.addSubview(guideLabelView)
        guideLabelView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(28)
        }
        
        view.addSubview(nicknameTextField)
        nicknameTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(guideLabelView.snp.bottom).offset(24)
        }
        
        view.addSubview(errorLogStackView)
        errorLogStackView.addArrangedSubview(errorLogLabel)
        errorLogStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(10)
        }
        
        view.addSubview(nicknameCountLabel)
        nicknameCountLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(12)
        }
        
        view.addSubview(nextButtonView)
        nextButtonView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-13)
        }
    }
    
    // 키보드 상태 업데이트에 따른 버튼 위치 조정
    override func updatedKeyboard(withoutBottomSafeInset height: CGFloat) {
        super.updatedKeyboard(withoutBottomSafeInset: height)
                
        UIView.animate(withDuration: 0.25) {
            self.nextButtonView.snp.updateConstraints {
                let offset = -height - 13
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(offset)
            }
        }
        self.view.layoutIfNeeded()
    }
}
