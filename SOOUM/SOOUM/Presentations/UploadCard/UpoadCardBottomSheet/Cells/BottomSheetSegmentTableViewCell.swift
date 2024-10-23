//
//  BottomSheetSegmentTableViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 10/17/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift

import SnapKit
import Then

class BottomSheetSegmentTableViewCell: UITableViewCell {
    
    enum ImageSegment {
        case defaultImage
        case myImage
    }
    
    var imageSegment: BehaviorRelay<ImageSegment>?
    
    var selectedSegment: ImageSegment = .defaultImage
    
    var disposeBag = DisposeBag()

    let rootStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 0
        $0.isLayoutMarginsRelativeArrangement = true
    }
    
    let selectModeButtonStack = UIStackView().then {
        $0.axis = .horizontal
    }
    
    let defualtImageButtonLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: Pretendard(size: 16, weight: .medium),
            lineHeight: 20
         )
        $0.textAlignment = .center
        $0.textColor = .som.black
        $0.text = "기본 이미지"
    }
    
    let myImageButtonLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: Pretendard(size: 16, weight: .medium),
            lineHeight: 20
         )
        $0.textAlignment = .center
        $0.textColor = .som.black
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
        $0.typography = .init(
            fontContainer: Pretendard(size: 14, weight: .medium),
            lineHeight: 14
         )
        $0.textColor = .som.gray03
        $0.text = "이미지 변경"
    }
    
    let chageImageImageView = UIImageView().then {
        $0.image = .init(systemName: "gobackward")
        $0.tintColor = .som.gray03
    }
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupConstraint()
        updateImageSegment(segment: .defaultImage, animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    // MARK: - setData
    func setData(segmentState: BehaviorRelay<ImageSegment>) {
        action()
        self.imageSegment = segmentState
        updateImageSegment(segment: segmentState.value, animated: false)
    }
    
    // MARK: - action
    private func action() {
        defualtImageButtonLabel.rx.tapGesture()
            .when(.recognized)
            .subscribe { _ in
                self.imageSegment?.accept(.defaultImage)
                self.updateImageSegment(segment: .defaultImage, animated: true)
            }
            .disposed(by: disposeBag)
        
        myImageButtonLabel.rx.tapGesture()
            .when(.recognized)
            .subscribe { _ in
                self.imageSegment?.accept(.myImage)
                self.updateImageSegment(segment: .myImage, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func updateImageSegment(segment: ImageSegment, animated: Bool) {
        print("\(type(of: self)) - \(#function)")

        self.selectedSegment = segment
        let duration = animated ? 0.2 : 0.0

        UIView.transition(
            with: self.defualtImageButtonLabel,
            duration: duration,
            options: .transitionCrossDissolve,
            animations: {
                self.defualtImageButtonLabel.textColor = segment == .defaultImage ? .som.black : .som.gray04
            },
            completion: nil
        )
        
        UIView.transition(
            with: self.myImageButtonLabel,
            duration: duration,
            options: .transitionCrossDissolve,
            animations: {
                self.myImageButtonLabel.textColor = segment == .myImage ? .som.black : .som.gray04
            },
            completion: nil
        )
    }
    
    // MARK: - setupConstraint
    private func setupConstraint() {
        contentView.addSubview(rootStack)
        rootStack.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-14)
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
