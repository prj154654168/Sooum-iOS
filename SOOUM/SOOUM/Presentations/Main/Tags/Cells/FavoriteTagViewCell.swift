//
//  FavoriteTagViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 11/19/25.
//

import UIKit

import SnapKit
import Then

import RxCocoa
import RxSwift

class FavoriteTagViewCell: UICollectionViewCell {
    
    static let cellIdentifier = String(reflecting: FavoriteTagViewCell.self)
    
    
    // MARK: Views
    
    private let container = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .top
        $0.distribution = .equalSpacing
        $0.spacing = 0
    }
    
    
    // MARK: Variables
    
    private(set) var model: FavoriteTagsViewModel?
    
    let favoriteIconDidTap = PublishRelay<FavoriteTagViewModel>()
    let backgroundDidTap = PublishRelay<FavoriteTagViewModel>()
    
    var disposeBag = DisposeBag()
    
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Override func
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.container.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        self.disposeBag = DisposeBag()
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.container)
        self.container.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            /// trailing padding + iconView padding
            let offset = 16 + 12
            $0.trailing.equalToSuperview().offset(-offset)
        }
    }
    
    
    // MARK: Public func
    
    func setModels(_ model: FavoriteTagsViewModel) {
        
        self.model = model
        
        self.container.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        model.tags.forEach { model in
            
            let label = UILabel().then {
                $0.text = model.text
                $0.textColor = .som.v2.gray600
                $0.typography = .som.v2.subtitle1
            }
            
            let iconView = UIImageView().then {
                $0.image = .init(.icon(.v2(.filled(.star))))
                $0.tintColor = model.isFavorite ? .som.v2.yMain : .som.v2.gray200
            }
            
            let separator = UIView().then {
                $0.backgroundColor = .som.v2.gray200
            }
            
            let itemContainer = UIView()
            itemContainer.addSubview(label)
            label.snp.makeConstraints {
                $0.centerY.leading.equalToSuperview()
            }
            itemContainer.addSubview(iconView)
            iconView.snp.makeConstraints {
                $0.centerY.trailing.equalToSuperview()
                $0.size.equalTo(24)
            }
            itemContainer.addSubview(separator)
            separator.snp.makeConstraints {
                $0.bottom.horizontalEdges.equalToSuperview()
                $0.height.equalTo(1)
            }
            self.container.addArrangedSubview(itemContainer)
            itemContainer.snp.makeConstraints {
                $0.width.equalTo(UIScreen.main.bounds.width - 16 * 2 - 12)
                $0.height.equalTo(48)
            }
            
            itemContainer.rx.tapGesture()
                .when(.recognized)
                .subscribe(with: self) { object, gesture in
                    guard itemContainer.isTappedDirectly(gesture: gesture) else { return }
                    
                    object.backgroundDidTap.accept(model)
                }
                .disposed(by: self.disposeBag)
            
            iconView.rx.tapGesture()
                .when(.recognized)
                .subscribe(with: self.favoriteIconDidTap) { favoriteIconDidTap, _ in
                    favoriteIconDidTap.accept(model)
                }
                .disposed(by: self.disposeBag)
        }
    }
}
