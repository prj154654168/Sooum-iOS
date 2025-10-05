//
//  ProfileViewFooterCell.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/24.
//

import UIKit

import SnapKit
import Then


class ProfileViewFooterCell: UICollectionViewCell {
    
    static let cellIdentifier = String(reflecting: ProfileViewFooterCell.self)
    
    private let backgroundImageView = UIImageView()
    
    private let backgroundDimView = UIView().then {
        $0.backgroundColor = .som.black.withAlphaComponent(0.2)
    }
    
    private let contentLabel = UILabel().then {
        $0.textColor = .som.white
        $0.textAlignment = .center
        $0.typography = .som.body3WithRegular
        $0.numberOfLines = 0
        $0.lineBreakMode = .byTruncatingTail
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.backgroundImageView.image = nil
        self.contentLabel.text = nil
    }
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.backgroundImageView)
        self.backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.backgroundImageView.addSubview(self.backgroundDimView)
        self.backgroundDimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.backgroundImageView.addSubview(self.contentLabel)
        self.contentLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(10)
            $0.bottom.trailing.equalToSuperview().offset(-10)
        }
    }
    
    func setModel(_ writtenCard: WrittenCard) {
        self.backgroundImageView.setImage(strUrl: writtenCard.backgroundImgURL.url, with: "")
        self.contentLabel.typography = writtenCard.font == .pretendard ? .som.body3WithRegular : .som.schoolBody1WithLight
        self.contentLabel.text = writtenCard.content
        self.contentLabel.textAlignment = .center
    }
}
