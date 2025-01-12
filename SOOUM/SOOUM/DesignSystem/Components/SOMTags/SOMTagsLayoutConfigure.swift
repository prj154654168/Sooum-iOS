//
//  SOMTagLayoutConfigure.swift
//  SOOUM
//
//  Created by 오현식 on 11/19/24.
//

import UIKit


struct SOMTagsLayoutConfigure {
    
    var direction: UICollectionView.ScrollDirection
    
    var lineSpacing: CGFloat = 0
    var interSpacing: CGFloat = 0
    var inset: UIEdgeInsets = .zero
    
    static var horizontalWithoutRemove = Self(
        direction: .horizontal,
        lineSpacing: 10,
        interSpacing: 10,
        inset: .init(top: 15, left: 20, bottom: 18, right: 0)
    )
    static var horizontalWithRemove = Self(
        direction: .horizontal,
        lineSpacing: 12,
        interSpacing: 12,
        inset: .init(top: 12, left: 20, bottom: 16, right: 20)
    )
    static var verticalWithoutRemove = Self(
        direction: .vertical,
        lineSpacing: 12,
        interSpacing: 12,
        inset: .zero
    )
}
