//
//  TagPreviewCardCollectionViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 11/26/24.
//

import UIKit

class TagPreviewCardCollectionViewCell: UICollectionViewCell {
    
    let tagPreviewCardView = TagPreviewCardView()
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraint() {
        self.contentView.addSubview(tagPreviewCardView)
        tagPreviewCardView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}