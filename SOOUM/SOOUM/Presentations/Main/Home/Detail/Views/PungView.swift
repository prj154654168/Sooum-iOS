//
//  PungView.swift
//  SOOUM
//
//  Created by 오현식 on 11/2/25.
//

import UIKit

import SnapKit
import Then

import RxCocoa
import RxSwift

class PungView: UIView {
    
    
    // MARK: Views
    
    private let pungTimeLabel = UILabel().then {
        $0.textColor = .som.v2.pDark
        $0.typography = .som.v2.caption3
    }
    
    
    // MARK: Variables
    
    /// 펑 이벤트 처리 위해 추가
    private var serialTimer: Disposable?
    private var disposeBag = DisposeBag()
    
    var isPunged = PublishRelay<Void>()
    
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
        
        self.backgroundColor = .som.v2.white
        self.layer.borderColor = UIColor.som.v2.gray200.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 23 * 0.5
        
        self.snp.makeConstraints {
            $0.height.equalTo(23)
        }
        
        self.addSubview(self.pungTimeLabel)
        self.pungTimeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(6)
            $0.trailing.equalToSuperview().offset(-6)
        }
    }
    
    /// 펑 이벤트 구독
    func subscribePungTime(_ pungTime: Date?) {
        self.serialTimer?.dispose()
        self.serialTimer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .startWith((self, 0))
            .map { object, _ in
                guard let pungTime = pungTime else {
                    object.serialTimer?.dispose()
                    return "00:00:00"
                }
                
                let currentDate = Date()
                let remainingTime = currentDate.infoReadableTimeTakenFromThisForPung(to: pungTime)
                if remainingTime == "00:00:00" {
                    object.serialTimer?.dispose()
                    object.isPunged.accept(())
                }
                
                return remainingTime
            }
            .bind(to: self.pungTimeLabel.rx.text)
    }
}
