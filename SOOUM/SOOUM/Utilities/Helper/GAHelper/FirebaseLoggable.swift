//
//  FirebaseLoggable.swift
//  SOOUM
//
//  Created by JDeoks on 3/11/25.
//

/// Firebase에서 지원하는 데이터 타입만 준수하도록 제한
protocol FirebaseLoggable {
    var description: String { get }
}

extension String: FirebaseLoggable { var description: String { self } }
extension Int: FirebaseLoggable { var description: String { "\(self)" } }
extension Double: FirebaseLoggable { var description: String { "\(self)" } }
extension Bool: FirebaseLoggable { var description: String { "\(self)" } }
/// [String]만 허용
extension Array: FirebaseLoggable where Element == String {}
extension GAEvent.DetailView.ScreenPath: FirebaseLoggable { var description: String { self.rawValue } }
