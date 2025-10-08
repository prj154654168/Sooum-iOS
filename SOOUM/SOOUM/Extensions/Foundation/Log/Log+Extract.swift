//
//  Log+Extract.swift
//  SOOUM
//
//  Created by 오현식 on 1/9/25.
//

import CocoaLumberjack
import RxSwift
import UIKit


extension Log {

    class func extract() -> Single<UIViewController> {
        return .create { observer -> Disposable in

            let identifier: String = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? "Identifier not found"

            if let fileLogger = DDLog.logger(DDFileLogger.self) {

                let filePaths: [String] = fileLogger.logFileManager.sortedLogFilePaths

                if let latesFilePath = filePaths.last {
                    let fileUrls: [URL] = [URL(fileURLWithPath: latesFilePath)]
                    let viewController = UIActivityViewController(
                        activityItems: fileUrls,
                        applicationActivities: nil
                    )
                    observer(.success(viewController))
                } else {
                    let error = NSError(
                        domain: "\(identifier):Log",
                        code: -999,
                        userInfo: [NSLocalizedDescriptionKey: "기록된 로그가 없습니다."]
                    )
                    observer(.failure(error))
                }
            } else {

                let error = NSError(
                    domain: "\(identifier):Log",
                    code: -999,
                    userInfo: [NSLocalizedDescriptionKey: "파일 로거를 사용할 수 없습니다."]
                )
                observer(.failure(error))
            }

            return Disposables.create()
        }
    }
}
