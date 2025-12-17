//
//  FirebaseLoggable.swift
//  SOOUM
//
//  Created by JDeoks on 3/11/25.
//

/// Firebase에서 지원하는 데이터 타입만 준수하도록 제한
protocol FirebaseLoggable {}

extension String: FirebaseLoggable {}
extension Int: FirebaseLoggable {}
extension Double: FirebaseLoggable {}
extension Bool: FirebaseLoggable {}
/// [String]만 허용
extension Array: FirebaseLoggable where Element == String {}
