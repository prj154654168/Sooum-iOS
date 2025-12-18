//
//  AppDIContainer.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Foundation

protocol AppDIContainerable {
    
    var rootContainer: BaseDIContainerable { get }
}

final class AppDIContainer: AppDIContainerable {
    
    var rootContainer: BaseDIContainerable
    
    init() {
        
        self.rootContainer = BaseDIContainer()
        
        let appAssembler = AppAssembler()
        
        appAssembler.assemble(container: self.rootContainer)
    }
}
