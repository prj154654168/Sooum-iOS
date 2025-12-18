//
//  WriteCardTag.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/25.
//

import UIKit

import SnapKit
import Then

protocol WriteCardTagDelegate: AnyObject {
    func tag(_ tag: WriteCardTag, didRemoveSelect model: WriteCardTagModel)
}

class WriteCardTag: UICollectionViewCell {
    
    static let cellIdentifier = String(reflecting: WriteCardTag.self)
    
    
    // MARK: Views
    
    private let imageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.outlined(.hash))))
        $0.tintColor = .som.v2.gray300
    }
    
    private let label = UILabel().then {
        $0.textColor = .som.v2.white
        $0.typography = .som.v2.caption2
    }
    
    private lazy var removeButton = SOMButton().then {
        $0.image = .init(.icon(.v2(.outlined(.delete))))
        $0.foregroundColor = .som.v2.gray300
        
        $0.addTarget(self, action: #selector(self.remove), for: .touchUpInside)
    }
    
    
    // MARK: Variables
    
    private(set) var model: WriteCardTagModel?
    
    
    // MARK: Delegate
    
    weak var delegate: WriteCardTagDelegate?
    
    
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
        }
        
        self.contentView.addSubview(self.removeButton)
        self.removeButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.label.snp.trailing).offset(2)
            $0.trailing.equalToSuperview().offset(-8)
            $0.size.equalTo(16)
        }
    }
    
    
    // MARK: Objc func
    
    @objc
    private func remove(_ button: UIButton) {
        guard let model = self.model else { return }
        self.delegate?.tag(self, didRemoveSelect: model)
    }
    
    
    // MARK: Public func
    
    func setModel(_ model: WriteCardTagModel) {
        
        self.model = model
        
        self.label.text = model.originalText
        self.label.typography = model.typography
    }
}
