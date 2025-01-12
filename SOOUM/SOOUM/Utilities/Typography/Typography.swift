//
//  Typography.swift
//  SOOUM
//
//  Created by 오현식 on 9/9/24.
//

import UIKit


class Typography: NSObject, NSCopying {

    private(set) var fontContainer: FontConrainer
    private(set) var lineHeight: CGFloat
    private(set) var letterSpacing: CGFloat

    var font: UIFont {
        return self.fontContainer.font
    }

    var paragraphStyle: NSParagraphStyle {
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = self.lineHeight
        paragraph.maximumLineHeight = self.lineHeight
        return paragraph
    }

    var attributes: [NSAttributedString.Key: Any] {
        let fontLineHeight = self.font.lineHeight
        let lineHeight = self.lineHeight
        let adjustment: CGFloat = lineHeight > fontLineHeight ? 2.0 : 1.0
        let baselineOffset: CGFloat = (lineHeight - fontLineHeight) / 2.0 / adjustment
        return [
            .paragraphStyle: self.paragraphStyle,
            .kern: self.letterSpacing,
            .baselineOffset: baselineOffset
        ]
    }

    init(fontContainer: FontConrainer, lineHeight: CGFloat, letterSpacing: CGFloat = 0) {
        self.fontContainer = fontContainer
        self.lineHeight = lineHeight
        self.letterSpacing = letterSpacing
        super.init()
    }

    func withWeight(_ weight: UIFont.Weight) -> Self {
        let new = self.copy() as! Self
        new.fontContainer.weight = weight
        return new
    }

    func withSize(_ size: CGFloat) -> Self {
        let new = self.copy() as! Self
        new.fontContainer.size = size
        return new
    }

    func withLineHeight(_ lineHeight: CGFloat) -> Self {
        let new = self.copy() as! Self
        new.lineHeight = lineHeight
        return new
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let fontContainer = self.fontContainer.copy() as! FontConrainer
        return Typography(fontContainer: fontContainer, lineHeight: self.lineHeight)
    }
}

extension Typography {

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = (object as? Typography) else { return false }
        return (self.font == object.font) && (self.lineHeight == object.lineHeight)
    }
}
