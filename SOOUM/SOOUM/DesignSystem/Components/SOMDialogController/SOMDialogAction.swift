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
        case gray
        
        var backgroundColor: UIColor {
            switch self {
            case .primary:
                return .som.p300
            case .gray:
                return .som.gray300
            }
        }
        
        var foregroundColor: UIColor {
            switch self {
            case .primary:
                return .som.white
            case .gray:
                return .som.gray700
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
