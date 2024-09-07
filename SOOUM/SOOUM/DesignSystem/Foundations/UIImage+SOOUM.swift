//
//  UIImage+SOOUM.swift
//  SOOUM
//
//  Created by 오현식 on 9/8/24.
//

import UIKit

extension UIImage {
    
    enum SOOUMType: Equatable {
        case icon(IconStyle)
        
        enum IconStyle {
            case outlined(Outlined)
            
            enum Outlined: String {
                case add_card
                case alarm
                case chat_bubble_grid
                case clock
                case comment
                case heart
                case home
                case location
                case profile
                case star
                case tag
            }
            
            var imageName: String {
                switch self {
                case .outlined(let outlined):
                    return "\(outlined.rawValue)_outlined"
                }
            }
        }
        
        var imageName: String {
            switch self {
            case .icon(let iconStyle):
                return iconStyle.imageName
            }
        }
        
        static func == (lhs: UIImage.SOOUMType, rhs: UIImage.SOOUMType) -> Bool {
            return (lhs.imageName == rhs.imageName)
        }
    }
    
    convenience init?(_ som: SOOUMType) {
        self.init(named: som.imageName)
    }
}
