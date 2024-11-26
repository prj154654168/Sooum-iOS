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

final class FavoriteTagTableViewCell: UITableViewCell {
    
    let favoriteTagView = FavoriteTagView()
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.clipsToBounds = true
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraint() {
        self.contentView.addSubview(favoriteTagView)
        favoriteTagView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
}
