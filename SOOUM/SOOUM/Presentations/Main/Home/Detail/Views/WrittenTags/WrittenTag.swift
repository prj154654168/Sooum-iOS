//
//  WrittenTag.swift
//  SOOUM
//
//  Created by 오현식 on 11/2/25.
//

import UIKit

import SnapKit
import Then

class WrittenTag: UICollectionViewCell {
    
    static let cellIdentifier = String(reflecting: WrittenTag.self)
    
    
    // MARK: Views
    
    private let imageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.hash))))
        $0.tintColor = .som.v2.gray300
    }
    
    private let label = UILabel().then {
        $0.textColor = .som.v2.white
        $0.typography = .som.v2.caption2
    }
    
    
    // MARK: Variables
    
    private(set) var model: WrittenTagModel?
    
    
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
        
        self.contentView.backgroundColor = .som.v2.dim
        self.contentView.layer.cornerRadius = 6
        self.contentView.clipsToBounds = true
        
        self.contentView.addSubview(self.imageView)
        self.imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
            $0.size.equalTo(14)
        }
        
        self.contentView.addSubview(self.label)
        self.label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.imageView.snp.trailing).offset(2)
            $0.trailing.equalToSuperview().offset(-8)
        }
    }
    
    
    // MARK: Public func
    
    func setModel(_ model: WrittenTagModel) {
        
        self.model = model
        
        self.label.text = model.originalText
        self.label.typography = model.typography
    }
}
