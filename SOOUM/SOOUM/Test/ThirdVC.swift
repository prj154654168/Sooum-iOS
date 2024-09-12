//
//  ThirdVC.swift
//  SOOUM
//
//  Created by 오현식 on 9/12/24.
//

import UIKit

import SnapKit


class ThirdVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel()
        label.text = "Third ViewController"
        
        self.view.addSubview(label)
        label.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
}
