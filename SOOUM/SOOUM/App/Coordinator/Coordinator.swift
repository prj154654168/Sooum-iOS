//
//  Coordinator.swift
//  SOOUM
//
//  Created by Codex on 7/5/26.
//

import Foundation

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

class BaseCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    func start() { }

    func store(_ coordinator: Coordinator) {
        self.childCoordinators.append(coordinator)
    }

    func free(_ coordinator: Coordinator) {
        self.childCoordinators.removeAll { $0 === coordinator }
    }
}
