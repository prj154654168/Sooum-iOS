//
//  FavoriteTagsView.swift
//  SOOUM
//
//  Created by 오현식 on 11/20/25.
//

import UIKit

import SnapKit
import Then

import RxCocoa
import RxSwift

class FavoriteTagsView: UIView {
    
    enum Section: Int, CaseIterable {
        case main
        case empty
    }
    
    enum Item: Hashable {
        case main(FavoriteTagsViewModel)
        case empty
    }
    
    
    // MARK: Views
    
    private let indicatorContainer = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 4
        
        $0.isHidden = true
    }
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.scrollDirection = .horizontal
            $0.minimumLineSpacing = 0
            $0.minimumInteritemSpacing = 0
            $0.sectionInset = .zero
        }
    ).then {
        $0.backgroundColor = .clear
        
        $0.alwaysBounceHorizontal = true
        
        $0.contentInsetAdjustmentBehavior = .never
        $0.contentInset = .zero
        
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = true
        
        $0.register(FavoriteTagViewCell.self, forCellWithReuseIdentifier: FavoriteTagViewCell.cellIdentifier)
        $0.register(FavoriteTagPlaceholderViewCell.self, forCellWithReuseIdentifier: FavoriteTagPlaceholderViewCell.cellIdentifier)
        
        $0.delegate = self
    }
    
    
    // MARK: Variables
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private lazy var dataSource = DataSource(collectionView: self.collectionView) { collectionView, indexPath, item -> UICollectionViewCell in
        
        switch item {
        case let .main(models):
            
            let cell: FavoriteTagViewCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FavoriteTagViewCell.cellIdentifier,
                for: indexPath
            ) as! FavoriteTagViewCell
            cell.setModels(models)
            
            cell.backgroundDidTap
                .subscribe(with: self) { object, model in
                    object.backgroundDidTap.accept(model)
                }
                .disposed(by: cell.disposeBag)
            
            cell.favoriteIconDidTap
                .subscribe(with: self) { object, model in
                    object.favoriteIconDidTap.accept(model)
                    
                    guard var new = object.models,
                          let index = new.firstIndex(where: { $0 == model })
                    else { return }
                    
                    new[index].isFavorite.toggle()
                    
                    object.setModels(new)
                }
                .disposed(by: cell.disposeBag)
            
            return cell
        case .empty:
            
            let placeholder: FavoriteTagPlaceholderViewCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FavoriteTagPlaceholderViewCell.cellIdentifier,
                for: indexPath
            ) as! FavoriteTagPlaceholderViewCell
            
            return placeholder
        }
    }
    
    private var currentIndexForIndicator: Int = 0 {
        didSet {
            
            guard oldValue != self.currentIndexForIndicator else { return }
            
            self.indicatorContainer.subviews.enumerated().forEach { index, indicator in
                indicator.backgroundColor = index == self.currentIndexForIndicator ? .som.v2.black : .som.v2.gray300
            }
        }
    }
    
    private(set) var models: [FavoriteTagViewModel]?
    
    private var collectionViewHeightConstraint: Constraint?
    
    let favoriteIconDidTap = PublishRelay<FavoriteTagViewModel>()
    let backgroundDidTap = PublishRelay<FavoriteTagViewModel>()
    
    
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
        
        let container = UIStackView(arrangedSubviews: [self.collectionView, self.indicatorContainer]).then {
            $0.axis = .vertical
            $0.alignment = .center
            $0.distribution = .equalSpacing
            $0.spacing = 12
        }
        self.addSubview(container)
        container.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.collectionView.snp.makeConstraints {
            $0.width.equalTo(container.snp.width)
            self.collectionViewHeightConstraint = $0.height.equalTo(0).constraint
        }
        self.indicatorContainer.snp.makeConstraints {
            $0.height.equalTo(6)
        }
    }
    
    
    // MARK: Public func
    
    func setModels(_ models: [FavoriteTagViewModel]) {
        
        self.models = models
        
        let slicedBySize = models.sliceBySize(into: 3).map { FavoriteTagsViewModel(tags: $0) }
        
        self.indicatorContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        
        var finalCollectionViewHeight: CGFloat = 0
        if slicedBySize.isEmpty {
            snapshot.appendItems([.empty], toSection: .empty)
            
            finalCollectionViewHeight = 144
            self.indicatorContainer.isHidden = true
        } else {
            if slicedBySize.count > 1 {
                
                for index in 0..<slicedBySize.count {
                    let indicator = UIView().then {
                        $0.backgroundColor = index == self.currentIndexForIndicator ? .som.v2.black : .som.v2.gray300
                        $0.layer.cornerRadius = 6 * 0.5
                    }
                    self.indicatorContainer.addArrangedSubview(indicator)
                    indicator.snp.makeConstraints {
                        $0.size.equalTo(6)
                    }
                }
            }
            
            var infiniteModels: [FavoriteTagsViewModel] {
                if slicedBySize.count > 1 {
                    guard let first = slicedBySize.first,
                          let last = slicedBySize.last
                    else { return slicedBySize }
                    
                    let toFirst = FavoriteTagsViewModel(tags: first.tags)
                    let toLast = FavoriteTagsViewModel(tags: last.tags)
                    
                    return [toLast] + slicedBySize + [toFirst]
                } else {
                    return slicedBySize
                }
            }
            
            let items = infiniteModels.map { Item.main($0) }
            snapshot.appendItems(items, toSection: .main)
            
            let indicatorIsHidden = slicedBySize.count < 2
            self.indicatorContainer.isHidden = indicatorIsHidden
            
            let indicatorHiddenHeight = CGFloat(slicedBySize[0].tags.count * 48)
            let indicatorVisibleHeight = CGFloat(48 * 3 + 12 + 6)
            finalCollectionViewHeight = indicatorIsHidden ? indicatorHiddenHeight : indicatorVisibleHeight
        }
        
        self.collectionViewHeightConstraint?.update(offset: finalCollectionViewHeight)
        
        self.layoutIfNeeded()
        
        self.dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            guard let self = self, slicedBySize.count > 1 else { return }
            
            DispatchQueue.main.async {
                let newIndexForIndicator = self.currentIndexForIndicator == 0 ? 1 : self.currentIndexForIndicator + 1
                let initialIndexPath: IndexPath = IndexPath(item: newIndexForIndicator, section: Section.main.rawValue)
                self.collectionView.scrollToItem(
                    at: initialIndexPath,
                    at: .centeredHorizontally,
                    animated: false
                )
            }
        }
    }
}


// MARK: UICollectionViewDelegateFlowLayout and UIScrollViewDelegate

extension FavoriteTagsView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let width = collectionView.bounds.width
        let placeholderSize = CGSize(width: width, height: 144)
        guard let item = self.dataSource.itemIdentifier(for: indexPath),
              let models = self.models
        else { return placeholderSize }
        
        let modelsCount = ceil(Double(models.count) / 3)
        
        switch item {
        case let .main(models):
            
            var height: Int {
                return modelsCount > 1 ? 48 * 3 + 12 + 6 : 48 * models.tags.count
            }
            return CGSize(width: width, height: CGFloat(height))
        case .empty:
            
            return placeholderSize
        }
    }
    
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        self.infiniteScroll(scrollView)
    }
    
    private func infiniteScroll(_ scrollView: UIScrollView) {
        
        guard let models = self.models else { return }
        
        let slicedCount = Int(ceil(Double(models.count) / 3.0))
        guard slicedCount > 1 else { return }
        
        let cellWidth: CGFloat = scrollView.bounds.width
        let currentIndex: Int = Int(round(scrollView.contentOffset.x / cellWidth))
        
        var targetIndex: Int? {
            switch currentIndex {
            case 0:                    return slicedCount
            case slicedCount + 1:      return 1
            default:                   return nil
            }
        }
        
        guard let targetIndex = targetIndex else {
            self.currentIndexForIndicator = currentIndex - 1
            return
        }
        
        let targetIndexPath: IndexPath = IndexPath(item: targetIndex, section: Section.main.rawValue)
        self.collectionView.scrollToItem(
            at: targetIndexPath,
            at: .centeredHorizontally,
            animated: false
        )
        self.currentIndexForIndicator = targetIndex - 1
    }
}
