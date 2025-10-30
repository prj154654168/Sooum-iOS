//
//  WriteCardDefaultImageCell.swift
//  SOOUM
//
//  Created by 오현식 on 10/10/25.
//

import UIKit

import SnapKit
import Then

class WriteCardDefaultImageCell: UICollectionViewCell {
    
    static let cellIdentifier = String(reflecting: WriteCardDefaultImageCell.self)
    
    
    // MARK: Views
    
    private let imageView = UIImageView()
    
    private let checkBackgroundDimView = UIView().then {
        $0.backgroundColor = .som.v2.black.withAlphaComponent(0.3)
        $0.isHidden = true
    }
    
    private let checkBackgroundView = UIView().then {
        $0.backgroundColor = .som.v2.white
        $0.layer.borderColor = UIColor.som.v2.pMain.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 32 * 0.5
        $0.clipsToBounds = true
        $0.isHidden = true
    }
    
    private let checkImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.check))))
        $0.tintColor = .som.v2.pMain
    }
    
    
    // MARK: Variables
    
    private(set) var model: ImageUrlInfo = .defaultValue
    
    override var isSelected: Bool {
        didSet {
            self.checkBackgroundDimView.isHidden = self.isSelected == false
            self.checkBackgroundView.isHidden = self.isSelected == false
        }
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
        
        self.contentView.addSubview(self.imageView)
        self.imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.contentView.addSubview(self.checkBackgroundDimView)
        self.checkBackgroundDimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.checkBackgroundView.addSubview(self.checkImageView)
        self.checkImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        self.contentView.addSubview(self.checkBackgroundView)
        self.checkBackgroundView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(32)
        }
    }
    
    
    // MARK: Public func
    
    func setModel(_ model: ImageUrlInfo) {
        
        self.model = model
        self.imageView.setImage(strUrl: model.imgUrl, with: model.imgName)
    }
}
