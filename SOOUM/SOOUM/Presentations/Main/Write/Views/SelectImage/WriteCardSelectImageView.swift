//
//  WriteCardSelectImageView.swift
//  SOOUM
//
//  Created by 오현식 on 10/10/25.
//

import UIKit

import SnapKit
import Then

import RxCocoa

class WriteCardSelectImageView: UIView {
    
    enum Text {
        static let title: String = "배경"
        
        static let colorTitle: String = "컬러"
        static let natureTitle: String = "자연"
        static let sensitivitytitle: String = "감성"
        static let foodTitle: String = "푸드"
        static let abstractTitle: String = "추상"
        static let memoTitle: String = "메모"
        static let eventTitle: String = "이벤트"
    }
    
    enum Section: Int, CaseIterable {
        case color
        case nature
        case sensitivity
        case food
        case abstract
        case memo
        case event
    }
    
    enum Item: Hashable {
        case color(ImageUrlInfo)
        case nature(ImageUrlInfo)
        case sensitivity(ImageUrlInfo)
        case food(ImageUrlInfo)
        case abstract(ImageUrlInfo)
        case memo(ImageUrlInfo)
        case event(ImageUrlInfo)
        case user
    }
    
    
    // MARK: Views
    
    private let titleLabel = UILabel().then {
        $0.text = Text.title
        $0.textColor = .som.v2.pDark
        $0.typography = .som.v2.caption1
    }
    
    private lazy var headerView = SOMSwipableTabBar().then {
        $0.delegate = self
    }
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.scrollDirection = .vertical
            $0.minimumLineSpacing = 0
            $0.minimumInteritemSpacing = 0
        }
    ).then {
        $0.isScrollEnabled = false
        
        $0.contentInsetAdjustmentBehavior = .never
        
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        
        $0.layer.borderColor = UIColor.som.v2.gray200.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 8
        
        $0.clipsToBounds = true
        
        $0.register(WriteCardDefaultImageCell.self, forCellWithReuseIdentifier: WriteCardDefaultImageCell.cellIdentifier)
        $0.register(WriteCardUserImageCell.self, forCellWithReuseIdentifier: WriteCardUserImageCell.cellIdentifier)
        
        $0.delegate = self
    }
    
    
    // MARK: Variables
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private lazy var dataSource = DataSource(collectionView: self.collectionView) { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
        
        guard let self = self else { return nil }
        
        switch item {
        case let .color(imageInfo):
            
            let cell: WriteCardDefaultImageCell = self.cellForDefault(collectionView, with: indexPath)
            cell.setModel(imageInfo)
            cell.isSelected = imageInfo == self.selectedImageInfo.value?.info
            
            return cell
        case let .nature(imageInfo):
            
            let cell: WriteCardDefaultImageCell = self.cellForDefault(collectionView, with: indexPath)
            cell.setModel(imageInfo)
            cell.isSelected = imageInfo == self.selectedImageInfo.value?.info
            
            return cell
        case let .sensitivity(imageInfo):
            
            let cell: WriteCardDefaultImageCell = self.cellForDefault(collectionView, with: indexPath)
            cell.setModel(imageInfo)
            cell.isSelected = imageInfo == self.selectedImageInfo.value?.info
            
            return cell
        case let .food(imageInfo):
            
            let cell: WriteCardDefaultImageCell = self.cellForDefault(collectionView, with: indexPath)
            cell.setModel(imageInfo)
            cell.isSelected = imageInfo == self.selectedImageInfo.value?.info
            
            return cell
        case let .abstract(imageInfo):
            
            let cell: WriteCardDefaultImageCell = self.cellForDefault(collectionView, with: indexPath)
            cell.setModel(imageInfo)
            cell.isSelected = imageInfo == self.selectedImageInfo.value?.info
            
            return cell
        case let .memo(imageInfo):
            
            let cell: WriteCardDefaultImageCell = self.cellForDefault(collectionView, with: indexPath)
            cell.setModel(imageInfo)
            cell.isSelected = imageInfo == self.selectedImageInfo.value?.info
            
            return cell
        case let .event(imageInfo):
            
            let cell: WriteCardDefaultImageCell = self.cellForDefault(collectionView, with: indexPath)
            cell.setModel(imageInfo)
            cell.isSelected = imageInfo == self.selectedImageInfo.value?.info
            
            return cell
        case .user:
            
            let cell: WriteCardUserImageCell = self.cellForUser(collectionView, with: indexPath)
            
            return cell
        }
    }
    
    
    // MARK: Variables
    
    private(set) var models: DefaultImages = .defaultValue
    private(set) var cardType: EntranceCardType = .feed
    
    var selectedImageInfo = BehaviorRelay<(type: BaseCardInfo.ImageType, info: ImageUrlInfo)?>(value: nil)
    var selectedUseUserImageCell = PublishRelay<Void>()
    
    
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
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        
        self.addSubview(self.headerView)
        self.headerView.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }
        
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.top.equalTo(self.headerView.snp.bottom)
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            let width: CGFloat = (UIScreen.main.bounds.width - 16 * 2) / 4
            $0.height.equalTo(width * 2)
        }
    }
    
    
    // MARK: Public func
    
    func setModels(_ models: DefaultImages, cardType: EntranceCardType) {
        
        self.models = models
        self.cardType = cardType
        
        guard let initialImage = models.color.first else { return }
        
        self.selectedImageInfo.accept((.default, initialImage))
        
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        var items = [
            Text.colorTitle,
            Text.natureTitle,
            Text.sensitivitytitle,
            Text.foodTitle,
            Text.abstractTitle,
            Text.memoTitle,
            Text.eventTitle
        ]
        if models.event == nil {
            snapshot.deleteSections([.event])
            items.removeAll(where: { $0 == Text.eventTitle })
        }
        self.headerView.items = items
        
        var new = models.color.map { Item.color($0) }
        new.append(Item.user)
        snapshot.appendItems(new, toSection: .color)
        self.dataSource.apply(snapshot, animatingDifferences: true)
        
        var reconfigureSnapshot = self.dataSource.snapshot()
        if let itemToUpdate: Item = reconfigureSnapshot.itemIdentifiers.first(where: {
            switch $0 {
            case let .color(imageInfo):
                return imageInfo == initialImage
            default:
                return false
            }
        }) {
            reconfigureSnapshot.reconfigureItems([itemToUpdate])
            self.dataSource.apply(reconfigureSnapshot, animatingDifferences: false)
        }
    }
    
    func updatedByUser() {
        
        var reconfigureSnapshot = self.dataSource.snapshot()
        if let itemToUpdate: Item = reconfigureSnapshot.itemIdentifiers.first(where: {
            switch $0 {
            case let .color(imageInfo),
                let .nature(imageInfo),
                let .sensitivity(imageInfo),
                let .food(imageInfo),
                let .abstract(imageInfo),
                let .memo(imageInfo),
                let .event(imageInfo):
                return imageInfo == self.selectedImageInfo.value?.info
            case .user:
                return false
            }
        }) {
            
            self.selectedImageInfo.accept((.user, .defaultValue))
            
            reconfigureSnapshot.reconfigureItems([itemToUpdate])
            self.dataSource.apply(reconfigureSnapshot, animatingDifferences: false)
        }
    }
}


// MARK: Cells

private extension WriteCardSelectImageView {
    
    func cellForDefault(
        _ collectionView: UICollectionView,
        with indexPath: IndexPath
    ) -> WriteCardDefaultImageCell {
        
        return collectionView.dequeueReusableCell(
            withReuseIdentifier: WriteCardDefaultImageCell.cellIdentifier,
            for: indexPath
        ) as! WriteCardDefaultImageCell
    }
    
    func cellForUser(
        _ collectionView: UICollectionView,
        with indexPath: IndexPath
    ) -> WriteCardUserImageCell {
        return collectionView.dequeueReusableCell(
            withReuseIdentifier: WriteCardUserImageCell.cellIdentifier,
            for: indexPath
        ) as! WriteCardUserImageCell
    }
}


// MARK: SOMSwipeTabBarDelegate

extension WriteCardSelectImageView: SOMSwipableTabBarDelegate {
    
    func tabBar(_ tabBar: SOMSwipableTabBar, didSelectTabAt index: Int) {
        
        var headerFilter: (section: WriteCardSelectImageView.Section, items: [WriteCardSelectImageView.Item])? {
            switch index {
            case 0:
                let items = self.models.color.map { Item.color($0) }
                return (.color, items)
            case 1:
                let items = self.models.nature.map { Item.nature($0) }
                return (.nature, items)
            case 2:
                let items = self.models.sensitivity.map { Item.sensitivity($0) }
                return (.sensitivity, items)
            case 3:
                let items = self.models.food.map { Item.food($0) }
                return (.food, items)
            case 4:
                let items = self.models.abstract.map { Item.abstract($0) }
                return (.abstract, items)
            case 5:
                let items = self.models.memo.map { Item.memo($0) }
                return (.memo, items)
            case 6:
                guard let events = self.models.event else { return nil }
                let items = events.map { Item.event($0) }
                return (.event, items)
            default:
                return nil
            }
        }
        guard var headerFilter = headerFilter else { return }
        headerFilter.items.append(Item.user)
        
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(headerFilter.items, toSection: headerFilter.section)
        self.dataSource.apply(snapshot, animatingDifferences: true)
        
        var reconfigureSnapshot = self.dataSource.snapshot()
        let items = reconfigureSnapshot.itemIdentifiers(inSection: headerFilter.section)
        if let itemToUpdate: Item = items.first(where: {
            switch $0 {
            case let .color(imageInfo),
                let .nature(imageInfo),
                let .sensitivity(imageInfo),
                let .food(imageInfo),
                let .abstract(imageInfo),
                let .memo(imageInfo):
                
                if self.cardType == .feed {
                    GAHelper.shared.logEvent(
                        event: GAEvent.WriteCardView.feedBackgroundCategory_tabClick
                    )
                } else {
                    GAHelper.shared.logEvent(
                        event: GAEvent.WriteCardView.commentBackgroundCategory_tabClick
                    )
                }
                
                return imageInfo == self.selectedImageInfo.value?.info
            case let .event(imageInfo):
                
                if self.cardType == .feed {
                    GAHelper.shared.logEvent(
                        event: GAEvent.WriteCardView.feedBackgroundCategory_tabClick
                    )
                } else {
                    GAHelper.shared.logEvent(
                        event: GAEvent.WriteCardView.commentBackgroundCategory_tabClick
                    )
                    GAHelper.shared.logEvent(event: GAEvent.WriteCardView.createFCardEventCategory_btnClick)
                }
                
                return imageInfo == self.selectedImageInfo.value?.info
            case .user:
                return false
            }
        }) {
            reconfigureSnapshot.reconfigureItems([itemToUpdate])
            self.dataSource.apply(reconfigureSnapshot, animatingDifferences: false)
        }
    }
}


// MARK: UICollectionViewDelegate

extension WriteCardSelectImageView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let newItem = self.dataSource.itemIdentifier(for: indexPath) else { return }
        
        var reconfigureSnapshot = self.dataSource.snapshot()
        var itemsToUpdate: Set<Item> = []
        if let prevItem: Item = reconfigureSnapshot.itemIdentifiers.first(where: {
            switch $0 {
            case let .color(imageInfo),
                let .nature(imageInfo),
                let .sensitivity(imageInfo),
                let .food(imageInfo),
                let .abstract(imageInfo),
                let .memo(imageInfo),
                let .event(imageInfo):
                return imageInfo == self.selectedImageInfo.value?.info
            case .user:
                return false
            }
        }) {
            itemsToUpdate.insert(prevItem)
        }

        switch newItem {
        case let .color(imageInfo):
            self.selectedImageInfo.accept((.default, imageInfo))
        case let .nature(imageInfo):
            self.selectedImageInfo.accept((.default, imageInfo))
        case let .sensitivity(imageInfo):
            self.selectedImageInfo.accept((.default, imageInfo))
        case let .food(imageInfo):
            self.selectedImageInfo.accept((.default, imageInfo))
        case let .abstract(imageInfo):
            self.selectedImageInfo.accept((.default, imageInfo))
        case let .memo(imageInfo):
            self.selectedImageInfo.accept((.default, imageInfo))
        case let .event(imageInfo):
            self.selectedImageInfo.accept((.default, imageInfo))
        case .user:
            self.selectedUseUserImageCell.accept(())
        }
        itemsToUpdate.insert(newItem)
        
        reconfigureSnapshot.reconfigureItems(Array(itemsToUpdate))
        self.dataSource.apply(reconfigureSnapshot, animatingDifferences: false)
    }
}

extension WriteCardSelectImageView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let width: CGFloat = (UIScreen.main.bounds.width - 16 * 2) / 4
        return CGSize(width: width, height: width)
    }
}
