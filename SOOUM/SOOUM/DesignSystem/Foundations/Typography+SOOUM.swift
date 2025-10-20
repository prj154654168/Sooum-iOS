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
        case yoonwoo = "OwnglyphYoonwooChae"
        case ridi = "RIDIBatang"
        case kkookkkook = "MemomentKkukkukkR"
    }
    
    var type: FontType

    init(type fontType: FontType = .pretendard, size fontSize: CGFloat, weight: UIFont.Weight) {
        self.type = fontType
        let fontName = UIFont.builtInFontName(type: type, with: weight)
        let font = UIFont(name: fontName, size: fontSize)!
        super.init(font)
    }

    override var weight: UIFont.Weight {
        set {
            self.font = .builtInFont(type: self.type, ofSize: self.size, weight: newValue)
        }
        get {
            return super.weight
        }
    }

    override var size: CGFloat {
        set {
            self.font = .builtInFont(type: self.type, ofSize: newValue, weight: self.weight)
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

    static func builtInFontName(type fontType: BuiltInFont.FontType, with weight: Weight) -> String {
        if case .pretendard = fontType {
            let weightName: String = {
                switch weight {
                case .thin:         return "Thin"
                case .ultraLight:   return "ExtraLight"
                case .light:        return "Light"
                case .medium:       return "Medium"
                case .semibold:     return "SemiBold"
                case .bold:         return "Bold"
                case .heavy:        return "ExtraBold"
                case .black:        return "Black"
                default:            return "Regular"
                }
            }()
            return "\(fontType.rawValue)-\(weightName)"
        } else {
            return "\(fontType.rawValue)"
        }
    }

    static func builtInFont(type fontType: BuiltInFont.FontType, ofSize fontSize: CGFloat, weight: Weight) -> UIFont {
        let fontName = self.builtInFontName(type: fontType, with: weight)
        return .init(name: fontName, size: fontSize)!
    }
}

extension Typography: SOOUMStyleCompatible { }
extension SOOUMStyle where Base == Typography {
    
    
    // MARK: v1
    
    // Pretendard
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
    
    // shcool
    
    // static var schoolBody1WithBold: Typography = .init(
    //     fontContainer: BuiltInFont(type: .school, size: 18, weight: .bold),
    //     lineHeight: 25,
    //     letterSpacing: -0.004
    // )
    
    // static var schoolBody1WithLight: Typography = .init(
    //     fontContainer: BuiltInFont(type: .school, size: 18, weight: .light),
    //     lineHeight: 25,
    //     letterSpacing: -0.004
    // )
}

extension V2Style where Base == Typography {
    
    
    // MARK: v2
    
    // Pretandard
    /// Size: 28, Line height: 39
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var head1: Typography = .init(
        fontContainer: BuiltInFont(size: 28, weight: .bold),
        lineHeight: 39,
        letterSpacing: -0.025
    )
    /// Size: 24, Line height: 34
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var head2: Typography = .init(
        fontContainer: BuiltInFont(size: 24, weight: .bold),
        lineHeight: 34,
        letterSpacing: -0.025
    )
    /// Size: 20, Line height: 28
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var head3: Typography = .init(
        fontContainer: BuiltInFont(size: 20, weight: .bold),
        lineHeight: 28,
        letterSpacing: -0.025
    )
    /// Size: 18, Line height: 27
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var title1: Typography = .init(
        fontContainer: BuiltInFont(size: 18, weight: .semibold),
        lineHeight: 27,
        letterSpacing: -0.025
    )
    /// Size: 16, Line height: 24
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var title2: Typography = .init(
        fontContainer: BuiltInFont(size: 16, weight: .semibold),
        lineHeight: 24,
        letterSpacing: -0.025
    )
    /// Size: 16, Line height: 24
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var subtitle1: Typography = .init(
        fontContainer: BuiltInFont(size: 16, weight: .medium),
        lineHeight: 24,
        letterSpacing: -0.025
    )
    /// Size: 14, Line height: 21
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var subtitle2: Typography = .init(
        fontContainer: BuiltInFont(size: 14, weight: .bold),
        lineHeight: 21,
        letterSpacing: -0.025
    )
    /// Size: 14, Line height: 21
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var subtitle3: Typography = .init(
        fontContainer: BuiltInFont(size: 14, weight: .semibold),
        lineHeight: 21,
        letterSpacing: -0.025
    )
    /// Size: 14, Line height: 21
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var body1: Typography = .init(
        fontContainer: BuiltInFont(size: 14, weight: .medium),
        lineHeight: 21,
        letterSpacing: -0.025
    )
    /// Size: 14, Line height: 21
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var body2: Typography = .init(
        fontContainer: BuiltInFont(size: 14, weight: .regular),
        lineHeight: 21,
        letterSpacing: -0.025
    )
    /// Size: 12, Line height: 18
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var caption1: Typography = .init(
        fontContainer: BuiltInFont(size: 12, weight: .semibold),
        lineHeight: 18,
        letterSpacing: -0.025
    )
    /// Size: 12, Line height: 18
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var caption2: Typography = .init(
        fontContainer: BuiltInFont(size: 12, weight: .medium),
        lineHeight: 18,
        letterSpacing: -0.025
    )
    /// Size: 10, Line height: 15
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var caption3: Typography = .init(
        fontContainer: BuiltInFont(size: 10, weight: .medium),
        lineHeight: 15,
        letterSpacing: -0.025
    )
    
    
    // RIDIBatang
    /// Size: 15, Line height: 23
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var ridiButton: Typography = .init(
        fontContainer: BuiltInFont(type: .ridi, size: 15, weight: .regular),
        lineHeight: 23,
        letterSpacing: -0.025
    )
    /// Size: 13, Line height: 20
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var ridiCard: Typography = .init(
        fontContainer: BuiltInFont(type: .ridi, size: 13, weight: .regular),
        lineHeight: 20,
        letterSpacing: -0.025
    )
    /// Size: 11, Line height: 17
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var ridiTag: Typography = .init(
        fontContainer: BuiltInFont(type: .ridi, size: 11, weight: .regular),
        lineHeight: 17,
        letterSpacing: -0.025
    )
    
    // Yoonwoo
    /// Size: 20, Line height: 22
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var yoonwooButton: Typography = .init(
        fontContainer: BuiltInFont(type: .yoonwoo, size: 20, weight: .regular),
        lineHeight: 22,
        letterSpacing: 0
    )
    /// Size: 18, Line height: 20
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var yoonwooCard: Typography = .init(
        fontContainer: BuiltInFont(type: .yoonwoo, size: 18, weight: .regular),
        lineHeight: 20,
        letterSpacing: 0
    )
    /// Size: 16, Line height: 18
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var yoonwooTag: Typography = .init(
        fontContainer: BuiltInFont(type: .yoonwoo, size: 16, weight: .regular),
        lineHeight: 18,
        letterSpacing: -0.025
    )
    
    // Kkukkukk
    /// Size: 16, Line height: 22
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var kkookkkookButton: Typography = .init(
        fontContainer: BuiltInFont(type: .kkookkkook, size: 16, weight: .regular),
        lineHeight: 22,
        letterSpacing: 0
    )
    /// Size: 14, Line height: 20
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var kkookkkookCard: Typography = .init(
        fontContainer: BuiltInFont(type: .kkookkkook, size: 14, weight: .regular),
        lineHeight: 20,
        letterSpacing: 0
    )
    /// Size: 12, Line height: 17
    ///
    /// Weight: [Thin: 100, UltraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, Heavy: 800, Black: 900]
    static var kkookkkookTag: Typography = .init(
        fontContainer: BuiltInFont(type: .kkookkkook, size: 12, weight: .regular),
        lineHeight: 17,
        letterSpacing: -0.025
    )
}
