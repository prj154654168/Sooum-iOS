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
    
    private let indicatorContainer = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 2
    }
    
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
    
    private var currentIndexForIndicator: Int = 0 {
        didSet {
            
            guard oldValue != self.currentIndexForIndicator else { return }
            
            self.indicatorContainer.subviews.enumerated().forEach { index, indicator in
                indicator.backgroundColor = index == self.currentIndexForIndicator ? .som.v2.gray600 : .som.v2.gray300
                indicator.snp.updateConstraints {
                    $0.width.equalTo(index == self.currentIndexForIndicator ? 8 : 4)
                }
            }
        }
    }
    
    private(set) var models: [SOMPageModel] = []
    
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
        
        self.shadowbackgroundView.addSubview(self.indicatorContainer)
        self.indicatorContainer.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        self.shadowbackgroundView.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    
    // MARK: Public func
    
    func setModels(_ models: [SOMPageModel]) {
        
        self.indicatorContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for index in 0..<models.count {
            let indicator = UIView().then {
                $0.backgroundColor = index == 0 ? .som.v2.gray600 : .som.v2.gray300
                $0.layer.cornerRadius = 4 * 0.5
            }
            self.indicatorContainer.addArrangedSubview(indicator)
            indicator.snp.makeConstraints {
                $0.width.equalTo(index == 0 ? 8 : 4)
                $0.height.equalTo(4)
            }
        }
        
        self.models = models
        
        var infiniteModels: [SOMPageModel] {
            if models.count > 1 {
                guard let first = models.first, let last = models.last else { return models }
                
                let leadingModel: SOMPageModel = SOMPageModel(data: last.data)
                let trailingModel: SOMPageModel = SOMPageModel(data: first.data)
                
                return [leadingModel] + models + [trailingModel]
            } else {
                return models
            }
        }
        
        let modelsToItem = infiniteModels.map { Item.main($0) }
        var snapshot = Snapshot()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(modelsToItem, toSection: .main)
        self.dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            guard models.count > 1 else { return }
            
            DispatchQueue.main.async {
                let initialIndexPath: IndexPath = IndexPath(item: 1, section: Section.main.rawValue)
                self?.collectionView.scrollToItem(
                    at: initialIndexPath,
                    at: .centeredHorizontally,
                    animated: false
                )
            }
        }
    }
}


// MARK: UICollectionViewDelegateFlowLayout and UIScrollViewDelegate

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
    
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        self.infiniteScroll(scrollView)
    }
    
    private func infiniteScroll(_ scrollView: UIScrollView) {
        
        let cellWidth: CGFloat = scrollView.bounds.width
        let currentIndex: Int = Int(round(scrollView.contentOffset.x / cellWidth))
        
        var targetIndex: Int? {
            switch currentIndex {
            case 0:                    return self.models.count
            case self.models.count + 1: return 1
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
