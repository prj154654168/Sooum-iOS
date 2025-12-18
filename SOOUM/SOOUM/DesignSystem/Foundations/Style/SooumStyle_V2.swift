//
//  SooumStyle_V2.swift
//  SOOUM
//
//  Created by 오현식 on 9/16/25.
//

import Foundation


// MARK: V2

public struct V2Style<Base> { }

public extension SOOUMStyle {
    static var v2: V2Style<Base>.Type { V2Style<Base>.self }
}
