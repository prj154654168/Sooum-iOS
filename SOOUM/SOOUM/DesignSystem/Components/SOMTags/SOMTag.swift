//
//  SOMTag.swift
//  SOOUM
//
//  Created by 오현식 on 10/1/24.
//

import UIKit

import SnapKit
import Then


protocol SOMTagDelegate: AnyObject {
    func tag(_ tag: SOMTag, didRemoveSelect model: SOMTagModel)
}

class SOMTag: UICollectionViewCell {
    
    static let cellIdentifier = String(reflecting: SOMTag.self)
    
    private(set) var model: SOMTagModel?
    
    weak var delegate: SOMTagDelegate?
    
    private lazy var removeButton = SOMButton().then {
        $0.image = .init(.image(.defaultStyle(.cancelTag)))
        
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        
        $0.addTarget(self, action: #selector(self.remove), for: .touchUpInside)
    }
    
    private let label = UILabel().then {
        $0.textColor = .som.gray600
        $0.typography = .som.body2WithRegular
    }
    
    var removeButtonLeadingConstraint: Constraint?
    var removeButtonWidthConstraint: Constraint?
    var betweenSpacing: Constraint?
    var labelTrailingConstraint: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        self.contentView.layer.borderColor = UIColor.som.gray200.cgColor
        self.contentView.layer.borderWidth = 0.8
        self.contentView.layer.cornerRadius = 4
        self.contentView.clipsToBounds = true
        
        self.contentView.addSubview(self.removeButton)
        self.removeButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            self.removeButtonLeadingConstraint = $0.leading.equalToSuperview().offset(16).constraint
            self.removeButtonWidthConstraint = $0.width.equalTo(16).constraint
            $0.size.equalTo(16)
        }
        
        self.contentView.addSubview(self.label)
        self.label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            self.betweenSpacing = $0.leading.equalTo(self.removeButton.snp.trailing).offset(8).constraint
            self.labelTrailingConstraint = $0.trailing.equalToSuperview().offset(-16).constraint
            $0.height.equalTo(20)
        }
    }
    
    @objc
    private func remove(_ button: UIButton) {
        guard let model = self.model else { return }
        self.delegate?.tag(self, didRemoveSelect: model)
    }
    
    private func updateBackground(direction: UICollectionView.ScrollDirection) {
        
        self.contentView.backgroundColor = direction == .horizontal ? .som.gray200 : .clear
    }
    
    func setModel(_ model: SOMTagModel, direction: UICollectionView.ScrollDirection) {
        
        self.model = model
        if let count = model.count {
            let typography = Typography.som.body2WithRegular
            let string = model.text + " \(count)"
            let attributedString = NSMutableAttributedString(
                string: string,
                attributes: typography.attributes
            ).then {
                let textColor = UIColor.som.p300
                let range = (string as NSString).range(of: count)
                $0.addAttribute(.foregroundColor, value: textColor, range: range)
            }
            self.label.attributedText = attributedString
        } else {
            self.label.text = model.text
        }
        
        let isHorizontal = direction == .horizontal
        self.contentView.backgroundColor = isHorizontal ? .som.gray200 : .clear
        
        self.removeButtonLeadingConstraint?.update(offset: isHorizontal ? 16 : 10)
        self.removeButtonWidthConstraint?.update(offset: model.isRemovable ? 16 : 0)
        self.betweenSpacing?.update(offset: model.isRemovable ? 8 : 0)
        self.labelTrailingConstraint?.update(offset: isHorizontal ? -16 : -6)
    }
}
