//
//  SOMLocationFilterCollectionViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 9/19/24.
//

import UIKit

import SnapKit
import Then

class SOMLocationFilterCollectionViewCell: UICollectionViewCell {
    
    /// 거리 범위 텍스트 표시하는 라벨
    let label = UILabel().then {
        $0.typography = .init(
            fontContainer: Pretendard(size: 12, weight: .regular),
            lineHeight: 14,
            letterSpacing: 0.07
        )
        $0.textColor = .som.primary
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(distance: SOMLocationFilter.Distance, isSelected: Bool) {
        label.text = distance.text
        label.textColor = isSelected ? .som.primary : .som.gray01
        contentView.layer.borderColor = isSelected 
            ? UIColor.som.primary.cgColor
            : UIColor.som.gray02.cgColor
    }
    
    // MARK: - initUI
    private func initUI() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = contentView.frame.height / 2
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.som.primary.cgColor
        addSubviews()
        initConstraint()
    }
    
    private func addSubviews() {
        self.addSubview(label)
    }
    
    // MARK: - initConstraint
    private func initConstraint() {
        label.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
