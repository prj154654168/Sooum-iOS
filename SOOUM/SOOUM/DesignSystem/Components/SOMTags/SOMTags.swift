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
    
    private let flowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumInteritemSpacing = 10
        $0.sectionInset = UIEdgeInsets(top: 12, left: 20, bottom: 17, right: 0)
    }
    
    lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: self.flowLayout
    ).then {
        $0.alwaysBounceHorizontal = true
        
        $0.contentInsetAdjustmentBehavior = .never
        $0.contentInset = .zero
        
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        
        $0.alwaysBounceVertical = self.flowLayout.scrollDirection == .vertical
        $0.alwaysBounceHorizontal = self.flowLayout.scrollDirection == .horizontal
        
        $0.isScrollEnabled = self.flowLayout.scrollDirection == .horizontal
        
        $0.register(SOMTag.self, forCellWithReuseIdentifier: SOMTag.cellIdentifier)
        
        $0.dataSource = self
        $0.delegate = self
    }
    
    private(set) var models = [SOMTagModel]()
    
    weak var delegate: SOMTagsDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        guard !models.isEmpty else {
            self.models = []
            self.collectionView.reloadData()
            return
        }
        
        /// flowLayout 옵션 한 번만 업데이트
        guard let configuration = models.first?.configuration else { return }
        if self.flowLayout.scrollDirection != configuration.direction {
            self.flowLayout.scrollDirection = configuration.direction
        }
        if self.flowLayout.minimumInteritemSpacing != configuration.interSpacing {
            self.flowLayout.minimumInteritemSpacing = configuration.interSpacing
        }
        if self.flowLayout.minimumLineSpacing != configuration.lineSpacing {
            self.flowLayout.minimumLineSpacing = configuration.lineSpacing
        }
        if self.flowLayout.sectionInset != configuration.inset {
            self.flowLayout.sectionInset = configuration.inset
        }
        
        let current = self.models
        let new = Array(NSOrderedSet(array: models)) as! [SOMTagModel]
        /// 중복 제거
        let deduplicatedCurrent = Set(current)
        let deduplicatedNew = Set(new)
        /// 변경사항이 없다면 종료
        guard deduplicatedCurrent != deduplicatedNew else { return }
        /// 새로운 태그가 유효한지 확인 (중복 여부 확인)
        let isValid: Bool = models.count == deduplicatedNew.count
        if !isValid { print("⚠️ 중복된 태그가 존재합니다. 태그의 순서를 유지하고 중복된 태그를 제거합니다.") }
        /// 현재 태그 배열에서 삭제되어야 할 태그 및 삽입되어야 할 태그 찾기
        let deleted = deduplicatedCurrent.subtracting(deduplicatedNew)
        let inserted = deduplicatedNew.subtracting(deduplicatedCurrent)
        /// 삭제 또는 삽입 되어야 할 태그 인덱스
        let deletedIndices = current.enumerated()
            .filter { deleted.contains($0.element) }
            .map { IndexPath(item: $0.offset, section: 0) }
        let insertedIndices = new.enumerated()
            .filter { inserted.contains($0.element) }
            .map { IndexPath(item: $0.offset, section: 0) }
        
        /// 삭제되어야 할 태그 삭제, 추가되어야 할 태그 추가, 태그 순서 변경, 후에 모델이 업데이트 되었으면 리로드, 모델 업데이트
        if !deletedIndices.isEmpty || !insertedIndices.isEmpty {
            self.collectionView.performBatchUpdates {
                if !deletedIndices.isEmpty {
                    self.collectionView.deleteItems(at: deletedIndices)
                    self.models.removeAll(where: { deleted.contains($0) })
                }
                
                if !insertedIndices.isEmpty {
                    self.collectionView.insertItems(at: insertedIndices)
                    inserted.forEach { self.models.insert($0, at: 0) }
                }
            } completion: { _ in
                if self.collectionView.numberOfItems(inSection: 0) != self.models.count {
                    self.collectionView.reloadData()
                }
            }
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
        tag.setModel(model)
        
        tag.delegate = self

        return tag
    }
}

extension SOMTags: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = self.models[indexPath.row]
        self.delegate?.tags(self, didTouch: model)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return self.models[indexPath.item].tagSize
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
