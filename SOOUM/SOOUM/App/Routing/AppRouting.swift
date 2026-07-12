//
//  AppRouting.swift
//  SOOUM
//
//  Created by Codex on 7/5/26.
//

import Foundation

protocol AppRouting: AnyObject {
    func handle(_ route: AppRoute)
}
