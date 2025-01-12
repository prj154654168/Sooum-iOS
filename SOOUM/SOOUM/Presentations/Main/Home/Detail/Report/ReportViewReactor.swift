//
//  ReportViewReactor.swift
//  SOOUM
//
//  Created by JDeoks on 10/13/24.
//

import Foundation

import ReactorKit

class ReportViewReactor: Reactor {
    
    enum ReportType: String, CaseIterable {
        case profanity = "DEFAMATION_AND_ABUSE"
        case privacyViolation = "PRIVACY_VIOLATION"
        case inappropriatePromotion = "INAPPROPRIATE_ADVERTISING"
        case obsceneContent = "PORNOGRAPHY"
        case fraud = "IMPERSONATION_AND_FRAUD"
        case etc = "OTHER"
        
        var title: String {
            switch self {
            case .profanity:
                "비방 및 욕설"
            case .privacyViolation:
                "개인정보 침해"
            case .inappropriatePromotion:
                "부적절한 홍보 및 바이럴"
            case .obsceneContent:
                "음란물"
            case .fraud:
                "사칭 및 사기"
            case .etc:
                "기타"
            }
        }
        
        var description: String {
            switch self {
            case .profanity:
                "욕설을 사용하여 타인에게 모욕감을 주는 경우"
            case .privacyViolation:
                "법적으로 중요한 타인의 개인정보를 게재"
            case .inappropriatePromotion:
                "부적절한 스팸 홍보 행위"
            case .obsceneContent:
                "음란한 행위와 관련된 부적절한 행동"
            case .fraud:
                "사칭으로 타인의 권리를 침해하는 경우"
            case .etc:
                "해당하는 신고항목이 없는 경우"
            }
        }
    }
    
    enum Action: Equatable {
        case report(ReportType)
    }
    
    enum Mutation {
        /// 업로드 완료 여부 변경
        case updateDialogPresent(Bool)
    }
    
    struct State {
        var isDialogPresented: Bool
    }
    
    var initialState: State = .init(isDialogPresented: false)
    
    private let networkManager = NetworkManager.shared
    /// 신고할 카드 id
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .report(let reportType):
            return summitReport(reportType: reportType)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state: State = state
        switch mutation {
        case let .updateDialogPresent(isPresent):
            state.isDialogPresented = isPresent
        }
        return state
    }
    
    func summitReport(reportType: ReportType) -> Observable<Mutation> {
        
        let request = ReportRequest.reportCard(id: id, reportType: reportType)
        return self.networkManager.request(Status.self, request: request)
            .map { .updateDialogPresent($0.httpCode == 201) }
    } 
}
