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
        $0.backgroundColor = .som.gray04
        $0.layer.borderColor = UIColor.som.gray03.cgColor
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
    func setData(idx: Int, imageURLStr: String) {
        imageView.setImage(strUrl: imageURLStr)
        applyCornerRadius(for: idx)
    }
    
    private func applyCornerRadius(for idx: Int) {
         let cornerRadius: CGFloat = 10
         
         imageView.layer.cornerRadius = cornerRadius
         imageView.layer.maskedCorners = [] // 초기화
         
         switch idx {
         case 0:
             imageView.layer.maskedCorners = [.layerMinXMinYCorner] // 왼쪽 위
         case 3:
             imageView.layer.maskedCorners = [.layerMaxXMinYCorner] // 오른쪽 위
         case 4:
             imageView.layer.maskedCorners = [.layerMinXMaxYCorner] // 왼쪽 아래
         case 7:
             imageView.layer.maskedCorners = [.layerMaxXMaxYCorner] // 오른쪽 아래
         default:
             imageView.layer.maskedCorners = []
         }
     }}
