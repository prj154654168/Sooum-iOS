//
//  ReportViewReactor.swift
//  SOOUM
//
//  Created by JDeoks on 10/13/24.
//

import ReactorKit

class ReportViewReactor: Reactor {
    
    enum Action: Equatable {
        case updateReportReason(ReportType)
        case report
    }
    
    enum Mutation {
        case updateReportReason(ReportType?)
        /// 업로드 완료 여부 변경
        case updateisReported(Bool)
        case updateHasErrors(Bool)
    }
    
    struct State {
        fileprivate(set) var reportReason: ReportType?
        fileprivate(set) var isReported: Bool
        fileprivate(set) var hasErrors: Bool
    }
    
    var initialState: State = .init(reportReason: nil, isReported: false, hasErrors: false)
    
    private let dependencies: AppDIContainerable
    private let reportCardUseCase: ReportCardUseCase
    /// 신고할 카드 id
    private let id: String
    
    init(dependencies: AppDIContainerable, with id: String) {
        self.dependencies = dependencies
        self.reportCardUseCase = dependencies.rootContainer.resolve(ReportCardUseCase.self)
        
        self.id = id
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateReportReason(reportReason):
            
            return .just(.updateReportReason(reportReason))
        case .report:
            
            guard let reportReason = self.currentState.reportReason else { return .empty() }
            
            return self.reportCardUseCase.report(cardId: self.id, reportType: reportReason.rawValue)
                .map(Mutation.updateisReported)
                .catchAndReturn(.updateHasErrors(true))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .updateReportReason(reportReason):
            newState.reportReason = reportReason
        case let .updateisReported(isReported):
            newState.isReported = isReported
        case let .updateHasErrors(hasErrors):
            newState.hasErrors = hasErrors
        }
        return newState
    }
}

extension ReportViewReactor {
    
    // TODO: 임시, 에러 발생 시 뒤로가기
    // var catchClosure: ((Error) throws -> Observable<Mutation> ) {
    //     return { error in
    //
    //         let nsError = error as NSError
    //         switch nsError.code {
    //         case 409, 410:  return .just(.updateHasErrors(true))
    //         default:        return .empty()
    //         }
    //     }
    // }
}
