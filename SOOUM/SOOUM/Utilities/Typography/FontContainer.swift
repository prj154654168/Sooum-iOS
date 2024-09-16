//
//  FontContainer.swift
//  SOOUM
//
//  Created by 오현식 on 9/10/24.
//

import UIKit


class FontConrainer: NSObject, NSCopying {

    var font: UIFont

    init(_ font: UIFont) {
        self.font = font
        super.init()
    }

    var weight: UIFont.Weight {
        set {
            self.font = .systemFont(ofSize: self.size, weight: newValue)
        }
        get {
            guard let traits = self.font.fontDescriptor.object(forKey: .traits) as? [
                UIFontDescriptor.TraitKey:
                    Any
            ],
                let rawWeight = traits[.weight] as? CGFloat
            else {
                return .regular
            }
            return .init(rawWeight)
        }
    }

    var size: CGFloat {
        set {
            self.font = .systemFont(ofSize: newValue, weight: self.weight)
        }
        get {
            return self.font.pointSize
        }
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let font = self.font.copy(with: zone) as! UIFont
        return FontConrainer(font)
    }
}

extension FontConrainer {

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = (object as? FontConrainer) else { return false }
        return self.font == object.font
    }
}
