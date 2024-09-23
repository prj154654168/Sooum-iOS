//
//  MockViewController.swift
//  SOOUM
//
//  Created by 오현식 on 9/23/24.
//

import UIKit

import Alamofire
import RxSwift

import SnapKit
import Then


class MockViewController: BaseViewController {
    
    let button = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.title = "눌러라~~"
        config.baseBackgroundColor = .systemBlue
        $0.configuration = config
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.button.rx.tap
            .subscribe(with: self) { object, _ in
                let request = MockRequest.mock
                
                NetworkManager.shared.request(MockResponse.self, request: request)
                    .subscribe(onNext: { response in
                        print(response)
                    })
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: self.disposeBag)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.button)
        self.button.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
    }
}
