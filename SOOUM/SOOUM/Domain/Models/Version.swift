//
//  Version.swift
//  SOOUM
//
//  Created by 오현식 on 1/6/25.
//

import Foundation

struct Version: Equatable {
    
    let currentVersionStatus: Status
    let latestVersion: String
}

extension Version {
    
    init(status: String, latest: String) {
        self.currentVersionStatus = Status(rawValue: status) ?? .NONE
        self.latestVersion = latest
    }
    
    static var defaultValue: Version = Version(status: "NONE", latest: "1.0.0")
}

extension Version {
    
    static var thisAppVersion: String {
        return Info.appVersion
    }
    
    enum Status: String {
        case PENDING
        case UPDATE
        case OK
        case NONE
    }
    
    /// AP앱이 최신버전인지 여부
    var isLatest: Bool {
        self.currentVersionStatus == .OK
    }
    
    /// AP앱이 반드시 업데이트가 필요한지 여부
    var mustUpdate: Bool {
        self.currentVersionStatus == .UPDATE
    }
  
    var shouldHideTransfer: Bool {
        self.currentVersionStatus == .PENDING
    }
}

extension Version.Status: Decodable { }
extension Version: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case currentVersionStatus = "status"
        case latestVersion
    }
}
