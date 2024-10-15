//
//  DetailViewFooter.swift
//  SOOUM
//
//  Created by 오현식 on 10/3/24.
//

import UIKit

import RxCocoa
import RxSwift

import SnapKit
import Then


class DetailViewFooter: UICollectionReusableView {
    
    enum Text {
        static let noContentText: String = "댓글이 아직 없어요"
    }
    
    let likeAndCommentView = LikeAndCommentView()
    
    let noContentBackgroundView = UIImageView()
    let noContentLabel = UILabel().then {
        $0.text = Text.noContentText
        $0.textColor = .som.gray02
        $0.textAlignment = .center
        $0.typography = .init(
            fontContainer: Pretendard(size: 16, weight: .semibold),
            lineHeight: 26,
            letterSpacing: -0.04
        )
    }
    
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
        
        $0.decelerationRate = .fast
        
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        
        $0.register(DetailViewFooterCell.self, forCellWithReuseIdentifier: "cell")
        $0.dataSource = self
        $0.delegate = self
    }
    
    var commentCards = [Card]()
    
    let didTap = PublishRelay<String>()
    
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
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
        
        self.addSubviews(self.noContentBackgroundView)
        self.noContentBackgroundView.snp.makeConstraints {
            $0.top.equalTo(self.likeAndCommentView.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
        }
        self.noContentBackgroundView.addSubview(self.noContentLabel)
        self.noContentLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func setDatas(_ datas: [Card], cardSummary: CardSummary) {
        self.commentCards = datas
        self.likeAndCommentView.likeCount = cardSummary.cardLikeCnt
        self.likeAndCommentView.commentCount = cardSummary.commentCnt
        self.likeAndCommentView.isLikeSelected = cardSummary.isLiked
        
        self.collectionView.isHidden = datas.isEmpty
        self.noContentBackgroundView.isHidden = !datas.isEmpty
        
        if !datas.isEmpty {
            self.collectionView.reloadData()
        }
    }
}

extension DetailViewFooter: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return self.commentCards.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: DetailViewFooterCell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        as! DetailViewFooterCell
        
        let commentCard = self.commentCards[indexPath.row]
        let model: SOMCardModel = .init(data: commentCard)
        cell.setModel(model)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedId = self.commentCards[indexPath.row].id
        self.didTap.accept(selectedId)
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
        layout.sectionInset.left = (collectionView.bounds.width - cellWidthWithSpacing) * 0.5
        layout.sectionInset.right = (collectionView.bounds.width - cellWidthWithSpacing) * 0.5
    }
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = self.collectionView.bounds.height + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        var roundedIndex = round(index)
        
        if velocity.x > 0 {
            roundedIndex = floor(roundedIndex) + 1
        } else if velocity.x < 0 {
            roundedIndex = ceil(roundedIndex) - 1
        } else {
            roundedIndex = round(roundedIndex)
        }
        roundedIndex = max(
            0,
            min(roundedIndex, CGFloat(self.collectionView.numberOfItems(inSection: 0) - 1))
        )
        
        offset = CGPoint(
            x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left,
            y: scrollView.contentInset.top
        )
        targetContentOffset.pointee = offset
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
