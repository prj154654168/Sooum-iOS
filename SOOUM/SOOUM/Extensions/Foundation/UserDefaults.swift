//
//  UserDefaults.swift
//  SOOUM
//
//  Created by 오현식 on 11/28/24.
//

import Foundation


extension UserDefaults {
    
    enum Keys {
        static let hasBeenLaunchedBefore: String = "hasBeenLaunchedBefore"
        static let hasBeenShowMessageGuide: String = "hasBeenShowMessageGuide"
        static let hasBeenShowWriteCardGuide: String = "hasBeenShowWriteCardGuide"
        static let userNickname: String = "userNickname"
    }
    
    // Keychain 삭제를 위한 flag
    static var isFirstLaunch: Bool {
        
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: Keys.hasBeenLaunchedBefore)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: Keys.hasBeenLaunchedBefore)
        }
        
        return isFirstLaunch
    }
    
    // 메인 홈 카드추가 가이드 메시지를 위한 flag
    static var showGuideMessage: Bool {
        
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: Keys.hasBeenShowMessageGuide)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: Keys.hasBeenShowMessageGuide)
        }
        
        return isFirstLaunch
    }
    
    // 카드추가 시 가이드 뷰를 위한 flag
    static var showGuideView: Bool {
        
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: Keys.hasBeenShowWriteCardGuide)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: Keys.hasBeenShowWriteCardGuide)
        }
        
        return isFirstLaunch
    }
    
    // Nickname의 전역 사용을 위한 확장
    var nickname: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.userNickname)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.userNickname)
        }
    }
}
