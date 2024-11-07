//
//  UploadCardBottomSheetSegmentView.swift
//  SOOUM
//
//  Created by JDeoks on 10/16/24.
//

import UIKit

import ReactorKit
import RxGesture
import RxSwift

import SnapKit
import Then

class UploadCardBottomSheetSegmentView: UIView {
    let rootStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 0
        $0.isLayoutMarginsRelativeArrangement = true
    }
    
    let selectModeButtonStack = UIStackView().then {
        $0.axis = .horizontal
    }
    
    let defualtImageButtonLabel = UILabel().then {
        $0.typography = .som.body1WithBold
        $0.textAlignment = .center
        $0.textColor = .som.black
        $0.text = "기본 이미지"
    }
    
    let myImageButtonLabel = UILabel().then {
        $0.typography = .som.body1WithRegular
        $0.textAlignment = .center
        $0.textColor = .som.gray400
        $0.text = "내 사진"
    }
    
    let chageImageButtonStack = UIStackView().then {
        $0.alignment = .center
        $0.axis = .horizontal
        $0.spacing = 2
        $0.layoutMargins = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    
    let chagneImageLabel = UILabel().then {
        $0.typography = .som.body2WithRegular
        $0.textColor = .som.gray400
        $0.text = "이미지 변경"
    }
    
    let chageImageImageView = UIImageView().then {
        $0.image = .init(systemName: "gobackward")
        $0.tintColor = .som.gray400
    }
    
    // MARK: - init
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - setupConstraint
    private func setupConstraint() {
        self.addSubview(rootStack)
        rootStack.snp.makeConstraints {
            $0.leading.top.trailing.bottom.equalToSuperview()
        }
        
        rootStack.addArrangedSubviews(selectModeButtonStack, UIView(), chageImageButtonStack)
        selectModeButtonStack.addArrangedSubviews(defualtImageButtonLabel, myImageButtonLabel)
        defualtImageButtonLabel.snp.makeConstraints {
            $0.height.equalTo(32)
            $0.width.equalTo(94)
        }
        myImageButtonLabel.snp.makeConstraints {
            $0.height.equalTo(32)
            $0.width.equalTo(70)
        }
        
        chageImageButtonStack.addArrangedSubviews(chagneImageLabel, chageImageImageView)
        chagneImageLabel.snp.makeConstraints {
            $0.height.equalTo(14)
            $0.width.equalTo(65)
        }
        chageImageImageView.snp.makeConstraints {
            $0.height.equalTo(14)
            $0.width.equalTo(14)
        }
    }
}
