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
        
        $0.register(SOMTag.self, forCellWithReuseIdentifier: SOMTag.cellIdentifier)
        
        $0.dataSource = self
        $0.delegate = self
    }
    
    private(set) var models = [SOMTagModel]()
    
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
     현재 태그와 새로운 태그를 비교해,
        1. 삭제할 태그가 있다면 삭제
        2. 추가할 태그가 있다면 추가
        3. 태그의 순서가 바뀌었다면 태그의 순서 변경
        4. 현재 태그가 비어있다면 새로운 태그를 컬랙션 뷰에 표시
     */
    func setDatas(_ models: [SOMTagModel]) {
        
        let current = self.models
        let new = models
        /// 변경사항이 없다면 종료
        guard current != new else { return }
        /// 새로운 태그가 유효한지 확인 (중복 여부 확인)
        let isValid: Bool = new.count == Set(new).count
        /// TODO: 추후 Log 클래스를 정의하면 수정
        if !isValid { print("⚠️ 중복된 태그가 존재합니다.") }
        /// 현재 태그 배열에서 삭제되어야 할 태그 찾기
        let deduplicatedNew = Set(new)
        let deleted = current.filter { deduplicatedNew.contains($0) }
        let deletedIndices: [(offset: Int, element: SOMTagModel)] = current.enumerated().filter { deleted.contains($0.element) }
        /// 새로운 태그 배열에서 추가되어야 할 태그 찾기
        let deduplicatedCurrent = Set(current)
        let inserted = new.filter { !deduplicatedCurrent.contains($0) }
        let insertedIndices: [(offset: Int, element: SOMTagModel)] = new.enumerated().filter { inserted.contains($0.element) }
        
        /// 새로운 요소나 삭제된 요소가 없고, current와 new 배열의 순서만 다를 때 new에 맞게 정렬
        var moveIndeces: [(from: Int, to: Int)] = []
        if current.count + new.count > 0, deletedIndices.isEmpty, insertedIndices.isEmpty {
            for currentItemIndex in 0..<current.count {
                let currentItem: SOMTagModel = current[currentItemIndex]
                if let newItemIndex: Int = new.firstIndex(of: currentItem),
                   currentItemIndex > newItemIndex {
                    moveIndeces.append((currentItemIndex, newItemIndex))
                }
            }
        }
        /// 모델 업데이트
        self.models = new
        
        /// 삭제되어야 할 태그 삭제, 추가되어야 할 태그 추가, 태그 순서 변경
        if !current.isEmpty, isValid {
            self.collectionView.performBatchUpdates {
                self.collectionView.deleteItems(
                    at: deletedIndices.map { .init(item: $0.offset, section: 0) }
                )
                self.collectionView.insertItems(
                    at: insertedIndices.map { .init(item: $0.offset, section: 0) }
                )
                moveIndeces.forEach {
                    self.collectionView.moveItem(
                        at: .init(item: $0.from, section: 0),
                        to: .init(item: $0.to, section: 0)
                    )
                }
            }
        }
        
        self.collectionView.reloadData()
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

        return tag
    }
}

extension SOMTags: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return self.models[indexPath.item].tagSize
    }
}
