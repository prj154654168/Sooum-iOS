//
//  SooumStyle.swift
//  SOOUM
//
//  Created by 오현식 on 9/7/24.
//

import Foundation


// MARK: Styles

public protocol SOOUMStyleCompatible {
    associatedtype SOOUMStyleBase
    static var som: SOOUMStyle<SOOUMStyleBase>.Type { get }
}

public struct SOOUMStyle<Base> { }

public extension SOOUMStyleCompatible {
    static var som: SOOUMStyle<Self>.Type { SOOUMStyle<Self>.self }
}


// MARK: V2

public struct V2Style<Base> { }

public extension SOOUMStyle {
    static var v2: V2Style<Base>.Type { V2Style<Base>.self }
}
