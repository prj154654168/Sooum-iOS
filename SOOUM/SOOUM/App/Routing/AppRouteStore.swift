//
//  AppRouteStore.swift
//  SOOUM
//
//  Created by Codex on 7/5/26.
//

import Foundation

final class AppRouteStore {

    private let queue = DispatchQueue(label: "com.sooum.appRouteStore")
    private weak var sceneHandler: SceneRouteHandling?
    private var pendingRoute: AppRoute?

    func setActiveSceneHandler(_ handler: SceneRouteHandling) {
        self.queue.sync {
            self.sceneHandler = handler
        }
    }

    func clearActiveSceneHandler(_ handler: SceneRouteHandling) {
        self.queue.sync {
            guard self.sceneHandler === handler else { return }
            self.sceneHandler = nil
        }
    }

    func activeSceneHandler() -> SceneRouteHandling? {
        self.queue.sync { self.sceneHandler }
    }

    func enqueue(_ route: AppRoute) {
        self.queue.sync {
            // Root route는 마지막 요청을 우선한다.
            self.pendingRoute = route
        }
    }

    func consumePendingRoute() -> AppRoute? {
        self.queue.sync {
            defer { self.pendingRoute = nil }
            return self.pendingRoute
        }
    }
}
