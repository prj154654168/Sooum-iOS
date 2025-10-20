//
//  WriteCardUserImageCell.swift
//  SOOUM
//
//  Created by 오현식 on 10/10/25.
//

import UIKit

import SnapKit
import Then

class WriteCardUserImageCell: UICollectionViewCell {
    
    static let cellIdentifier = String(reflecting: WriteCardUserImageCell.self)
    
    
    // MARK: Views
    
    private let cameraImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.filled(.camera))))
        $0.tintColor = .som.v2.gray400
    }
    
    
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
        
        self.contentView.backgroundColor = .som.v2.gray100
        
        self.contentView.addSubview(self.cameraImageView)
        self.cameraImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
