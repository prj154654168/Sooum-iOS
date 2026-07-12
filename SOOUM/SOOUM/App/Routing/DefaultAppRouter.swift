//
//  DefaultAppRouter.swift
//  SOOUM
//
//  Created by Codex on 7/5/26.
//

import Foundation

final class DefaultAppRouter: AppRouting {

    private let routeStore: AppRouteStore

    init(routeStore: AppRouteStore) {
        self.routeStore = routeStore
    }

    func handle(_ route: AppRoute) {
        DispatchQueue.main.async { [weak self] in
            // Root 전환을 현재 Rx 이벤트 처리 스택과 분리해 reentrancy를 방지한다.
            self?.dispatch(route)
        }
    }

    private func dispatch(_ route: AppRoute) {
        if let handler = self.routeStore.activeSceneHandler(),
           handler.canHandleRoutes {
            handler.handle(route)
        } else {
            self.routeStore.enqueue(route)
        }
    }
}
