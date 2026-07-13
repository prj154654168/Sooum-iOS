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
        static let writeCardVoteGuideFirstShownAt: String = "writeCardVoteGuideFirstShownAt"
        static let shouldHideNotice: String = "shouldHideNotice"
        static let shouldHideArticleDot: String = "shouldHideArticleDot"
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
    
    // 메인 홈, 카드추가 가이드 메시지를 위한 flag
    static var shouldShowMessage: Bool { !UserDefaults.standard.bool(forKey: Keys.hasBeenShowMessageGuide) }
    // 카드추가, 가이드 뷰를 위한 flag
    static var shouldShowGuideView: Bool { !UserDefaults.standard.bool(forKey: Keys.hasBeenShowWriteCardGuide) }
    // 두 가이드가 모두 완료되지 않았을 경우, true
    static var needsGuideMessageAndGuide: Bool { self.shouldShowMessage || self.shouldShowGuideView }
    // 가이드 메시지 및 뷰 상태 업데이트
    static func hadShownMessage() { UserDefaults.standard.set(true, forKey: Keys.hasBeenShowMessageGuide) }
    static func hadShownGuideView() { UserDefaults.standard.set(true, forKey: Keys.hasBeenShowWriteCardGuide) }

    // WriteCardViewController 최초 진입 시각 저장 및 노출 조건
    static func hadShownWriteCardVoteGuideIfNeeded(now: Date = .init()) {
        if UserDefaults.standard.object(forKey: Keys.writeCardVoteGuideFirstShownAt) == nil {
            UserDefaults.standard.set(now, forKey: Keys.writeCardVoteGuideFirstShownAt)
        }
    }

    static var shouldShowWriteCardVoteGuide: Bool {
        guard let firstShownAt = UserDefaults.standard.object(
            forKey: Keys.writeCardVoteGuideFirstShownAt
        ) as? Date else {
            return false
        }

        let week: TimeInterval = 60 * 60 * 24 * 7
        return Date().timeIntervalSince(firstShownAt) < week
    }
    
    // 메인 홈 > 최신카드, 공지 숨김 처리를 위한 flag
    static var shouldHideNotice: Bool { UserDefaults.standard.bool(forKey: Keys.shouldHideNotice) }
    // 공지 숨김 상태 업데이트
    static func hadHiddenNotice(_ flag: Bool) { UserDefaults.standard.set(flag, forKey: Keys.shouldHideNotice) }
    
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
