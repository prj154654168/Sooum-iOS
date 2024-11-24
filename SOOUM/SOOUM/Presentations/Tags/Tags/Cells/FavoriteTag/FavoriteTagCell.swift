//
//  FavoriteTagCell.swift
//  SOOUM
//
//  Created by JDeoks on 11/24/24.
//

import UIKit

import RxCocoa
import RxGesture
import RxSwift

final class FavoriteTagCell: UITableViewCell {
    
    let tagNameLabel = UILabel().then {
        $0.typography = .som.body3WithBold
        $0.text = "#태그이름"
        $0.textColor = .som.gray800
    }
    
    let tagsCountLabel = UILabel().then {
        $0.typography = .som.body3WithBold
        $0.text = "999"
        $0.textColor = .som.gray500
    }
    
    let moreButtonStackView = UIStackView().then {
        $0.axis = .horizontal
    }
    
    let moreButtonLabel = UILabel().then {
        $0.typography = .som.body3WithBold
        $0.text = "더보기"
        $0.textColor = .som.blue300
    }
    
    let moreImageView = UIImageView().then {
        $0.image = .next
        $0.tintColor = .som.blue300
    }
    
    let cardPreviewCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.scrollDirection = .horizontal
        }).then {
            $0.backgroundColor = .red
        }
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.layer.cornerRadius = 28
        self.layer.borderColor = UIColor.som.gray200.cgColor
        self.layer.borderWidth = 1
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraint() {
        self.contentView.addSubview(tagNameLabel)
        tagNameLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(20)
            $0.height.equalTo(17)
        }
        
        self.contentView.addSubview(tagsCountLabel)
        tagsCountLabel.snp.makeConstraints {
            $0.leading.equalTo(self.tagNameLabel.snp.trailing)
            $0.top.equalTo(self.tagNameLabel)
            $0.height.equalTo(17)
        }
        
        self.contentView.addSubview(moreButtonStackView)
        moreButtonStackView.addArrangedSubviews(moreButtonLabel, moreImageView)
        moreButtonStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(20)
            $0.height.equalTo(17)
        }
        
        self.addSubview(cardPreviewCollectionView)
        cardPreviewCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(tagNameLabel.snp.bottom).offset(15)
            $0.bottom.equalToSuperview().offset(-15)
        }
    }
}
