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
    
    let homeTabBarDidTap = PublishRelay<Int>()
    let locationFilterDidTap = PublishRelay<String>()
    
    let container = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 2
    }
    
    lazy var homeTabBar = SOMHomeTabBar().then {
        $0.delegate = self
    }
    
    lazy var locationFilter = SOMLocationFilter().then {
        $0.delegate = self
    }
    
    var isLocationFilterHidden: Bool {
        set { self.locationFilter.isHidden = newValue }
        get { self.locationFilter.isHidden }
    }
    
    var disponseBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.setupConstraints()
        /// 시작 인덱스
        self.homeTabBar.didSelectTab(0)
        /// locationFilter hidden 에 따른 높이
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
                
                object.layoutIfNeeded()
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


// MARK: MainHomeHeaderView Delegate

extension MainHomeHeaderView: SOMHomeTabBarDelegate {
    
    func tabBar(_ tabBar: SOMHomeTabBar, didSelectTabAt index: Int) {
        self.homeTabBarDidTap.accept(index)
        self.isLocationFilterHidden = index != 2
    }
}

extension MainHomeHeaderView: SOMLocationFilterDelegate {
    
    func filter(
        _ filter: SOMLocationFilter,
        didSelectDistanceAt distance: SOMLocationFilter.Distance
    ) {
        self.locationFilterDidTap.accept(distance.rawValue)
    }
}
