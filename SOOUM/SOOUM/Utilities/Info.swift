//
//  Info.swift
//  SOOUM
//
//  Created by 오현식 on 1/6/25.
//

import UIKit

enum Info {
    
    static subscript<T>(key: String) -> T? {
        return Bundle.main.infoDictionary?[key] as? T
    }
    
    static var appId: String {
        return self["AppId"]!
    }
    
    static var appVersion: String {
        return self["CFBundleShortVersionString"]!
    }
    
    static var clarityId: String {
        return self["ClarityId"]!
    }
    
    static var iOSVersion: String {
        return UIDevice.current.systemVersion
    }
    
    static var deviceModel: String {
        return UIDevice.current.name
    }
}
