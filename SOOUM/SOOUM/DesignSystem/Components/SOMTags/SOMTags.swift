//
//  SOMTags.swift
//  SOOUM
//
//  Created by 오현식 on 10/1/24.
//

import UIKit

import SnapKit
import Then


class SOMTags: UIView {
    
    private let flowLayout = SOMTagsLayout()
    lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: self.flowLayout
    ).then {
        $0.alwaysBounceHorizontal = true
        
        $0.contentInsetAdjustmentBehavior = .never
        $0.contentInset = .zero
        
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        
        $0.register(SOMTag.self, forCellWithReuseIdentifier: SOMTag.cellIdentifier)
        
        $0.dataSource = self
        $0.delegate = self
    }
    
    private(set) var models = [SOMTagModel]()
    
    private var configuration: SOMTagsLayoutConfigure = .horizontalWithoutRemove
    
    weak var delegate: SOMTagsDelegate?
    
    convenience init() {
        self.init(configure: SOMTagsLayoutConfigure.horizontalWithoutRemove)
    }
    
    init(configure: SOMTagsLayoutConfigure) {
        super.init(frame: .zero)
        self.configure(config: configure)
        self.setupConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure(config: .horizontalWithoutRemove)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(config: SOMTagsLayoutConfigure) {
        
        self.configuration = config
        
        self.flowLayout.scrollDirection = config.direction
        self.flowLayout.minimumLineSpacing = config.lineSpacing
        self.flowLayout.minimumInteritemSpacing = config.interSpacing
        self.flowLayout.sectionInset = config.inset
        
        self.flowLayout.estimatedItemSize = .zero
        
        self.collectionView.alwaysBounceVertical = config.direction == .vertical
        self.collectionView.alwaysBounceHorizontal = config.direction == .horizontal
        
        self.collectionView.isScrollEnabled = config.direction == .horizontal
        
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func setupConstraints() {
        
        self.addSubviews(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    /*
     상세보기 태그 표시
        - 항상 입력 받은 태그 전부 표시
     글추가 입력된 태그 표시
        - 기존 태그와 비교해 중복되면 맨 왼쪽에 추가 후 기존 태그 제거
     글추가 관련태그 표시
        - 최대 5개 표시 3줄이 넘어가면 그 이후 태그 제거
     
     현재 태그와 새로운 태그를 비교해,
        1. 삭제할 태그가 있다면 삭제
        2. 추가할 태그가 있다면 추가
        3. 태그의 순서가 바뀌었다면 태그의 순서 변경
        4. 현재 태그가 비어있다면 새로운 태그를 컬랙션 뷰에 표시
     */
    func setModels(_ models: [SOMTagModel]) {
        
        guard models.isEmpty == false else {
            self.models = []
            self.collectionView.reloadData()
            return
        }
        
        let current = self.models
        let new = models
        /// 변경사항이 없다면 종료
        guard current != new else { return }
        
        /// 새로운 태그가 유효한지 확인 (중복 여부 확인)
        let deduplicatedNew = Set(new)
        if new.count != deduplicatedNew.count {
            print("⚠️ 중복된 태그가 존재합니다. 태그의 순서를 유지하고 중복된 태그를 제거합니다.")
        }
        /// 현재 태그 배열에서 삭제되어야 할 태그 및 삽입되어야 할 태그 찾기
        let deleted = Set(current).subtracting(new)
        let inserted = deduplicatedNew.subtracting(current)
        /// 삭제 또는 삽입 되어야 할 태그 인덱스
        let deletedIndices = current.enumerated()
            .filter { deleted.contains($0.element) }
            .map { IndexPath(item: $0.offset, section: 0) }
        let insertedIndices = new.enumerated()
            .filter { inserted.contains($0.element) }
            .map { IndexPath(item: $0.offset, section: 0) }
        /// 변경되어야 할 인덱스
        var moveIndeces: [(from: Int, to: Int)] = []
        if current.count + new.count > 0, deletedIndices.isEmpty, insertedIndices.isEmpty {
            for currentItemIndex in 0..<current.count {
                let currentItem = current[currentItemIndex]
                if let newItemIndex = new.firstIndex(of: currentItem),
                   currentItemIndex > newItemIndex {
                    moveIndeces.append((currentItemIndex, newItemIndex))
                }
            }
        }
        
        self.models = new
        
        /// 삭제되어야 할 태그 삭제, 추가되어야 할 태그 추가, 태그 순서 변경, 모델 업데이트
        if current.isEmpty == false {
            self.collectionView.performBatchUpdates {
                self.collectionView.deleteItems(at: deletedIndices)
                self.collectionView.insertItems(at: insertedIndices)
                moveIndeces.forEach {
                    self.collectionView.moveItem(
                        at: .init(item: $0.from, section: 0),
                        to: .init(item: $0.to, section: 0)
                    )
                }
            }
        } else {
            self.collectionView.reloadData()
        }
    }
}

extension SOMTags: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let tag: SOMTag = collectionView.dequeueReusableCell(
            withReuseIdentifier: SOMTag.cellIdentifier,
            for: indexPath
        ) as! SOMTag

        let model = self.models[indexPath.item]
        tag.setModel(model, direction: self.configuration.direction)
        
        tag.delegate = self

        return tag
    }
}

extension SOMTags: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = self.models[indexPath.row]
        if model.isSelectable {
            self.delegate?.tags(self, didTouch: model)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let typography: Typography = .som.body2WithRegular
        let model = self.models[indexPath.item]
        
        var tagSize: CGSize {
            
            let leadingOffset: CGFloat = self.configuration.direction == .horizontal ? 16 : 10
            
            let removeButtonWidth: CGFloat = model.isRemovable ? 16 + 8 : 0 /// 버튼 width + spacing
            
            let textWidth: CGFloat = (model.text as NSString).size(
                withAttributes: [.font: typography.font]
            ).width
            
            var countWidth: CGFloat = 0 /// text width + spacing
            if let count = model.count {
                countWidth = (count as NSString).size(withAttributes: [.font: typography.font]).width
                countWidth += 2
            }
            
            let traillingOffset: CGFloat = self.configuration.direction == .horizontal ? 16 : 6
            
            let tagWidth: CGFloat = leadingOffset + removeButtonWidth + ceil(textWidth) + ceil(countWidth) + traillingOffset
            let tagHeight: CGFloat = self.configuration.direction == .horizontal ? 30 : 32
            return CGSize(width: tagWidth, height: tagHeight)
        }
        
        return tagSize
    }
}

extension SOMTags: SOMTagDelegate {
    
    func tag(_ tag: SOMTag, didRemoveSelect model: SOMTagModel) {
        var models = self.models
        models.removeAll(where: { $0 == model })
        self.setModels(models)
        self.delegate?.tags(self, didRemove: model)
    }
}
