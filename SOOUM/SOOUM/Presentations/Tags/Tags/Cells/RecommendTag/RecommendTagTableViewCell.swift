//
//  RecommendTagTableViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 11/26/24.
//

import UIKit

class RecommendTagTableViewCell: UITableViewCell {
    
    let recommendTagView = RecommendTagView()
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraint() {
        self.contentView.addSubview(recommendTagView)
        recommendTagView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.height.equalTo(57)
        }
    }
}
