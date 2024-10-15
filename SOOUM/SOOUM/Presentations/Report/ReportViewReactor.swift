//
//  ReportViewReactor.swift
//  SOOUM
//
//  Created by JDeoks on 10/13/24.
//

import Foundation

import ReactorKit

class ReportViewReactor: Reactor {
    
    enum Action: Equatable {
        case report(ReportViewController.ReportType)
        case dismissDialog
    }
    
    enum Mutation {
        /// 신고 로직 실행
        case report
        /// 업로드 완료 여부 변경
        case updatewDialogPresent(Bool)
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
        case .dismissDialog:
            return .just(.updatewDialogPresent(false))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state: State = state
        switch mutation {
        case .report:
            state.isDialogPresented = true
        case let .updatewDialogPresent(isPresent):
            state.isDialogPresented = isPresent
        }
        return state
    }
    
    func summitReport(reportType: ReportViewController.ReportType) -> Observable<Mutation> {
        var request = ReportRequest.reportCard(id: id, reportType: reportType)
        return self.networkManager.request(LatestCardResponse.self, request: request)
            .map { _ in
                Mutation.report
            }
    }
}
