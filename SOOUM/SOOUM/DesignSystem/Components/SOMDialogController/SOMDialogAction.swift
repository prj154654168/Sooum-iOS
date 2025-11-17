//
//  SOMDialogAction.swift
//  SOOUM
//
//  Created by 오현식 on 1/18/25.
//

import UIKit


class SOMDialogAction {
    
    enum Style {
        case primary
        case red
        case gray
        
        var backgroundColor: UIColor {
            switch self {
            case .primary:
                return .som.v2.black
            case .red:
                return .som.v2.rMain
            case .gray:
                return .som.v2.gray100
            }
        }
        
        var foregroundColor: UIColor {
            switch self {
            case .primary, .red:
                return .som.v2.white
            case .gray:
                return .som.v2.gray600
            }
        }
    }
    
    typealias Action = () -> Void
    
    
    // MARK: Variables
    
    let tag: Int
    let title: String
    let style: Style
    let action: Action?
    
    
    // MARK: Initalization
    
    init(title: String, style: Style, action: Action? = nil) {
        self.tag = UUID().hashValue
        self.title = title
        self.style = style
        self.action = action
    }
}

extension SOMDialogAction: Equatable {
    
    static func == (lhs: SOMDialogAction, rhs: SOMDialogAction) -> Bool {
        return lhs.tag == rhs.tag
    }
}
