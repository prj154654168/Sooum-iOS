//
//  MainHomeHeaderView.swift
//  SOOUM
//
//  Created by 오현식 on 9/25/24.
//

import UIKit

import RxCocoa
import RxSwift

import SnapKit
import Then


class MainHomeHeaderView: UIView {
    
    private let height = SOMHomeTabBar.height + 54 + 2
    
    let container = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 2
    }
    
    let homeTabBar = SOMHomeTabBar()
    
    let locationFilter = SOMLocationFilter()
    
    var isLocationFilterHidden: Bool {
        set { self.locationFilter.isHidden = newValue }
        get { self.locationFilter.isHidden }
    }
    
    var disponseBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.setupConstraints()
        
        // locationFilter hidden 에 따른 높이
        self.locationFilter.rx.observe(Bool.self, "hidden")
            .distinctUntilChanged()
            .subscribe(with: self) { object, isHidden in
                
                guard let isHidden = isHidden else { return }
                
                object.container.snp.updateConstraints {
                    $0.height.equalTo(isHidden ? SOMHomeTabBar.height : object.height)
                }
                
                object.locationFilter.snp.updateConstraints {
                    $0.height.equalTo(isHidden ? 0 : 54)
                }
            }
            .disposed(by: self.disponseBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        self.container.addArrangedSubview(self.homeTabBar)
        self.homeTabBar.snp.makeConstraints {
            $0.height.equalTo(SOMHomeTabBar.height)
        }
        
        self.container.addArrangedSubview(self.locationFilter)
        self.locationFilter.snp.makeConstraints {
            $0.height.equalTo(self.isLocationFilterHidden ? 0 : 54)
        }
        
        self.addSubview(self.container)
        self.container.snp.makeConstraints {
            $0.edges.equalToSuperview()
            let height = self.isLocationFilterHidden ?
                SOMHomeTabBar.height :
                self.height
            $0.height.equalTo(height)
        }
    }
}
