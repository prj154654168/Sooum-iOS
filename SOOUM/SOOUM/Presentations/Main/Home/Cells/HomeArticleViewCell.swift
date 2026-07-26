//
//  HomeArticleViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 1/31/26.
//

import UIKit

import SnapKit
import Then

final class HomeArticleViewCell: UITableViewCell {
    
    private enum Metric {
        static let containerHorizontalInset: CGFloat = 16
        static let containerTopInset: CGFloat = 16
        static let sectionBottomSpacing: CGFloat = 10
        static let containerBottomInset: CGFloat = 16
        static let cellBottomInset: CGFloat = 10
        static let cardWidth: CGFloat = 230
        static let minimumCardHeight: CGFloat = 48
        static let cardSpacing: CGFloat = 10
        static let rightGradientWidth: CGFloat = 20
    }
    
    static let cellIdentifier = String(reflecting: HomeArticleViewCell.self)
    
    enum Text {
        static let sectionTitle: String = "숨터"
        static let noCommentCardMessage: String = "첫 댓글을 남겨보세요"
        static let commentCardTrailingMessage: String = "명이 카드를 남겼어요"
    }
    
    
    // MARK: Views
    
    private lazy var shadowbackgroundView = UIView().then {
        $0.backgroundColor = .som.v2.white
        $0.layer.cornerRadius = 16
    }
    
    private let sectionTitleLabel = UILabel().then {
        $0.text = Text.sectionTitle
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.caption1.withAlignment(.left)
    }
    
    private let flowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = Metric.cardSpacing
        $0.minimumInteritemSpacing = Metric.cardSpacing
        $0.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: self.flowLayout
    ).then {
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = false
        $0.dataSource = self
        $0.delegate = self
        $0.register(
            ArticlePreviewCollectionCell.self,
            forCellWithReuseIdentifier: ArticlePreviewCollectionCell.cellIdentifier
        )
    }
    
    private let rightGradientView = LinearGradientView().then {
        $0.isHidden = false
        $0.configuration = .init(
            stops: [
                .init(color: .som.v2.white.withAlphaComponent(0.0), location: 0.0),
                .init(color: .som.v2.white.withAlphaComponent(1.0), location: 1.0)
            ],
            direction: .leftToRight
        )
    }
    
    
    // MARK: Variables
    
    private(set) var models: [ArticleCardInfo] = []
    var onSelectArticle: ((ArticleCardInfo) -> Void)?
    
    
    // MARK: Constraint
    
    private var collectionHeightConstraint: Constraint?
    
    
    // MARK: Initialize
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Override func
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.models = []
        self.onSelectArticle = nil
        self.collectionView.setContentOffset(.zero, animated: false)
        self.collectionHeightConstraint?.update(offset: Metric.minimumCardHeight)
        self.collectionView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.shadowbackgroundView.setShadow(
            radius: 6,
            color: UIColor(hex: "#ABBED11A").withAlphaComponent(0.1),
            blur: 16,
            offset: .init(width: 0, height: 6)
        )
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.shadowbackgroundView)
        self.shadowbackgroundView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-Metric.cellBottomInset)
            $0.leading.equalToSuperview().offset(Metric.containerHorizontalInset)
            $0.trailing.equalToSuperview().offset(-Metric.containerHorizontalInset)
        }
        
        self.shadowbackgroundView.addSubview(self.sectionTitleLabel)
        self.sectionTitleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(Metric.containerTopInset)
            $0.trailing.lessThanOrEqualToSuperview().offset(-Metric.containerTopInset)
        }
        
        self.shadowbackgroundView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.top.equalTo(self.sectionTitleLabel.snp.bottom).offset(Metric.sectionBottomSpacing)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-Metric.containerBottomInset)
            self.collectionHeightConstraint = $0.height.equalTo(Metric.minimumCardHeight).constraint
        }
        
        self.shadowbackgroundView.addSubview(self.rightGradientView)
        self.rightGradientView.snp.makeConstraints {
            $0.top.bottom.equalTo(self.collectionView)
            $0.trailing.equalTo(self.collectionView.snp.trailing)
            $0.width.equalTo(Metric.rightGradientWidth)
        }
    }
    
    
    // MARK: Public func
    
    func bind(_ models: [ArticleCardInfo]) {
        
        self.models = models
        
        let maxCardHeight = models
            .map { ArticlePreviewCollectionCell.preferredHeight(for: $0, width: Metric.cardWidth) }
            .max() ?? Metric.minimumCardHeight
        self.collectionHeightConstraint?.update(offset: maxCardHeight)
        
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension HomeArticleViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.models.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ArticlePreviewCollectionCell.cellIdentifier,
            for: indexPath
        ) as! ArticlePreviewCollectionCell
        cell.bind(self.models[indexPath.item])
        return cell
    }
}

extension HomeArticleViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.models.indices.contains(indexPath.item) else { return }
        self.onSelectArticle?(self.models[indexPath.item])
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        guard self.models.indices.contains(indexPath.item) else {
            return CGSize(width: Metric.cardWidth, height: Metric.minimumCardHeight)
        }
        
        let model = self.models[indexPath.item]
        return CGSize(
            width: Metric.cardWidth,
            height: ArticlePreviewCollectionCell.preferredHeight(for: model, width: Metric.cardWidth)
        )
    }
}
