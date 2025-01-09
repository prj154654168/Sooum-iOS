//
//  CocoaLumberjack.swift
//  SOOUM
//
//  Created by 오현식 on 1/9/25.
//

import CocoaLumberjack

extension DDLog {

    static func logger<T: DDLogger>(_ loggerType: T.Type) -> T? {
        return self.allLoggers.first { type(of: $0) == loggerType } as? T
    }
}
