//
//  UserDefaults.swift
//  SOOUM
//
//  Created by 오현식 on 11/28/24.
//

import Foundation


extension UserDefaults {
    
    // Keychain 삭제를 위한 flag
    static var isFirstLaunch: Bool {
        
        let hasBeenLaunchedBefore = "hasBeenLaunchedBefore"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunchedBefore)
        
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: hasBeenLaunchedBefore)
            UserDefaults.standard.synchronize()
        }
        
        return isFirstLaunch
    }
}
