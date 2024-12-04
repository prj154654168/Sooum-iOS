//
//  FavoriteTagCell.swift
//  SOOUM
//
//  Created by JDeoks on 11/24/24.
//

import UIKit

import RxCocoa
import RxGesture
import RxSwift

final class FavoriteTagTableViewCell: UITableViewCell {
    
    var favoriteTag: FavoriteTagsResponse.FavoriteTagList? = nil
    
    lazy var favoriteTagView = FavoriteTagView().then {
        $0.cardPreviewCollectionView.delegate = self
        $0.cardPreviewCollectionView.dataSource = self
        $0.cardPreviewCollectionView.register(
            TagPreviewCardCollectionViewCell.self,
            forCellWithReuseIdentifier: String(
                describing: TagPreviewCardCollectionViewCell.self
            )
        )
    }
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.clipsToBounds = true
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(favoriteTag: FavoriteTagsResponse.FavoriteTagList) {
        self.favoriteTag = favoriteTag
        self.favoriteTagView.tagNameLabel.text = favoriteTag.tagContent
        self.favoriteTagView.tagsCountLabel.text = favoriteTag.tagUsageCnt
    }
    
    private func setupConstraint() {
        self.contentView.addSubview(favoriteTagView)
        favoriteTagView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
}

extension FavoriteTagTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(
            describing: TagPreviewCardCollectionViewCell.self
        ), for: indexPath)
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let height = favoriteTagView.cardPreviewCollectionView.frame.height
        return CGSize(width: height, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
}
