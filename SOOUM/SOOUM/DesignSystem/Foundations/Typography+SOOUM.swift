//
//  Typography+SOOUM.swift
//  SOOUM
//
//  Created by 오현식 on 9/10/24.
//

import UIKit


class BuiltInFont: FontConrainer {
    
    enum FontType: String {
        case pretendard = "PretendardVariable"
        case school = "Hakgyoansim"
    }
    
    var type: FontType

    init(_ type: FontType = .pretendard, size fontSize: CGFloat, weight: UIFont.Weight) {
        self.type = type
        let fontName = UIFont.builtInFontName(type.rawValue, with: weight)
        let font = UIFont(name: fontName, size: fontSize)!
        super.init(font)
    }

    override var weight: UIFont.Weight {
        set {
            self.font = .builtInFont(self.type.rawValue, ofSize: self.size, weight: newValue)
        }
        get {
            return super.weight
        }
    }

    override var size: CGFloat {
        set {
            self.font = .builtInFont(self.type.rawValue, ofSize: newValue, weight: self.weight)
        }
        get {
            return super.size
        }
    }

    override func copy(with zone: NSZone? = nil) -> Any {
        return BuiltInFont(size: self.size, weight: self.weight)
    }
}

fileprivate extension UIFont {

    static func builtInFontName(_ name: String, with weight: Weight) -> String {
        let weightName: String = {
            switch weight {
            case .thin: return "Thin"
            case .ultraLight: return "ExtraLight"
            case .light: return "Light"
            case .medium: return "Medium"
            case .semibold: return "SemiBold"
            case .bold: return "Bold"
            case .heavy: return "ExtraBold"
            case .black: return "Black"
            default: return "Regular"
            }
        }()
        return "\(name)-\(weightName)"
    }

    static func builtInFont(_ name: String, ofSize fontSize: CGFloat, weight: Weight) -> UIFont {
        let fontName = self.builtInFontName(name, with: weight)
        return .init(name: fontName, size: fontSize)!
    }
}

extension Typography: SOOUMStyleCompatible { }
extension SOOUMStyle where Base == Typography {
    
    static var head1WithBold: Typography = .init(
        fontContainer: BuiltInFont(size: 22, weight: .semibold),
        lineHeight: 23,
        letterSpacing: -0.003
    )
    static var head1WithRegular: Typography = .init(
        fontContainer: BuiltInFont(size: 22, weight: .medium),
        lineHeight: 28,
        letterSpacing: -0.003
    )
    
    static var head2WithBold: Typography = .init(
        fontContainer: BuiltInFont(size: 18, weight: .semibold),
        lineHeight: 24,
        letterSpacing: -0.003
    )
    static var head2WithRegular: Typography = .init(
        fontContainer: BuiltInFont(size: 18, weight: .regular),
        lineHeight: 24,
        letterSpacing: -0.003
    )
    
    static var body1WithBold: Typography = .init(
        fontContainer: BuiltInFont(size: 16, weight: .semibold),
        lineHeight: 24,
        letterSpacing: -0.004
    )
    static var body1WithRegular: Typography = .init(
        fontContainer: BuiltInFont(size: 16, weight: .regular),
        lineHeight: 24,
        letterSpacing: -0.004
    )
    
    static var body2WithBold: Typography = .init(
        fontContainer: BuiltInFont(size: 14, weight: .medium),
        lineHeight: 20,
        letterSpacing: -0.004
    )
    static var body2WithRegular: Typography = .init(
        fontContainer: BuiltInFont(size: 14, weight: .regular),
        lineHeight: 20,
        letterSpacing: -0.004
    )
    
    static var body3WithBold: Typography = .init(
        fontContainer: BuiltInFont(size: 12, weight: .medium),
        lineHeight: 17,
        letterSpacing: -0.004
    )
    static var body3WithRegular: Typography = .init(
        fontContainer: BuiltInFont(size: 12, weight: .regular),
        lineHeight: 17,
        letterSpacing: -0.004
    )
    
    static var caption: Typography = .init(
        fontContainer: BuiltInFont(size: 10, weight: .medium),
        lineHeight: 14,
        letterSpacing: -0.004
    )
}
