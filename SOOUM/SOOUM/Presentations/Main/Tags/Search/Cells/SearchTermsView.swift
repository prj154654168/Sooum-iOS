//
//  SearchTermsView.swift
//  SOOUM
//
//  Created by 오현식 on 11/22/25.
//

import UIKit

import SnapKit
import Then

import RxCocoa
import RxSwift

class SearchTermsView: UIView {
    
    enum Section: Int, CaseIterable {
        case main
        case empty
    }
    
    enum Item: Hashable {
        case main(TagInfo)
        case empty
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
        
        $0.register(SearchTermViewCell.self, forCellWithReuseIdentifier: SearchTermViewCell.cellIdentifier)
        $0.register(SearchTermPlaceholderViewCell.self, forCellWithReuseIdentifier: SearchTermPlaceholderViewCell.cellIdentifier)
        
        $0.delegate = self
    }
    
    
    // MARK: Variables
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private lazy var dataSource = DataSource(collectionView: self.collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
        
        switch item {
        case let .main(model):
            
            let cell: SearchTermViewCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SearchTermViewCell.cellIdentifier,
                for: indexPath
            ) as! SearchTermViewCell
            cell.setModel(model)
            
            return cell
        case .empty:
            
            let placeholder: SearchTermPlaceholderViewCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SearchTermPlaceholderViewCell.cellIdentifier,
                for: indexPath
            ) as! SearchTermPlaceholderViewCell
            
            return placeholder
        }
    }
    
    private(set) var models: [TagInfo]?
    
    let backgroundDidTap = PublishRelay<TagInfo>()
    let didScrolled = PublishRelay<Void>()
    
    
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
        }
    }
    
    
    // MARK: Public func
    
    func setModels(_ models: [TagInfo], with returnKeyDidTap: Bool = false) {
        
        self.models = models
        
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        
        guard models.isEmpty == false else {
            if returnKeyDidTap {
                snapshot.appendItems([.empty], toSection: .empty)
            } else {
                snapshot.deleteSections(Section.allCases)
            }
            self.dataSource.apply(snapshot, animatingDifferences: false)
            return
        }
        
        let items = models.map { Item.main($0) }
        snapshot.appendItems(items, toSection: .main)
        
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }
}


// MARK: UICollectionViewDelegateFlowLayout

extension SearchTermsView: UICollectionViewDelegateFlowLayout {
    
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
        
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else {
            return collectionView.bounds.size
        }
        
        switch item {
        case .main:
            
            let width = (collectionView.bounds.width - 16 * 2)
            return CGSize(width: width, height: 48)
        case .empty:
            
            return collectionView.bounds.size
        }
    }
    
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        self.didScrolled.accept(())
    }
}
