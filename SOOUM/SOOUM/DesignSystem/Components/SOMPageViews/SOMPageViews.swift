//
//  SOMPageViews.swift
//  SOOUM
//
//  Created by 오현식 on 10/2/25.
//

import UIKit

import SnapKit
import Then

class SOMPageViews: UIView {
    
    enum Section: Int, CaseIterable {
        case main
    }
    
    enum Item: Hashable {
        case main(SOMPageModel)
    }
    
    
    // MARK: Views
    
    private let shadowbackgroundView = UIView().then {
        $0.backgroundColor = .som.v2.white
        $0.layer.cornerRadius = 16
    }
    
    private let layout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 0
        $0.minimumInteritemSpacing = 0
        $0.sectionInset = .zero
    }
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: self.layout
    ).then {
        $0.backgroundColor = .clear
        
        $0.alwaysBounceHorizontal = true
        
        $0.contentInsetAdjustmentBehavior = .never
        $0.contentInset = .zero
        
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = true
        
        $0.register(SOMPageView.self, forCellWithReuseIdentifier: "page")
        
        $0.delegate = self
    }
    
    
    // MARK: Variables
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private lazy var dataSource = DataSource(collectionView: self.collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
        
        if case let .main(model) = item {
            let cell: SOMPageView = collectionView.dequeueReusableCell(
                withReuseIdentifier: "page",
                for: indexPath
            ) as! SOMPageView
            cell.setModel(model)
            
            return cell
        } else {
            return nil
        }
    }
    
    weak var delegate: SOMPageViewsDelegate?
    
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Override func
    
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
        
        self.addSubview(self.shadowbackgroundView)
        self.shadowbackgroundView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-10)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        self.shadowbackgroundView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    
    // MARK: Public func
    
    func setModels(_ models: [SOMPageModel]) {
        
        let modelsToItem = models.map { Item.main($0) }
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(modelsToItem, toSection: .main)
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension SOMPageViews: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return }
        
        if case let .main(model) = item {
            self.delegate?.pages(self, didTouch: model)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width: CGFloat = collectionView.bounds.width
        let height: CGFloat = 71
        
        return CGSize(width: width, height: height)
    }
}
