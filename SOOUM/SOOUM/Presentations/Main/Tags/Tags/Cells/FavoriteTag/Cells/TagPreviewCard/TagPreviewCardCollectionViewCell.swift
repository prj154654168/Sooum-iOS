//
//  TagPreviewCardCollectionViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 11/26/24.
//

import UIKit

import RxCocoa
import RxGesture
import RxSwift

class TagPreviewCardCollectionViewCell: UICollectionViewCell {
    
    var disposeBag = DisposeBag()
    
    let tagPreviewCardView = TagPreviewCardView()
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.disposeBag = DisposeBag()
    }
    
    func setData(previewCard: FavoriteTagsResponse.PreviewCard) {
        tagPreviewCardView.rootContainerImageView.setImage(strUrl: previewCard.backgroundImgURL.href, with: "")
        tagPreviewCardView.cardTextContentLabel.text = previewCard.content
    }
    
    private func setupConstraint() {
        self.contentView.addSubview(tagPreviewCardView)
        tagPreviewCardView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
