//
//  RelatedTagsView.swift
//  SOOUM
//
//  Created by 오현식 on 10/16/25.
//

import UIKit

import SnapKit
import Then

import RxCocoa

class RelatedTagsView: UIView {
    
    enum Section: Int {
        case main
    }
    
    enum Item: Hashable {
        case tag(RelatedTagViewModel)
    }
    
    
    // MARK: Views
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: RelatedTagsViewLayout().then {
            $0.scrollDirection = .vertical
            $0.minimumInteritemSpacing = 8
            $0.minimumLineSpacing = 8
            $0.sectionInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        }
    ).then {
        $0.backgroundColor = .som.v2.gray200
        
        $0.alwaysBounceHorizontal = true
        
        $0.contentInsetAdjustmentBehavior = .never
        $0.contentInset = .zero
        
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        
        $0.register(RelatedTagView.self, forCellWithReuseIdentifier: RelatedTagView.cellIdentifier)
        
        $0.delegate = self
    }
    
    
    // MARK: Variables
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private lazy var dataSource = DataSource(collectionView: self.collectionView) { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
        guard let self = self else { return nil }
        
        switch item {
        case let .tag(model):
            
            let cell: RelatedTagView = collectionView.dequeueReusableCell(
                withReuseIdentifier: RelatedTagView.cellIdentifier,
                for: indexPath
            ) as! RelatedTagView
            cell.setModel(model)
            
            return cell
        }
    }
    
    var selectedRelatedTag = BehaviorRelay<RelatedTagViewModel?>(value: nil)
    var updatedContentHeight = BehaviorRelay<CGFloat?>(value: nil)
    
    private(set) var models = [RelatedTagViewModel]()
    
    
    // MARK: Constraint
    
    private var collectionViewHeightConstraint: Constraint?
    
    
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
    
    private func updateContentHeight(animated: Bool = true) {
        
        guard self.models.isEmpty == false else {
            self.collectionViewHeightConstraint?.update(offset: 0)
            self.updatedContentHeight.accept(nil)
            return
        }
        
        let contentHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height
        if self.collectionViewHeightConstraint?.layoutConstraints.first?.constant != contentHeight {
            self.collectionViewHeightConstraint?.update(offset: contentHeight)
            self.updatedContentHeight.accept(contentHeight)
        }
    }
    
    
    // MARK: Public func
    
    func setModels(_ models: [RelatedTagViewModel]) {
        
        guard models.isEmpty == false else {
            self.models = []
            var snapshot = Snapshot()
            snapshot.appendSections([.main])
            self.dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
                self?.updateContentHeight()
            }
            return
        }
        
        let current = self.models
        var new = models
        /// 변경사항이 없다면 종료
        guard current != new else { return }
        
        /// 새로운 태그가 유효한지 확인 (중복 여부 확인)
        if new.count != Set(new).count {
            Log.warning("중복된 태그가 존재합니다. 태그의 순서를 유지하고 중복된 태그를 제거합니다.")
            new = new.removeOlderfromDuplicated()
        }
        
        self.models = new
        
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        
        let items = new.map { Item.tag($0) }
        snapshot.appendItems(items, toSection: .main)
        self.dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            self?.updateContentHeight()
        }
    }
}


// MARK: UICollectionViewDelegateFlowLayout

extension RelatedTagsView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return }
        
        if case let .tag(model) = item {
            self.selectedRelatedTag.accept(model)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return .zero }
        
        switch item {
        case let .tag(model):
            
            var size: CGSize {
                let textWidth: CGFloat = (model.originalText as NSString).size(
                    withAttributes: [.font: Typography.som.v2.caption2.font]
                ).width
                let countWidth: CGFloat = (model.count as NSString).size(
                    withAttributes: [.font: Typography.som.v2.caption3.font]
                ).width
                /// leading offset + hash image width + spacing + text width + spacing + remove button width + trailing offset
                let tagWidth: CGFloat = 8 + 14 + 2 + ceil(textWidth) + 2 + ceil(countWidth) + 8
                return CGSize(width: tagWidth, height: 28)
            }
            
            return size
        }
    }
}
