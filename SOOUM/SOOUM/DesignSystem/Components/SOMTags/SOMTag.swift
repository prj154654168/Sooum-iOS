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
    
    private lazy var removeButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .init(.image(.cancel))
        $0.configuration = config
        
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        
        $0.addTarget(self, action: #selector(self.remove), for: .touchUpInside)
    }
    
    private let label = UILabel().then {
        $0.textColor = .som.gray500
        $0.typography = .init(
            fontContainer: BuiltInFont(size: 14, weight: .medium),
            lineHeight: 22,
            letterSpacing: -0.04
        )
    }
    
    var removeButtonWidthConstraint: Constraint?
    var betweenSpacing: Constraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        self.contentView.layer.borderWidth = 0.8
        self.contentView.layer.cornerRadius = 4
        self.contentView.clipsToBounds = true
        
        self.contentView.addSubview(self.removeButton)
        self.removeButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            self.removeButtonWidthConstraint = $0.width.equalTo(16).constraint
            $0.height.equalTo(16)
        }
        
        self.contentView.addSubview(self.label)
        self.label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            self.betweenSpacing = $0.leading.equalTo(self.removeButton.snp.trailing).offset(8).constraint
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
    
    @objc
    private func remove(_ button: UIButton) {
        guard let model = self.model else { return }
        self.delegate?.tag(self, didRemoveSelect: model)
    }
    
    private func updateBackground(direction: UICollectionView.ScrollDirection) {
        
        self.contentView.backgroundColor = direction == .horizontal ? .som.gray200 : .white
        self.contentView.layer.borderColor = direction == .horizontal ? UIColor.som.gray200.cgColor : UIColor.som.gray200.cgColor
    }
    
    func setModel(_ model: SOMTagModel) {
        
        self.model = model
        if let count = model.count {
            let string = model.text + " \(count)"
            let attributedString = NSMutableAttributedString(string: string).then {
                let textColor = UIColor.som.primary
                let typography = Typography(
                    fontContainer: BuiltInFont(size: 15, weight: .medium),
                    lineHeight: 24,
                    letterSpacing: -0.04
                )
                let range = (count as NSString).range(of: model.text)
                $0.addAttributes([.foregroundColor: textColor, .font: typography.font], range: range)
            }
            self.label.attributedText = attributedString
        } else {
            self.label.text = model.text
        }
        self.updateBackground(direction: model.configuration.direction)
        self.removeButtonWidthConstraint?.update(offset: model.isRemovable ? 16 : 0)
        self.betweenSpacing?.update(offset: model.isRemovable ? 8 : 0)
    }
}
