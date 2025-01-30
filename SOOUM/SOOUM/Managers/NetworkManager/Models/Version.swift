//
//  Version.swift
//  SOOUM
//
//  Created by 오현식 on 1/6/25.
//

import Foundation


struct Version {
    let currentVerion: String
}

extension Version {
    
    static var thisAppVersion: Self {
        .init(currentVerion: Info.appVersion)
    }
    
    /// AP앱이 최신버전인지 여부
    var isLatest: Bool {
        Self.thisAppVersion.currentVerion.compare(self.currentVerion, options: .numeric).rawValue >= 0
    }
    
    /// AP앱이 반드시 업데이트가 필요한지 여부
    var mustUpdate: Bool {
        Self.thisAppVersion.currentVerion.compare(self.currentVerion, options: .numeric).rawValue < 0
    }
  
    var shouldHideTransfer: Bool {
        Self.thisAppVersion.currentVerion.compare(self.currentVerion, options: .numeric).rawValue > 0
    }
}
