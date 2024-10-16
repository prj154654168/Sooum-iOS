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

class ReportViewController: BaseViewController, View {
    
    enum ReportType: String, CaseIterable {
        case profanity = "DEFAMATION_AND_ABUSE"
        case privacyViolation = "PRIVACY_VIOLATION"
        case inappropriatePromotion = "INAPPROPRIATE_ADVERTISING"
        case obsceneContent = "PORNOGRAPHY"
        case fraud = "IMPERSONATION_AND_FRAUD"
        case etc = "OTHER"
        
        var title: String {
            switch self {
            case .profanity:
                "비방 및 욕설"
            case .privacyViolation:
                "개인정보 침해"
            case .inappropriatePromotion:
                "부적절한 홍보 및 바이럴"
            case .obsceneContent:
                "음란물"
            case .fraud:
                "사칭 및 사기"
            case .etc:
                "기타"
            }
        }
        
        var description: String {
            switch self {
            case .profanity:
                "욕설을 사용하여 타인에게 모욕감을 주는 경우"
            case .privacyViolation:
                "법적으로 중요한 타인의 개인정보를 게재"
            case .inappropriatePromotion:
                "부적절한 스팸 홍보 행위"
            case .obsceneContent:
                "음란한 행위와 관련된 부적절한 행동"
            case .fraud:
                "사칭으로 타인의 권리를 침해하는 경우"
            case .etc:
                "해당하는 신고항목이 없는 경우"
            }
        }
    }
    
    var selectedReason: ReportType?
    
    let navigationBar = SOMNavigationBar()
    
    let tableViewTitleLabel = UILabel().then {
        $0.typography = .init(
            fontContainer: Pretendard(
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
            fontContainer: Pretendard(
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
        
        self.navigationBar.isHideBackButton = false
    }
    
    func bind(reactor: ReportViewReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: ReportViewReactor) {
        uploadReportButtonLabel.rx
            .tapGesture()
            .when(.recognized)
            .compactMap { _ in
                guard let selectedReason = self.selectedReason else {
                    return nil
                }
                return Reactor.Action.report(selectedReason)
            }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
    }
    
    private func bindState(reactor: ReportViewReactor) {
        reactor.state.map(\.isDialogPresented)
            .distinctUntilChanged()
            .subscribe(with: self) { object, state in
               // TODO: - 다이얼로그 VC 표시
            }
            .disposed(by: self.disposeBag)
    }
}

// MARK: - UITableView
extension ReportViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReportType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = reportTableView.dequeueReusableCell(
            withIdentifier: String(describing: ReportTableViewCell.self),
            for: indexPath
        ) as! ReportTableViewCell
        cell.setData(reason: ReportType.allCases[indexPath.item], isSelected: selectedReason == ReportType.allCases[indexPath.item] )
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedReason = ReportType.allCases[indexPath.item]
        print("\(type(of: self)) - \(#function)", selectedReason?.title)
    }
}
