//
//  SOMTagModel.swift
//  SOOUM
//
//  Created by 오현식 on 10/1/24.
//

import Foundation


class SOMTagModel {
    
    let id: String
    let originalText: String
    
    var text: String {
        let text = self.originalText
        return "#\(text)"
    }
    
    init(id: String, originalText: String) {
        self.id = id
        self.originalText = originalText
    }
}

extension SOMTagModel: Hashable {
    
    static func == (lhs: SOMTagModel, rhs: SOMTagModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension SOMTagModel {
    
    private static let textTypography: Typography = .init(
        fontContainer: Pretendard(size: 14, weight: .medium),
        lineHeight: 22,
        letterSpacing: -0.04
    )
    
    var tagSize: CGSize {
        
        let leadingAndTrailingOffset: CGFloat = 16
        
        let textWidth: CGFloat = (self.text as NSString).boundingRect(
            with: .init(width: .infinity, height: Self.textTypography.lineHeight),
            options: .usesLineFragmentOrigin,
            attributes: [.font: Self.textTypography.font],
            context: nil
        ).width
        
        let tagWidth: CGFloat = leadingAndTrailingOffset * 2 + ceil(textWidth)
        return CGSize(width: tagWidth, height: 30)
    }
}
