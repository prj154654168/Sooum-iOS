//
//  Log.swift
//  SOOUM
//
//  Created by 오현식 on 1/9/25.
//

import CocoaLumberjack


final class Log {

    private static func message(flag: String, items: [Any], separator: String) -> String {
        return "\(flag): " + items.reduce("", { $0.isEmpty ? "\($1)" : "\($0)\(separator)\($1)" })
    }

    static func info(_ items: Any..., separator: String = " ") {
        let message = self.message(flag: "ℹ️ INFO", items: items, separator: separator)
        DDLogInfo(message)
    }

    static func debug(_ items: Any..., separator: String = " ") {
        let message = self.message(flag: "⚠️ DEBUG", items: items, separator: separator)
        DDLogDebug(message)
    }

    static func warning(_ items: Any..., separator: String = " ") {
        let message = self.message(flag: "❗️ WARNING", items: items, separator: separator)
        DDLogWarn(message)
    }

    static func error(_ items: Any..., separator: String = " ") {
        let message = self.message(flag: "🚨 ERROR", items: items, separator: separator)
        DDLogError(message)
    }

    static func request(_ items: Any..., separator: String = " ") {
        let message = self.message(flag: "🙋🏻 REQUEST", items: items, separator: separator)
        DDLogDebug(message)
    }

    static func complete(_ items: Any..., separator: String = " ") {
        let message = self.message(flag: "🙆🏻 COMPLETE", items: items, separator: separator)
        DDLogDebug(message)
    }

    static func fail(_ items: Any..., separator: String = " ") {
        let message = self.message(flag: "🙅🏻 FAIL", items: items, separator: separator)
        DDLogDebug(message)
    }
}
