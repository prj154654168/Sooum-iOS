//
//  ImageCollectionViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 10/16/24.
//

import Foundation
import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    // 이미지 뷰
    private let imageView = UIImageView().then {
        $0.backgroundColor = .som.gray03
        $0.layer.borderColor = UIColor.som.gray02.cgColor
        $0.layer.borderWidth = 1
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
    
    // 이미지 설정 메서드
    func setData(image: UIImage) {
        imageView.image = image
    }
}
