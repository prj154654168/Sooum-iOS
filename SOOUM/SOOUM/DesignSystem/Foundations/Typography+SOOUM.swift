//
//  Typography+SOOUM.swift
//  SOOUM
//
//  Created by 오현식 on 9/10/24.
//

import UIKit


class Pretendard: FontConrainer {

    init(size fontSize: CGFloat, weight: UIFont.Weight) {
        let fontName = UIFont.pretendardFontName(with: weight)
        let font = UIFont(name: fontName, size: fontSize)!
        super.init(font)
    }

    override var weight: UIFont.Weight {
        set {
            self.font = .pretendardFont(ofSize: self.size, weight: newValue)
        }
        get {
            return super.weight
        }
    }

    override var size: CGFloat {
        set {
            self.font = .pretendardFont(ofSize: newValue, weight: self.weight)
        }
        get {
            return super.size
        }
    }

    override func copy(with zone: NSZone? = nil) -> Any {
        return Pretendard(size: self.size, weight: self.weight)
    }
}

fileprivate extension UIFont {

    static func pretendardFontName(with weight: Weight) -> String {
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
        return "PretendardVariable-\(weightName)"
    }

    static func pretendardFont(ofSize fontSize: CGFloat, weight: Weight) -> UIFont {
        let fontName = self.pretendardFontName(with: weight)
        return .init(name: fontName, size: fontSize)!
    }
}

// TODO: 추후 폰트의 size, weight, lineHeight가 정해지면 작성
extension Typography: SOOUMStyleCompatible { }
extension SOOUMStyle where Base == Typography { }
