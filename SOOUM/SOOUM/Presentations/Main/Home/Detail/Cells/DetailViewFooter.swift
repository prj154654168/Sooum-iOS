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
        static let noContentText: String = "답카드가 아직 없어요"
    }
    
    let likeAndCommentView = LikeAndCommentView()
    
    let noContentBackgroundView = UIImageView()
    let noContentLabel = UILabel().then {
        $0.text = Text.noContentText
        $0.textColor = .som.gray400
        $0.textAlignment = .center
        $0.typography = .som.body1WithBold
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
    
    private var currentOffset: CGFloat = 0
    private var isLoadingMore: Bool = false
    
    let didTap = PublishRelay<String>()
    let moreDisplay = PublishRelay<String>()
    
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
            $0.backgroundColor = .som.gray200
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
        
        self.isLoadingMore = false
        
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
        if self.commentCards.count > 1 {
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionInset.left = 19
            layout.sectionInset.right = 19
        } else {
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            let cellWidthWithSpacing = cell.bounds.width + layout.minimumLineSpacing
            layout.sectionInset.left = (collectionView.bounds.width - cellWidthWithSpacing) * 0.5
            layout.sectionInset.right = (collectionView.bounds.width - cellWidthWithSpacing) * 0.5
        }
        
        guard self.commentCards.isEmpty == false else { return }
        
        let lastSectionIndex = collectionView.numberOfSections - 1
        let lastRowIndex = collectionView.numberOfItems(inSection: lastSectionIndex) - 1
        
        if self.isLoadingMore, indexPath.section == lastSectionIndex, indexPath.item == lastRowIndex {
            
            self.isLoadingMore = false
            
            let lastId = self.commentCards[indexPath.item].id
            self.moreDisplay.accept(lastId)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let height: CGFloat = collectionView.bounds.height
        return CGSize(width: height, height: height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.x
        
        // 아래로 스크롤 중일 때, 데이터 추가로드 가능
        self.isLoadingMore = offset > self.currentOffset
        self.currentOffset = offset
    }
}
