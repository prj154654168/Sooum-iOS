//
//  SOMDialogViewController.swift
//  SOOUM
//
//  Created by JDeoks on 10/3/24.
//

import UIKit

import RxGesture
import RxSwift

class SOMDialogViewController: UIViewController {
    
    /// 버튼 디스플레이 모드 설정
    enum ButtonMode {
        case cancel
        case ok
        case delete
        case report
        case setting
        
        var text: String {
            switch self {
            case .cancel:
                "취소"
            case .ok:
                "확인"
            case .delete:
                "삭제하기"
            case .report:
                "신고하기"
            case .setting:
                "설정"
            }
        }
        
        var bgColor: UIColor {
            switch self {
            case .cancel:
                .som.gray300
            default:
                .som.p300
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .cancel:
                .som.gray700
            default:
                .som.white
            }
        }
    }
    
    /// 버튼 액션
    class Action {
        var mode: ButtonMode?
        var handler: () -> Void
        
        init(mode: ButtonMode?, handler: @escaping () -> Void) {
            self.mode = mode
            self.handler = handler
        }
    }
    
    // MARK: - property
    private var titleText: String?
    private var subTitleText: String?

    /// 좌측 버튼에 적용할 액션
    var leftAction: Action?
    /// 우측 버튼에 적용할 액션
    var rightAction: Action?
    /// 딤뷰 탭했을 경우 적용할 핸들러. nil일 경우 탭되지 않음
    var dimViewAction: Action?
    
    let disposeBag = DisposeBag()
    
    // MARK: - UI
    
    /// 다이얼로그 루트 컨테이너 뷰
    let containerView = UIView().then {
        $0.backgroundColor = .som.white
        $0.layer.cornerRadius = 20
    }
    
    /// 제목 표시 라벨
    let titleLabel = UILabel().then {
        $0.text = ""
        $0.textColor = .som.black
        $0.typography = .som.body1WithBold
    }
    
    /// 부제목 표시 라벨
    let subTitleLabel = UILabel().then {
        $0.textColor = .som.gray600
        $0.typography = .som.body2WithRegular
    }
    
    /// 버튼 스택 뷰
    let buttonStackView = UIStackView().then {
        $0.alignment = .fill
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 8
    }
    
    let leftButton = UIButton().then {
        $0.layer.cornerRadius = 10
        $0.titleLabel?.typography = .som.body1WithBold
    }
    
    let rightButton = UIButton().then {
        $0.layer.cornerRadius = 10
        $0.titleLabel?.typography = .som.body1WithBold
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bindUIData()
        action()
    }

    // MARK: - setData
    func setData(
        title: String?,
        subTitle: String?,
        leftAction: Action?,
        rightAction: Action?,
        dimViewAction: Action?
    ) {
        self.titleText = title
        self.subTitleText = subTitle
        self.leftAction = leftAction
        self.rightAction = rightAction
        self.dimViewAction = dimViewAction
    }
    
    // MARK: - initUI
    private func initUI() {
        self.view.backgroundColor = .som.dim
        addSubviews()
        initConstraint()
    }
    
    // MARK: - addSubviews
    private func addSubviews() {
        self.view.addSubviews(containerView)
        containerView.addSubviews(titleLabel, subTitleLabel, buttonStackView)
        buttonStackView.addArrangedSubviews(leftButton, rightButton)
    }
    
    // MARK: - initConstraint
    private func initConstraint() {
        containerView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.75)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(22)
            $0.bottom.equalToSuperview().offset(-14)
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(14)
        }
        
        leftButton.snp.makeConstraints {
            $0.height.equalTo(46)
        }
        
        rightButton.snp.makeConstraints {
            $0.height.equalTo(46)
        }
    }
    
    // MARK: - bindUIData
    private func bindUIData() {
        // 제목 및 부제목 텍스트
        titleLabel.text = titleText
        subTitleLabel.text = subTitleText
        
        // 좌측 버튼 설정
        if let leftAction = leftAction {
            leftButton.setTitle(leftAction.mode?.text ?? "취소", for: .normal)
            leftButton.backgroundColor = leftAction.mode?.bgColor ?? .som.gray300
            leftButton.setTitleColor(leftAction.mode?.textColor ?? .som.black, for: .normal)
        } else {
            leftButton.removeFromSuperview()
        }
        
        // 우측 버튼 설정
        if let rightAction = rightAction {
            rightButton.setTitle(rightAction.mode?.text ?? "확인", for: .normal)
            rightButton.backgroundColor = rightAction.mode?.bgColor ?? .som.p300
            rightButton.setTitleColor(rightAction.mode?.textColor ?? .som.white, for: .normal)
        } else {
            rightButton.removeFromSuperview()
        }
    }
        
    // MARK: - action
    private func action() {
        self.view.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { gesture in
                if self.view.isTappedDirectly(gesture: gesture) {
                    self.dimViewAction?.handler()
                }
            })
            .disposed(by: disposeBag)
        
        leftButton.rx.tap
            .subscribe(onNext: { _ in
                self.leftAction?.handler()
            })
            .disposed(by: disposeBag)
        
        rightButton.rx.tap
            .subscribe(onNext: { _ in
                self.rightAction?.handler()
            })
            .disposed(by: disposeBag)
    }
}
