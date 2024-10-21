//
//  SOMTag.swift
//  SOOUM
//
//  Created by 오현식 on 10/1/24.
//

import UIKit

import SnapKit
import Then


class SOMTag: UICollectionViewCell {
    
    static let cellIdentifier = String(reflecting: SOMTag.self)
    
    private(set) var model: SOMTagModel?
    
    private let label = UILabel().then {
        $0.textColor = .som.gray01
        $0.typography = .init(
            fontContainer: BuiltInFont(size: 14, weight: .medium),
            lineHeight: 22,
            letterSpacing: -0.04
        )
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        self.contentView.backgroundColor = .som.gray04
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 4
        
        self.contentView.addSubview(self.label)
        self.label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(16)
        }
    }
    
    func setModel(_ model: SOMTagModel) {
        
        self.model = model
        self.label.text = model.text
    }
}
