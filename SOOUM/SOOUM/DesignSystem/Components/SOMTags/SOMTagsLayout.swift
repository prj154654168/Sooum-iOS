//
//  SOMTagsLayout.swift
//  SOOUM
//
//  Created by 오현식 on 10/19/24.
//

import UIKit


class SOMTagsLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }

        // 수직 방향일 경우, 좌측으로 정렬
        if self.scrollDirection == .vertical {

            var leadingOffset: CGFloat = self.sectionInset.left
            var maxY: CGFloat = -1.0
            
            attributes.forEach { attribute in
                if attribute.representedElementCategory == .cell {

                    if attribute.frame.minY >= maxY {
                        leadingOffset = self.sectionInset.left
                    }
                    attribute.frame.origin.x = leadingOffset

                    leadingOffset += attribute.frame.width + self.minimumInteritemSpacing
                    maxY = attribute.frame.maxY
                }
            }
        }

        return attributes
    }
}
