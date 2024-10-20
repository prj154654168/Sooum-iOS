//
//  SelectMyImageTableViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 10/17/24.
//

import UIKit

import ReactorKit
import RxGesture
import RxSwift

import SnapKit
import Then

class SelectMyImageTableViewCell: UITableViewCell {
    
    var disposeBag = DisposeBag()
    
    let rootImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .som.gray04
        $0.layer.cornerRadius = 8
    }
    
    let plusIconImageView = UIImageView().then {
        $0.image = .init(systemName: "plus")
        $0.tintColor = .som.gray01
    }
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    // MARK: - setData
    func setData() {
        action()
    }
    
    // MARK: - action
    private func action() {
        rootImageView.rx.tapGesture()
            .when(.recognized)
            .subscribe { _ in
                // TODO: - 이미지 선택
            }
            .disposed(by: disposeBag)
    }

    // MARK: - setupConstraint
    private func setupConstraint() {
        contentView.addSubview(rootImageView)
        rootImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-24)
            $0.height.equalTo(108)
            $0.width.equalTo(120)
        }
        rootImageView.addSubview(plusIconImageView)
        
        plusIconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }
    }
}
