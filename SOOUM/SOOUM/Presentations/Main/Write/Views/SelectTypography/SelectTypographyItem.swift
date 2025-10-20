//
//  SelectTypographyItem.swift
//  SOOUM
//
//  Created by 오현식 on 10/10/25.
//

import UIKit

import SnapKit
import Then

class SelectTypographyItem: UIView {
    
    
    // MARK: Views
    
    private let label = UILabel().then {
        $0.textColor = .som.v2.gray600
    }
    
    
    // MARK: Variables
    
    var isSelected: Bool = false {
        didSet {
            self.backgroundColor = self.isSelected ? .som.v2.pLight1 : .som.v2.gray100
            let borderColor: UIColor = self.isSelected ? .som.v2.pMain : .som.v2.gray100
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    
    // MARK: Initialize
    
    convenience init(title: String, typography: Typography) {
        self.init(frame: .zero)
        
        self.label.text = title
        self.label.typography = typography
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.backgroundColor = .som.v2.gray100
        self.layer.borderColor = UIColor.som.v2.gray100.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10
        
        self.clipsToBounds = true
        
        self.addSubview(self.label)
        self.label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
