//
//  SOMTagModel.swift
//  SOOUM
//
//  Created by 오현식 on 10/1/24.
//

import UIKit


class SOMTagModel {
    
    struct Configuration {
        var direction: UICollectionView.ScrollDirection = .horizontal
        
        var lineSpacing: CGFloat = 0
        var interSpacing: CGFloat = 0
        var inset: UIEdgeInsets = .zero
        
        static let horizontalWithoutRemove = Self(
            lineSpacing: 0,
            interSpacing: 10,
            inset: .init(top: 15, left: 20, bottom: 18, right: 0)
        )
        static let horizontalWithRemove = Self(
            lineSpacing: 0,
            interSpacing: 10,
            inset: .init(top: 12, left: 20, bottom: 16, right: 20)
        )
        static let verticalWithoutRemove = Self(
            direction: .vertical,
            lineSpacing: 12,
            interSpacing: 12,
            inset: .zero
        )
    }
    
    let id: String
    let originalText: String
    let count: String?
    let isRemovable: Bool
    let configuration: Configuration
    
    var identifier: AnyHashable {
        self.originalText
    }
    
    var text: String {
        let text = self.originalText
        return "#\(text)"
    }
    
    init(
        id: String,
        originalText: String,
        count: String? = nil,
        isRemovable: Bool,
        configuration: Configuration = .horizontalWithoutRemove
    ) {
        self.id = id
        self.originalText = originalText
        self.count = count
        self.isRemovable = isRemovable
        self.configuration = configuration
    }
}

extension SOMTagModel: Hashable {
    
    static func == (lhs: SOMTagModel, rhs: SOMTagModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
}

extension SOMTagModel {
    
    private static let typography: Typography = .som.body2WithRegular
    
    var tagSize: CGSize {
        
        let leadingOffset: CGFloat = self.configuration.direction == .horizontal ? 16 : 10
        
        let removeButtonWidth: CGFloat = self.isRemovable ? 16 + 8 : 0 /// 버튼 width + spacing
        
        let typography = Self.typography
        let textWidth: CGFloat = (self.text as NSString).size(
            withAttributes: [.font: typography.font]
        ).width
        
        var countWidth: CGFloat = 0 /// text width + spacing
        if let count = self.count {
            countWidth = (count as NSString).size(withAttributes: [.font: typography.font]).width
            countWidth += 2
        }
        
        let traillingOffset: CGFloat = self.configuration.direction == .horizontal ? 16 : 6
        
        let tagWidth: CGFloat = leadingOffset + removeButtonWidth + ceil(textWidth) + ceil(countWidth) + traillingOffset
        let tagHeight: CGFloat = self.configuration.direction == .horizontal ? 30 : 32
        return CGSize(width: tagWidth, height: tagHeight)
    }
}
