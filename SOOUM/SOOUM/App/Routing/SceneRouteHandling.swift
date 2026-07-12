//
//  SceneRouteHandling.swift
//  SOOUM
//
//  Created by Codex on 7/5/26.
//

import Foundation

protocol SceneRouteHandling: AnyObject {
    var canHandleRoutes: Bool { get }
    func handle(_ route: AppRoute)
}
