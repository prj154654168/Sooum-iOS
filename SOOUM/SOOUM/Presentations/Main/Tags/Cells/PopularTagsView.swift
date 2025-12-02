//
//  PopularTagsView.swift
//  SOOUM
//
//  Created by 오현식 on 11/20/25.
//

import UIKit

import SnapKit
import Then

import RxCocoa
import RxSwift

class PopularTagsView: UIView {
    
    enum Section: Int, CaseIterable {
        case main
    }
    
    enum Item: Hashable {
        case main(TagInfo)
    }
    
    
    // MARK: Views
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.scrollDirection = .vertical
            $0.minimumLineSpacing = 0
            $0.minimumInteritemSpacing = 0
            $0.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        }
    ).then {
        $0.backgroundColor = .clear
        
        $0.alwaysBounceVertical = true
        
        $0.contentInsetAdjustmentBehavior = .never
        $0.contentInset = .zero
        
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        
        $0.register(PopularTagViewCell.self, forCellWithReuseIdentifier: PopularTagViewCell.cellIdentifier)
        
        $0.delegate = self
    }
    
    
    // MARK: Variables
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private lazy var dataSource = DataSource(collectionView: self.collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
        
        switch item {
        case let .main(model):
            
            let cell: PopularTagViewCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PopularTagViewCell.cellIdentifier,
                for: indexPath
            ) as! PopularTagViewCell
            cell.setModel(model, with: indexPath.item + 1)
            
            return cell
        }
    }
    
    private(set) var models: [TagInfo]?
    
    private var collectionViewHeightConstraint: Constraint?
    
    let backgroundDidTap = PublishRelay<TagInfo>()
    
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            self.collectionViewHeightConstraint = $0.height.equalTo(0).constraint
        }
    }
    
    
    // MARK: Public func
    
    func setModels(_ models: [TagInfo]) {
        
        self.models = models
        
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        
        guard models.isEmpty == false else {
            snapshot.appendItems([], toSection: .main)
            self.dataSource.apply(snapshot, animatingDifferences: false)
            return
        }
        
        let items = models.map { Item.main($0) }
        snapshot.appendItems(items, toSection: .main)
        
        self.collectionViewHeightConstraint?.update(offset: 52 * CGFloat(models.count / 2))
        
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }
}


// MARK: UICollectionViewDelegateFlowLayout

extension PopularTagsView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return }
        
        if case let .main(model) = item {
            self.backgroundDidTap.accept(model)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return .zero }
        
        switch item {
        case .main:
            
            let width = (collectionView.bounds.width - 16 * 2) * 0.5
            return CGSize(width: width, height: 52)
        }
    }
}
