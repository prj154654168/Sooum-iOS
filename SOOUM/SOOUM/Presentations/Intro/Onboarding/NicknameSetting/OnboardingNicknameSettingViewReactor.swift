//
//  OnboardingNicknameSettingViewReactor.swift
//  SOOUM
//
//  Created by JDeoks on 11/7/24.
//

import ReactorKit
import RxCocoa
import RxSwift

class OnboardingNicknameSettingViewReactor: Reactor {
    
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
    }
    
    enum ErrorMessages: String {
        case isEmpty = "한글자 이상 입력해주세요"
        case inValid = "부적절한 닉네임입니다. 다시 입력해주세요"
    }

    enum Action {
        case landing
        case checkValidate(String)
    }

    enum Mutation {
        case updateNickname(String)
        case updateIsValid(Bool)
        case updateIsErrorMessage(String?)
    }

    struct State {
        fileprivate(set) var nickname: String
        fileprivate(set) var isValid: Bool
        fileprivate(set) var errorMessage: String?
    }

    var initialState: State = .init(
        nickname: "\(Text.adjectives.randomElement()!) \(Text.nouns.randomElement()!)",
        isValid: false,
        errorMessage: nil
    )
    
    private let dependencies: AppDIContainerable
    private let validateNicknameUseCase: ValidateNicknameUseCase
    
    init(dependencies: AppDIContainerable) {
        self.dependencies = dependencies
        self.validateNicknameUseCase = dependencies.rootContainer.resolve(ValidateNicknameUseCase.self)
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .landing:
            
            return self.validateNicknameUseCase.nickname()
                .map(Mutation.updateNickname)
        case let .checkValidate(nickname):
            
            if nickname.isEmpty {
                return .concat([
                    .just(.updateIsValid(false)),
                    .just(.updateIsErrorMessage(ErrorMessages.isEmpty.rawValue))
                ])
            }
            
            return .concat([
                .just(.updateIsErrorMessage(nil)),
                self.validateNicknameUseCase.checkValidation(nickname: nickname)
                    .withUnretained(self)
                    .flatMapLatest { object, isValid -> Observable<Mutation> in
                        
                        let errorMessage = isValid ? nil : ErrorMessages.inValid.rawValue
                        let nickname = isValid ? nickname : object.currentState.nickname
                        return .concat([
                            .just(.updateIsValid(isValid)),
                            .just(.updateNickname(nickname)),
                            .just(.updateIsErrorMessage(errorMessage))
                        ])
                    }
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .updateNickname(nickname):
            newState.nickname = nickname
        case let .updateIsValid(isValid):
            newState.isValid = isValid
        case let .updateIsErrorMessage(errorMessage):
            newState.errorMessage = errorMessage
        }
        return newState
    }
}

extension OnboardingNicknameSettingViewReactor {
    
    func reactorForProfileImage() -> OnboardingProfileImageSettingViewReactor {
        OnboardingProfileImageSettingViewReactor(
            dependencies: self.dependencies,
            nickname: self.currentState.nickname
        )
    }
}
