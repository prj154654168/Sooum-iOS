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
            case outlined(Outlined)
            case filled(Filled)
            
            enum Outlined: String {
                case addCard
                case alarm
                case arrowBack
                case arrowTop
                case camera
                case cancel
                case chatBubbleGrid
                case checkBox
                case checkBoxOn
                case clock
                case comment
                case commentAdd
                case hamburger
                case heart
                case home
                case location
                case more
                case plus
                case profile
                case radio
                case refresh
                case report
                case star
                case tag
                case trash
            }
            
            enum Filled: String {
                case addCard
                case alarm
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
            
            var imageName: String {
                switch self {
                case .outlined(let outlined):
                    return "\(outlined.rawValue)_outlined"
                case .filled(let filled):
                    return "\(filled.rawValue)_filled"
                }
            }
        }
        
        enum ImageStyle: String {
            case refreshControl
            case cancel
            case error
            case login
            case next
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
