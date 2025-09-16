//
//  SooumStyle.swift
//  SOOUM
//
//  Created by 오현식 on 9/7/24.
//

import Foundation


// MARK: Styles

public struct SOOUMStyle<Base> { }

public protocol SOOUMStyleCompatible {
    associatedtype SOOUMStyleBase
    static var som: SOOUMStyle<SOOUMStyleBase>.Type { get }
}

public extension SOOUMStyleCompatible {
    static var som: SOOUMStyle<Self>.Type { SOOUMStyle<Self>.self }
}
