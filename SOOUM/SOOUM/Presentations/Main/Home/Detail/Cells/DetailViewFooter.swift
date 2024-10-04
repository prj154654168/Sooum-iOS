//
//  DetailViewFooter.swift
//  SOOUM
//
//  Created by 오현식 on 10/3/24.
//

import UIKit

import SnapKit
import Then


class DetailViewFooter: UICollectionReusableView {
    
    let likeAndCommentView = LikeAndCommentView()
    
    private let flowLayout = UICollectionViewFlowLayout().then {
        $0.minimumLineSpacing = 8
        $0.scrollDirection = .horizontal
    }
    
    lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: self.flowLayout
    ).then {
        $0.alwaysBounceHorizontal = true
        $0.backgroundColor = .clear
        $0.indicatorStyle = .black
        
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        
        $0.register(DetailViewFooterCell.self, forCellWithReuseIdentifier: "cell")
        $0.dataSource = self
        $0.delegate = self
    }
    
    var commentCards = [Card]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let topSeperatorView = UIView().then {
            $0.backgroundColor = .som.gray03
        }
        
        self.addSubview(topSeperatorView)
        topSeperatorView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(0.4)
        }
        
        self.addSubview(self.likeAndCommentView)
        self.likeAndCommentView.snp.makeConstraints {
            $0.top.equalTo(topSeperatorView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        self.addSubviews(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.top.equalTo(self.likeAndCommentView.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    func setData(_ datas: [Card], like: Int, comment: Int) {
        self.commentCards = datas
        self.likeAndCommentView.likeCount = like
        self.likeAndCommentView.commentCount = comment
        
        self.collectionView.reloadData()
    }
}

extension DetailViewFooter: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        self.commentCards.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: DetailViewFooterCell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        as! DetailViewFooterCell
        
        let model: SOMCardModel = .init(
            data: self.commentCards[indexPath.row],
            isDetail: false,
            isComment: true
        )
        
        cell.setModel(model)
        
        return cell
    }
}

extension DetailViewFooter: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthWithSpacing = cell.bounds.width + layout.minimumLineSpacing
        collectionView.contentInset.left = (collectionView.bounds.width - cellWidthWithSpacing) * 0.5
        collectionView.contentInset.right = (collectionView.bounds.width - cellWidthWithSpacing) * 0.5
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let height: CGFloat = collectionView.bounds.height
        return CGSize(width: height, height: height)
    }
}
