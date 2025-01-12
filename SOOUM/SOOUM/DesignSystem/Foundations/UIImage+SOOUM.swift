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
        case image(ImageStyle)
        case logo
        
        enum IconStyle {
            case filled(Filled)
            case outlined(Outlined)
            
            enum Filled: String {
                case addCard
                case alarm
                case checkBox
                case clock
                case comment
                case heart
                case home
                case location
                case profile
                case radio
                case star
                case tag
            }
            
            enum Outlined: String {
                case addCard
                case alarm
                case arrowBack
                case arrowTop
                case camera
                case cancel
                case check
                case checkBox
                case clock
                case comment
                case commentAdd
                case heart
                case home
                case location
                case menu
                case more
                case next
                case plus
                case profile
                case radio
                case refresh
                case report
                case search
                case star
                case tag
                case trash
            }
            
            var imageName: String {
                switch self {
                case .filled(let filled):
                    return "\(filled.rawValue)_filled"
                case .outlined(let outlined):
                    return "\(outlined.rawValue)_outlined"
                }
            }
        }
        
        enum ImageStyle: String {
            case cancelTag
            case errorTriangle
            case login
            case sooumLogo
        }
        
        var imageName: String {
            switch self {
            case .icon(let iconStyle):
                return iconStyle.imageName
            case .image(let imageStyle):
                return imageStyle.rawValue
            case .logo:
                return "logo"
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
