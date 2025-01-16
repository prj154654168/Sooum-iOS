//
//  CompositeManager.swift
//  SOOUM
//
//  Created by 오현식 on 1/14/25.
//

import Foundation


class CompositeManager: NSObject {
    
    weak var provider: ManagerProviderType?
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }
}
