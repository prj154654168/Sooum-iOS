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
        static let title: String = "신고하기"
        static let tableViewTitle: String = "신고 사유 선택"
        
        static let successDialogTitle: String = "신고가 접수 되었어요"
        static let successDialogMessage: String = "신고 내용을 확인한 후 조치할 예정이에요"
        
        static let failedDialogTitle: String = "이미 신고를 한 카드에요"
        static let failedDialogMessage: String = "이전 신고가 접수되어 처리 중이에요"
        
        static let confirmActionTitle: String = "확인"
    }
        
    let tableViewTitleLabel = UILabel().then {
        $0.typography = .som.body1WithBold
        $0.textColor = .som.gray800
        $0.text = Text.tableViewTitle
    }
        
    lazy var reportTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.indicatorStyle = .black
        $0.separatorStyle = .none
        
        $0.register(ReportTableViewCell.self, forCellReuseIdentifier: String(describing: ReportTableViewCell.self))
        
        $0.dataSource = self
        $0.delegate = self
    }
    
    let uploadReportButtonLabel = UILabel().then {
        $0.typography = .som.body1WithBold
        $0.text = Text.title
        $0.textColor = .som.white
        $0.isUserInteractionEnabled = false
        $0.textAlignment = .center
        $0.backgroundColor = .som.p300
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    var selectedReason: ReportViewReactor.ReportType?
    
    override var navigationBarHeight: CGFloat {
        53
    }

    override func setupConstraints() {
        self.view.addSubview(tableViewTitleLabel)
        tableViewTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(28)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(22)
        }
        
        self.view.addSubview(reportTableView)
        reportTableView.snp.makeConstraints {
            $0.top.equalTo(tableViewTitleLabel.snp.bottom).offset(22)
            $0.leading.trailing.equalToSuperview()
        }
        
        self.view.addSubview(uploadReportButtonLabel)
        uploadReportButtonLabel.snp.makeConstraints {
            $0.top.equalTo(reportTableView.snp.bottom)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(50)
        }
    }
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.title
        self.hidesNavigationBarBottomSeperator = false
    }
    
    func bind(reactor: ReportViewReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: ReportViewReactor) {
        uploadReportButtonLabel.rx
            .tapGesture()
            .when(.recognized)
            .withUnretained(self)
            .compactMap { object, _ in object.selectedReason }
            .map(Reactor.Action.report)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }
    
    private func bindState(reactor: ReportViewReactor) {
        
        reactor.state.map(\.isDialogPresented)
            .filterNil()
            .subscribe(with: self) { object, isDialogPresented in
                
                let confirmAction = SOMDialogAction(
                    title: Text.confirmActionTitle,
                    style: .primary,
                    action: {
                        UIApplication.topViewController?.dismiss(animated: true) {
                            object.navigationPop()
                        }
                    }
                )
                
                SOMDialogViewController.show(
                    title: isDialogPresented ? Text.successDialogTitle : Text.failedDialogTitle,
                    message: isDialogPresented ? Text.successDialogMessage : Text.failedDialogMessage,
                    actions: [confirmAction]
                )
            }
            .disposed(by: self.disposeBag)
    }
}

// MARK: - UITableView
extension ReportViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReportViewReactor.ReportType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = reportTableView.dequeueReusableCell(
            withIdentifier: String(describing: ReportTableViewCell.self),
            for: indexPath
        ) as! ReportTableViewCell
        cell.setData(
            reason: ReportViewReactor.ReportType.allCases[indexPath.item],
            isSelected: selectedReason == ReportViewReactor.ReportType.allCases[indexPath.item]
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedReason = ReportViewReactor.ReportType.allCases[indexPath.item]
    }
}
