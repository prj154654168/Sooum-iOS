//
//  ImageCollectionViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 10/16/24.
//

import UIKit

import RxCocoa
import RxGesture
import RxSwift

class ImageCollectionViewCell: UICollectionViewCell {
    
    /// 현재 셀 인덱스
    var idx: Int?
    /// 현재 셀 이미지
    var imageWithName: ImageWithName?
    /// 넘겨받은 현재선택 인덱스&이미지
    var selectedDefaultImage: BehaviorRelay<(idx: Int, imageWithName: ImageWithName?)>?

    var disposeBag = DisposeBag()
    
    private let imageView = UIImageView().then {
        $0.backgroundColor = .som.gray200
        $0.layer.borderColor = UIColor.som.p300.cgColor
        $0.layer.borderWidth = 0
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    // MARK: - setData
    func setData(idx: Int, imageWithName: ImageWithName?, selectedDefaultImage: BehaviorRelay<(idx: Int, imageWithName: ImageWithName?)>?) {
        self.idx = idx
        self.imageWithName = imageWithName
        self.selectedDefaultImage = selectedDefaultImage
        
        action()
        imageView.image = imageWithName?.image
        applyCornerRadius(for: idx)
        updateBorderColor()
    }
    
    // MARK: - action
    private func action() {
        imageView.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self) { object, _ in
                if let idx = object.idx, let imageWithName = object.imageWithName {
                    object.selectedDefaultImage?.accept((idx: idx, imageWithName: imageWithName))
                    object.updateBorderColor()
                }
            }
            .disposed(by: disposeBag)
    }
    
    /// 부분 곡률 설정
    private func applyCornerRadius(for idx: Int) {
        let cornerRadius: CGFloat = 10
        
        imageView.layer.cornerRadius = cornerRadius
        imageView.layer.maskedCorners = []
        
        switch idx {
        case 0:
            imageView.layer.maskedCorners = [.layerMinXMinYCorner]
        case 3:
            imageView.layer.maskedCorners = [.layerMaxXMinYCorner]
        case 4:
            imageView.layer.maskedCorners = [.layerMinXMaxYCorner]
        case 7:
            imageView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        default:
            imageView.layer.maskedCorners = []
        }
    }
    
    /// 테두리 색 업데이트
    func updateBorderColor() {
        if let idx = self.idx, let selectedIdx = selectedDefaultImage?.value.idx {
            imageView.layer.borderWidth = idx == selectedIdx ? 2 : 0
        }
    }
}
