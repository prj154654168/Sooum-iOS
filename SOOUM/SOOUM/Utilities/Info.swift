//
//  Info.swift
//  SOOUM
//
//  Created by 오현식 on 1/6/25.
//

import Foundation


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
}
