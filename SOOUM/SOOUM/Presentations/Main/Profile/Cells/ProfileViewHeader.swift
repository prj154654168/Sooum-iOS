//
//  ProfileViewFooterHeader.swift
//  SOOUM
//
//  Created by 오현식 on 11/7/25.
//

import UIKit

import SnapKit
import Then

import RxCocoa
import RxSwift

class ProfileViewHeader: UICollectionReusableView {
    
    enum Text {
        static let tabFeedTitle: String = "카드"
        static let tabCommentTitle: String = "댓글카드"
    }
    
    static let cellIdentifier = String(reflecting: ProfileViewHeader.self)
    
    
    // MARK: Views
    
    private lazy var stickyTabBar = SOMStickyTabBar(alignment: .center).then {
        $0.items = [Text.tabFeedTitle, Text.tabCommentTitle]
        $0.spacing = 24
        $0.delegate = self
    }
    
    
    // MARK: Variables + Rx
    
    var disposeBag = DisposeBag()
    
    let tabBarItemDidTap = PublishRelay<Int>()
    
    
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
        
        self.disposeBag = DisposeBag()
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.backgroundColor = .som.v2.white
        
        self.addSubview(self.stickyTabBar)
        self.stickyTabBar.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension ProfileViewHeader: SOMStickyTabBarDelegate {
    
    func tabBar(_ tabBar: SOMStickyTabBar, didSelectTabAt index: Int) {
        
        self.tabBarItemDidTap.accept(index)
    }
}
