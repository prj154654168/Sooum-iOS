//
//  SelectDefaultImageTableViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 10/16/24.
//

import UIKit

import SnapKit
import Then

import RxCocoa
import RxGesture
import RxSwift

class SelectDefaultImageTableViewCell: UITableViewCell {
    
    var defaultImages: [ImageWithName] = []
    var selectedDefaultImage: BehaviorRelay<(idx: Int, imageWithName: ImageWithName?)>?
        
    var disposeBag = DisposeBag()

    private let flowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 0
        $0.minimumInteritemSpacing = 0
    }
    
    // 이미지 컬렉션 뷰 설정
    lazy var imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.isScrollEnabled = false
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        $0.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: ImageCollectionViewCell.self))
        $0.dataSource = self
        $0.delegate = self
    }

    // 초기화 코드
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    // MARK: - setData
    func setData(imageWithNames: [ImageWithName], selectedDefaultImage: BehaviorRelay<(idx: Int, imageWithName: ImageWithName?)>) {        
        self.defaultImages = imageWithNames
        self.selectedDefaultImage = selectedDefaultImage
        
        bind()
        
        imageCollectionView.reloadData()
    }
    
    // MARK: - setData
    private func bind() {
        selectedDefaultImage?
            .subscribe(with: self, onNext: { object, _ in
                object.imageCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    // 뷰 설정
    private func setupConstraint() {
        contentView.addSubview(imageCollectionView)
        
        // AutoLayout 설정
        imageCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-18)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            let numberOfRows: CGFloat = 2    // 두 줄
            let cellHeight: CGFloat = (UIScreen.main.bounds.width - 40) / 4  // 가로 4개로 나눈 셀의 높이 (셀 높이 = 셀 너비)
            let totalHeight = cellHeight * numberOfRows
            make.height.equalTo(totalHeight)
        }
    }
}


// MARK: - UICollectionView
extension SelectDefaultImageTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        let idx = indexPath.item
        if defaultImages.indices.contains(idx) {
            cell.setData(idx: idx, imageWithName: defaultImages[idx], selectedDefaultImage: selectedDefaultImage)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfCellsPerRow: CGFloat = 4
        let width = collectionView.frame.width / numberOfCellsPerRow
        return CGSize(width: width, height: width)
    }
}
