//
//  TagsHeaderView.swift
//  SOOUM
//
//  Created by JDeoks on 11/24/24.
//

import UIKit

class TagsHeaderView: UIView {
    
    let titlelabel = UILabel().then {
        $0.typography = .som.body1WithBold
        $0.text = "내가 즐겨찾기한 태그"
    }
    
    // MARK: - init
    convenience init(type: TagsViewController.TagType) {
        self.init(frame: .zero, type: type)
    }
    
    init(frame: CGRect, type: TagsViewController.TagType) {
        super.init(frame: frame)
        self.backgroundColor = .som.white
        titlelabel.text = type.headerText
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setupConstraints
    private func setupConstraints() {
        self.addSubview(titlelabel)
        titlelabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(32)
            $0.top.equalToSuperview().offset(20)
            $0.height.equalTo(24)
        }
    }
}
