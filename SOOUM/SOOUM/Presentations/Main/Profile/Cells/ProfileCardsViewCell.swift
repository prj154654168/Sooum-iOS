//
//  ProfileCardsViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 11/7/25.
//

import UIKit

import SnapKit
import Then

import RxCocoa
import RxSwift

class ProfileCardsViewCell: UICollectionViewCell {
    
    enum Text {
        static let blockedText: String = "차단한 계정입니다"
    }
    
    enum Section: Int, CaseIterable {
        case feed
        case comment
        case empty
    }
    
    enum Item: Hashable {
        case feed(ProfileCardInfo)
        case comment(ProfileCardInfo)
        case empty
    }
    
    static let cellIdentifier = String(reflecting: ProfileCardsViewCell.self)
    
    
    // MARK: Views
    
    private let flowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 1
        $0.minimumInteritemSpacing = 1
    }
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: self.flowLayout
    ).then {
        $0.contentInset = .zero
        
        $0.isScrollEnabled = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        
        $0.register(
            ProfileCardViewCell.self,
            forCellWithReuseIdentifier: ProfileCardViewCell.cellIdentifier
        )
        $0.register(
            ProfileCardsPlaceholderViewCell.self,
            forCellWithReuseIdentifier: ProfileCardsPlaceholderViewCell.cellIdentifier
        )
        
        $0.delegate = self
    }
    
    
    // MARK: Variables
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private lazy var dataSource = DataSource(collectionView: self.collectionView) { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
       
        guard let self = self else { return nil }
        
        switch item {
        case let .feed(profileCardInfo):
            
            let cell: ProfileCardViewCell = self.cell(collectionView, cellForItemAt: indexPath)
            cell.setModel(profileCardInfo)
            
            return cell
        case let .comment(profileCardInfo):
            
            let cell: ProfileCardViewCell = self.cell(collectionView, cellForItemAt: indexPath)
            cell.setModel(profileCardInfo)
            
            return cell
        case .empty:
            
            return self.placeholder(collectionView, cellForItemAt: indexPath)
        }
    }
    
    private(set) var feedCardInfos = [ProfileCardInfo]()
    private(set) var commentCardInfos: [ProfileCardInfo]?
    private(set) var selectedCardType: EntranceCardType = .feed
    
    
    // MARK: Variables + Rx
    
    var disposeBag = DisposeBag()
    
    let cardDidTap = PublishRelay<String>()
    let moreFindCards = PublishRelay<(type: EntranceCardType, lastId: String)>()
    
    
    // MARK: Initialize
    
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
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    
    // MARK: Public func
    
    func setModels(
        type selectedCardType: EntranceCardType,
        feed feedCardInfos: [ProfileCardInfo],
        comment commentCardInfos: [ProfileCardInfo]?
    ) {
        
        self.selectedCardType = selectedCardType
        self.feedCardInfos = feedCardInfos
        self.commentCardInfos = commentCardInfos
        
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        
        switch selectedCardType {
        case .feed:
            
            guard feedCardInfos.isEmpty == false else {
                snapshot.appendItems([.empty], toSection: .empty)
                break
            }
            
            let new = feedCardInfos.map { Item.feed($0) }
            snapshot.appendItems(new, toSection: .feed)
        case .comment:
            
            guard let commentCardInfos = commentCardInfos else { return }
            
            guard commentCardInfos.isEmpty == false else {
                snapshot.appendItems([.empty], toSection: .empty)
                break
            }
            
            let new = commentCardInfos.map { Item.comment($0) }
            snapshot.appendItems(new, toSection: .comment)
        }
        
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension ProfileCardsViewCell {
    
    func cell(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> ProfileCardViewCell {
        
        let cell: ProfileCardViewCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProfileCardViewCell.cellIdentifier,
            for: indexPath
        ) as! ProfileCardViewCell
        
        return cell
    }
    
    func placeholder(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> ProfileCardsPlaceholderViewCell {
        
        let placeholder: ProfileCardsPlaceholderViewCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProfileCardsPlaceholderViewCell.cellIdentifier,
            for: indexPath
        ) as! ProfileCardsPlaceholderViewCell
        
        return placeholder
    }
}


// MARK: UICollectionViewDelegateFlowLayout

extension ProfileCardsViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return }
        
        var selectedId: String? {
            switch item {
            case let .feed(selectedCard):
                return selectedCard.id
            case let .comment(selectedCard):
                return selectedCard.id
            case .empty:
                return nil
            }
        }
        
        guard let selectedId = selectedId else { return }
        
        self.cardDidTap.accept(selectedId)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        
        switch self.selectedCardType {
        case .feed:
            
            let lastItemIndexPath = collectionView.numberOfItems(inSection: Section.feed.rawValue) - 1
            if self.feedCardInfos.isEmpty == false,
               indexPath.section == Section.feed.rawValue,
               indexPath.item == lastItemIndexPath,
               let lastId = self.feedCardInfos.last?.id {
                
                self.moreFindCards.accept((.feed, lastId))
            }
        case .comment:
            
            let lastItemIndexPath = collectionView.numberOfItems(inSection: Section.comment.rawValue) - 1
            if self.commentCardInfos?.isEmpty == false,
               indexPath.section == Section.comment.rawValue,
               indexPath.item == lastItemIndexPath,
               let lastId = self.commentCardInfos?.last?.id {
                
                self.moreFindCards.accept((.comment, lastId))
            }
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
}
