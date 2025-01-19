//
//  FavoriteTagView.swift
//  SOOUM
//
//  Created by JDeoks on 11/24/24.
//

import UIKit

class FavoriteTagView: UIView {
    
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
        $0.image = .init(.icon(.outlined(.next)))
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .som.blue300
    }
    
    let cardPreviewCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.scrollDirection = .horizontal
        }
    ).then {
        $0.showsHorizontalScrollIndicator = false
    }

    // MARK: - init
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.layer.cornerRadius = 28
        self.layer.borderColor = UIColor.som.gray200.cgColor
        self.layer.borderWidth = 1
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraint() {
        self.addSubview(tagNameLabel)
        tagNameLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(20)
            $0.height.equalTo(17)
        }
        
        self.addSubview(tagsCountLabel)
        tagsCountLabel.snp.makeConstraints {
            $0.leading.equalTo(self.tagNameLabel.snp.trailing).offset(2)
            $0.top.equalTo(self.tagNameLabel)
            $0.height.equalTo(17)
        }
        
        self.addSubview(moreButtonStackView)
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
