//
//  WriteCardGuideView.swift
//  SOOUM
//
//  Created by 오현식 on 12/5/25.
//

import UIKit

import SnapKit
import Then

class WriteCardGuideView: UIView {
    
    
    // MARK: Views
    
    private let imageView = UIImageView().then {
        $0.image = .init(.image(.v2(.guide_write_card)))
        // $0.contentMode = .scaleAspectFit
    }
    
    let closeButton = UIButton()
    
    
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
        
        self.addSubview(self.imageView)
        self.imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.addSubview(self.closeButton)
        self.closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60)
            $0.leading.equalToSuperview().offset(4)
            $0.size.equalTo(48)
        }
    }
}
