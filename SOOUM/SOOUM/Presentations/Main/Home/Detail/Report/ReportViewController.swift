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
    
    var selectedReason: ReportViewReactor.ReportType?
        
    let tableViewTitleLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: BuiltInFont(
                size: 16,
                weight: .semibold
            ),
            lineHeight: 22.4,
            letterSpacing: 0
        )
        $0.textColor = .som.black
        $0.text = "신고 사유 선택"
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
        $0.typography = .init(
            fontContainer: BuiltInFont(
                size: 16,
                weight: .bold
            ),
            lineHeight: 19.1,
            letterSpacing: 0
        )
        $0.text = "신고하기"
        $0.textColor = .som.white
        $0.isUserInteractionEnabled = false
        $0.textAlignment = .center
        $0.backgroundColor = .som.primary
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
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
        self.navigationBar.titleLabel.text = "신고하기"
    }
    
    func bind(reactor: ReportViewReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: ReportViewReactor) {
        uploadReportButtonLabel.rx
            .tapGesture()
            .when(.recognized)
            .compactMap { _ in self.selectedReason }
            .map(Reactor.Action.report)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }
    
    private func bindState(reactor: ReportViewReactor) {
        reactor.state.map(\.isDialogPresented)
            .distinctUntilChanged()
            .subscribe(with: self) { object, state in
               print("state", state)
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
