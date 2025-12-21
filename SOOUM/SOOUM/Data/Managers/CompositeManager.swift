//
//  CompositeManager.swift
//  SOOUM
//
//  Created by 오현식 on 1/14/25.
//

import Foundation


class CompositeManager<C: ManagerConfiguration>: NSObject {
    
    let provider: ManagerTypeDelegate
    let configure: C
    
    init(provider: ManagerTypeDelegate, configure: C) {
        self.provider = provider
        self.configure = configure
    }
}
