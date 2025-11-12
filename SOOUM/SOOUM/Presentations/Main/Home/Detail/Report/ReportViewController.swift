//
//  ReportViewController.swift
//  SOOUM
//
//  Created by JDeoks on 10/13/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift

import SnapKit
import Then

class ReportViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let navigationTitle: String = "신고하기"
        static let guideMessage: String = "신고하는 이유를 선택해주세요"
        
        static let successDialogTitle: String = "신고가 접수 되었어요"
        static let successDialogMessage: String = "신고 내용을 확인한 후 조치하도록 하겠습니다. 감사합니다."
        
        static let failedDialogTitle: String = "이미 신고를 한 카드에요"
        static let failedDialogMessage: String = "이전 신고가 접수되어 처리 중이에요"
        
        static let confirmButtonTitle: String = "확인"
        static let completeButtonTitle: String = "완료"
    }
        
    
    // MARK: Views
    
    private let guideMessageLabel = UILabel().then {
        $0.text = Text.guideMessage
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.head2
    }
    
    private let container = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 10
    }
    
    private let completeButton = SOMButton().then {
        $0.title = Text.completeButtonTitle
        $0.typography = .som.v2.title1
        $0.foregroundColor = .som.v2.white
        $0.backgroundColor = .som.v2.black
        
        $0.isEnabled = false
    }
    
    
    // MARK: Override variables
    
    override var bottomToastMessageOffset: CGFloat {
        /// bottom safe layout guide + floating button height + padding
        return 34 + 56 + 8
    }
    
    
    // MARK: Override func

    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.guideMessageLabel)
        self.guideMessageLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        self.view.addSubview(self.container)
        self.container.snp.makeConstraints {
            $0.top.equalTo(self.guideMessageLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        self.view.addSubview(self.completeButton)
        self.completeButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(56)
        }
    }
    
    override func bind() {
        super.bind()
        
        self.setupReportButtons()
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: ReportViewReactor) {
        self.bindAction(reactor: reactor)
        self.bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: ReportViewReactor) {
        
        self.completeButton.rx.throttleTap
            .map { _ in Reactor.Action.report }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }
    
    private func bindState(reactor: ReportViewReactor) {
        
        reactor.state.map(\.reportReason)
            .filterNil()
            .distinctUntilChanged()
            .subscribe(with: self) { object, reportReason in
                
                let items = object.container.arrangedSubviews
                    .compactMap { $0 as? SOMButton }
                
                items.forEach { item in
                    item.isSelected = reportReason.identifier == item.tag
                }
                
                object.completeButton.isEnabled = true
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isReported)
            .filter { $0 }
            .subscribe(with: self) { object, _ in
                object.showSuccessReportedDialog()
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.hasErrors)
            .filter { $0 }
            .subscribe(with: self) { object, _ in
                object.navigationPop {
                    NotificationCenter.default.post(name: .updatedReportState, object: nil, userInfo: nil)
                }
            }
            .disposed(by: self.disposeBag)
    }
}


// MARK: setup buttons and show dialog

private extension ReportViewController {
    
    func setupReportButtons() {
        
        guard let reactor = self.reactor else { return }
        
        ReportType.allCases.forEach { reportType in
            
            let item = SOMButton().then {
                
                $0.title = reportType.message
                $0.typography = .som.v2.subtitle1
                $0.foregroundColor = .som.v2.gray600
                $0.backgroundColor = .som.v2.gray100
                
                $0.inset = .init(top: 0, left: 16, bottom: 0, right: 0)
                $0.contentHorizontalAlignment = .left
                
                $0.tag = reportType.identifier
            }
            item.snp.makeConstraints {
                $0.height.equalTo(48)
            }
            item.rx.throttleTap
                .map { _ in Reactor.Action.updateReportReason(reportType) }
                .bind(to: reactor.action)
                .disposed(by: self.disposeBag)
            
            self.container.addArrangedSubview(item)
        }
    }
    
    func showSuccessReportedDialog() {
        
        let confirmAction = SOMDialogAction(
            title: Text.confirmButtonTitle,
            style: .primary,
            action: {
                UIApplication.topViewController?.dismiss(animated: true) {
                    self.navigationPop {
                        NotificationCenter.default.post(name: .updatedReportState, object: nil, userInfo: nil)
                    }
                }
            }
        )

        SOMDialogViewController.show(
            title: Text.successDialogTitle,
            message: Text.successDialogMessage,
            textAlignment: .left,
            actions: [confirmAction]
        )
    }
}
