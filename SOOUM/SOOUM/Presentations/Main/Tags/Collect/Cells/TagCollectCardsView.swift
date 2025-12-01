//
//  TagCollectCardsView.swift
//  SOOUM
//
//  Created by 오현식 on 11/22/25.
//

import UIKit

import SnapKit
import Then

import RxCocoa
import RxSwift

class TagCollectCardsView: UIView {
    
    enum Section: Int, CaseIterable {
        case main
        case empty
    }
    
    enum Item: Hashable {
        case main(ProfileCardInfo)
        case empty
    }
    
    
    // MARK: Views
    
    let refreshControl = SOMRefreshControl()
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.scrollDirection = .vertical
            $0.minimumLineSpacing = 1
            $0.minimumInteritemSpacing = 1
            $0.sectionInset = .zero
        }
    ).then {
        $0.contentInset = .zero
        
        $0.contentInsetAdjustmentBehavior = .never
        
        $0.isScrollEnabled = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        
        $0.refreshControl = self.refreshControl
        
        $0.register(
            TagCollectCardViewCell.self,
            forCellWithReuseIdentifier: TagCollectCardViewCell.cellIdentifier
        )
        $0.register(
            TagCollectPlaceholderViewCell.self,
            forCellWithReuseIdentifier: TagCollectPlaceholderViewCell.cellIdentifier
        )
        
        $0.delegate = self
    }
    
    
    // MARK: Variables
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private lazy var dataSource = DataSource(collectionView: self.collectionView) { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
        
        switch item {
        case let .main(model):
            
            let cell: TagCollectCardViewCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TagCollectCardViewCell.cellIdentifier,
                for: indexPath
            ) as! TagCollectCardViewCell
            
            cell.setModel(model)
            
            return cell
        case .empty:
            
            let placeholder: TagCollectPlaceholderViewCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TagCollectPlaceholderViewCell.cellIdentifier,
                for: indexPath
            ) as! TagCollectPlaceholderViewCell
            
            return placeholder
        }
    }
    
    private var initialOffset: CGFloat = 0
    private var currentOffset: CGFloat = 0
    private var isRefreshEnabled: Bool = true
    private var shouldRefreshing: Bool = false
    
    /// 외부에서 입력받는 값
    var isRefreshing: Bool = false {
        didSet {
            if self.isRefreshing == false {
                self.collectionView.refreshControl?.endRefreshing()
            }
        }
    }
    
    private(set) var models: [ProfileCardInfo]?
    
    let cardDidTapped = PublishRelay<ProfileCardInfo>()
    let moreFindWithId = PublishRelay<String>()
    
    
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
    
    func setModels(_ models: [ProfileCardInfo]) {
        
        self.models = models
        
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        
        guard models.isEmpty == false else {
            snapshot.appendItems([.empty], toSection: .empty)
            self.dataSource.apply(snapshot, animatingDifferences: false)
            return
        }
        
        let new = models.map { Item.main($0) }
        snapshot.appendItems(new, toSection: .main)
        
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }
}


// MARK: UICollectionViewDelegateFlowLayout

extension TagCollectCardsView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return }
        
        if case let .main(model) = item {
            self.cardDidTapped.accept(model)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        
        let lastItemIndexPath = collectionView.numberOfItems(inSection: Section.main.rawValue) - 1
        if let tagCardInfos = self.models,
           tagCardInfos.isEmpty == false,
           indexPath.section == Section.main.rawValue,
           indexPath.item == lastItemIndexPath,
           let lastId = tagCardInfos.last?.id {
            
            self.moreFindWithId.accept(lastId)
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
        case .empty:
            return collectionView.bounds.size
        default:
            let width: CGFloat = (collectionView.bounds.width - 2) / 3
            return CGSize(width: width, height: width)
        }
    }
    
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        
        // currentOffset <= 0 && isRefreshing == false 일 때, 테이블 뷰 새로고침 가능
        self.isRefreshEnabled = (offset <= 0) && (self.isRefreshing == false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        
        // 당겨서 새로고침
        if self.isRefreshEnabled, offset < self.initialOffset {
            
            let pulledOffset = self.initialOffset - offset
            /// refreshControl heigt + top padding
            let refreshingOffset: CGFloat = 44 + 12
            self.shouldRefreshing = abs(pulledOffset) >= refreshingOffset
        }
        
        self.currentOffset = offset
    }
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        
        if self.shouldRefreshing {
            self.collectionView.refreshControl?.beginRefreshing()
        }
    }
}
