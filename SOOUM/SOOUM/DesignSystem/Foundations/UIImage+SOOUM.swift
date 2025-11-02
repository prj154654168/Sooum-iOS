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
        case logo(LogoStyle)
        
        enum IconStyle {
            case filled(Filled)
            case outlined(Outlined)
            case v2(V2IconStyle)
            
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
                case let .filled(filled):
                    return "\(filled.rawValue)_filled"
                case let .outlined(outlined):
                    return "\(outlined.rawValue)_outlined"
                case let .v2(iconStyle):
                    return "v2_\(iconStyle.imageName)"
                }
            }
        }
        
        enum ImageStyle {
            case defaultStyle(DefaultStyle)
            case v2(V2ImageStyle)
            
            enum DefaultStyle: String {
                case cancelTag
                case errorTriangle
                case login
                case sooumLogo
            }
            
            var imageName: String {
                switch self {
                case let .defaultStyle(defaultStyle):
                    return defaultStyle.rawValue
                case let .v2(imageStyle):
                    return "v2_\(imageStyle.rawValue)"
                }
            }
        }
        
        enum LogoStyle {
            case logo
            case v2(V2LogoStyle)
            
            var imageName: String {
                switch self {
                case .logo:
                    return "logo"
                case let .v2(logoStyle):
                    return "v2_\(logoStyle.rawValue)"
                }
            }
        }
        
        var imageName: String {
            switch self {
            case let .icon(iconStyle):
                return iconStyle.imageName
            case let .image(imageStyle):
                return imageStyle.imageName
            case let .logo(logoStyle):
                return logoStyle.imageName
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


// MARK: V2

extension UIImage.SOOUMType {
    
    enum V2IconStyle {
        case filled(Filled)
        case outlined(Outlined)
        
        enum Filled: String {
            case bell
            case bomb
            case camera
            case card
            case danger
            case headset
            case heart
            case home
            case image
            case info
            case location
            case lock
            case mail
            case message_circle
            case message_square
            case notice
            case official
            case settings
            case star
            case tag
            case time
            case tool
            case trash
            case user
            case users
            case write
        }
        
        enum Outlined: String {
            case bell
            case camera
            case check
            case danger
            case delete
            case down
            case error
            case flag
            case hash
            case heart
            case hide
            case home
            case image
            case left
            case location
            case message_circle
            case message_square
            case more
            case plus
            case right
            case search
            case settings
            case star
            case swap
            case tag
            case time
            case trash
            case up
            case user
            case write
        }
        
        var imageName: String {
            switch self {
            case let .filled(filled):
                return "\(filled.rawValue)_filled"
            case let .outlined(outlined):
                return "\(outlined.rawValue)_outlined"
            }
        }
    }
    
    enum V2ImageStyle: String {
        case onboarding
        case onboarding_finish
        case check_square_light
        case detail_delete_card
        case placeholder_home
        case placeholder_notification
        case prev_card_button
        case profile_large
        case profile_small
    }
    
    enum V2LogoStyle: String {
        case logo_white
        case logo_black
    }
}
