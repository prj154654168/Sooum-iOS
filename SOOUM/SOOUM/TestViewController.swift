//
//  TestViewController.swift
//  SOOUM
//
//  Created by JDeoks on 9/19/24.
//

import UIKit

import SnapKit
import Then

class TestViewController: UIViewController, SOMLocationFilterDelegate {
    
    let filter = SOMLocationFilter()
    
    override func viewDidLoad() {
        initUI()
    }
    
    // MARK: - initUI
    private func initUI() {
        addSubviews()
        initDelegate()
        initConstraint()
    }
    
    // MARK: - addSubviews
    private func addSubviews() {
        self.view.addSubview(filter)
    }
    
    // MARK: - initDelegate
    private func initDelegate() {
        filter.delegate = self
    }
    
    // MARK: - initConstraint
    private func initConstraint() {
        filter.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
    }
    
    func filter(_ filter: SOMLocationFilter, didSelectDistanceAt distance: SOMLocationFilter.Distance) {
        print(distance, "선택됨")
    }
}
