//
//  WrittenTags.swift
//  SOOUM
//
//  Created by 오현식 on 11/2/25.
//

import UIKit

import SnapKit
import Then

import RxCocoa

class WrittenTags: UIView {
    
    enum Section: Int {
        case main
    }
    
    enum Item: Hashable {
        case tag(WrittenTagModel)
    }
    
    
    // MARK: Views
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.scrollDirection = .horizontal
            $0.minimumInteritemSpacing = 6
            $0.minimumLineSpacing = 0
        }
    ).then {
        $0.backgroundColor = .clear
        
        $0.alwaysBounceHorizontal = true
        $0.isScrollEnabled = true
        
        $0.contentInsetAdjustmentBehavior = .never
        $0.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        
        $0.register(WrittenTag.self, forCellWithReuseIdentifier: WrittenTag.cellIdentifier)
        
        $0.delegate = self
    }
    
    
    // MARK: Variables
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private lazy var dataSource = DataSource(collectionView: self.collectionView) { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
        guard let self = self else { return nil }
        
        switch item {
        case let .tag(model):
            
            let cell: WrittenTag = collectionView.dequeueReusableCell(
                withReuseIdentifier: WrittenTag.cellIdentifier,
                for: indexPath
            ) as! WrittenTag
            cell.setModel(model)
            
            return cell
        }
    }
    
    private(set) var models = [WrittenTagModel]()
    
    
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
    
    func setModels(_ models: [WrittenTagModel]) {
        
        guard models.isEmpty == false else {
            self.models = []
            var snapshot = Snapshot()
            snapshot.appendSections([.main])
            self.dataSource.apply(snapshot, animatingDifferences: false)
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
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }
}


// MARK: UICollectionViewDelegateFlowLayout

extension WrittenTags: UICollectionViewDelegateFlowLayout {
    
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
                    withAttributes: [.font: model.typography.font]
                ).width
                /// leading offset + hash image width + spacing + text width + spacing + trailing offset
                let tagWidth: CGFloat = 8 + 14 + 2 + ceil(textWidth) + 8
                return CGSize(width: tagWidth, height: 28)
            }
            
            return size
        }
    }
}
