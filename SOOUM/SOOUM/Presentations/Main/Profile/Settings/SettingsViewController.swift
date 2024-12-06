//
//  SettingsViewController.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import UIKit

import SnapKit
import Then

import ReactorKit
import RxCocoa
import RxSwift


class SettingsViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let navigationTitle: String = "설정"
        
        static let appSettingTitle: String = "앱 설정"
        static let notificationSettingTitle: String = "알림 설정"
        static let commentHistoryTitle: String = "작성된 덧글 히스토리"
        
        static let userSettingTitle: String = "계정 설정"
        static let issueUserTransferCodeTitle: String = "계정 이관 코드 발급"
        static let enterUserTransferCodeTitle: String = "계정 이관 코드 입력"
        static let acceptTermsTitle: String = "이용약관 및 개인정보 처리 방침"
        static let resignTitle: String = "계정 탈퇴"
        
        static let serviceCenterTitle: String = "고객센터"
        static let announcementTitle: String = "공지사항"
        static let inquiryTitle: String = "1:1 문의하기"
        static let suggestionTitle: String = "제안하기"
        
        static let userBlockedGuideMessage: String = "계정이 정지된 상태에요"
        static let unBlockDate: String = "차단 해제 날짜 : "
    }
    
    private let scrollView = UIScrollView().then {
        $0.isScrollEnabled = true
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let appSettingHeader = SettingScrollViewHeader(title: Text.appSettingTitle)
    private let notificationSettingCellView = SettingTextCellView(buttonStyle: .toggle, title: Text.notificationSettingTitle)
    private let commentHistoryCellView = SettingTextCellView(title: Text.commentHistoryTitle)
    
    private let userSettingHeader = SettingScrollViewHeader(title: Text.userSettingTitle)
    private let issueUserTransferCodeCellView = SettingTextCellView(title: Text.issueUserTransferCodeTitle)
    private let enterUserTransferCodeCellView = SettingTextCellView(title: Text.enterUserTransferCodeTitle)
    private let acceptTermsCellView = SettingTextCellView(title: Text.acceptTermsTitle)
    private let resignCellView = SettingTextCellView(title: Text.resignTitle, titleColor: .som.red)
    
    private let serviceCenterHeader = SettingScrollViewHeader(title: Text.serviceCenterTitle)
    private let announcementCellView = SettingTextCellView(title: Text.announcementTitle)
    private let inquiryCellView = SettingTextCellView(title: Text.inquiryTitle)
    private let suggestionCellView = SettingTextCellView(title: Text.suggestionTitle)
    
    private let userBlockedBackgroundView = UIView()
    private let userBlockedLabel = UILabel().then {
        $0.text = Text.userBlockedGuideMessage
        $0.textColor = .som.black
        $0.typography = .som.body1WithBold
    }
    private let unBlockDateLabel = UILabel().then {
        $0.text = Text.unBlockDate
        $0.textColor = .som.gray500
        $0.typography = .som.body2WithRegular
    }
    
    override var navigationBarHeight: CGFloat {
        46
    }
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
    }
    
    override func setupConstraints() {
        
        self.view.backgroundColor = .som.white
        
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.bottom.leading.trailing.equalToSuperview()
        }
        
        let container = UIStackView(arrangedSubviews: [
            self.appSettingHeader,
            self.notificationSettingCellView,
            self.commentHistoryCellView,
            self.userSettingHeader,
            self.issueUserTransferCodeCellView,
            self.enterUserTransferCodeCellView,
            self.acceptTermsCellView,
            self.resignCellView,
            self.serviceCenterHeader,
            self.announcementCellView,
            self.inquiryCellView,
            self.suggestionCellView, 
            self.userBlockedBackgroundView
        ]).then {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.setCustomSpacing(18, after: self.commentHistoryCellView)
            $0.setCustomSpacing(18, after: self.resignCellView)
        }
        self.scrollView.addSubview(container)
        container.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        let userBlockContainer = UIStackView(arrangedSubviews: [
            self.userBlockedLabel,
            self.unBlockDateLabel
        ]).then {
            $0.axis = .vertical
            $0.spacing = 5
            $0.alignment = .center
            $0.distribution = .equalSpacing
        }
        // TODO: API 연동 후 계정 정지일 때, height == 20 + 93 + 31, 활성화일 때, height == 31
        self.userBlockedBackgroundView.snp.makeConstraints {
            let height: CGFloat = 20 + 93 + 31
            $0.height.equalTo(height)
        }
        self.userBlockedBackgroundView.addSubview(userBlockContainer)
        userBlockContainer.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-31)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    
    // MARK: ReactorKit bind
    
    func bind(reactor: SettingsViewReactor) {
        
        // Action
        self.rx.viewWillAppear
            .map { _ in Reactor.Action.landing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.commentHistoryCellView.rx.didSelect
            .subscribe(with: self) { object, _ in
                let commentHistoryViewController = CommentHistroyViewController()
                commentHistoryViewController.reactor = reactor.reactorForCommentHistory()
                object.navigationPush(commentHistoryViewController, animated: true, bottomBarHidden: true)
            }
            .disposed(by: self.disposeBag)
        
        self.issueUserTransferCodeCellView.rx.didSelect
            .subscribe(with: self) { object, _ in
                let issueMemberTransferViewController = IssueMemberTransferViewController()
                issueMemberTransferViewController.reactor = reactor.reactorForTransferIssue()
                object.navigationPush(issueMemberTransferViewController, animated: true, bottomBarHidden: true)
            }
            .disposed(by: self.disposeBag)
        
        self.enterUserTransferCodeCellView.rx.didSelect
            .subscribe(with: self) { object, _ in
                let enterMemberTransferViewController = EnterMemberTransferViewController()
                enterMemberTransferViewController.reactor = reactor.reactorForTransferEnter()
                object.navigationPush(enterMemberTransferViewController, animated: true, bottomBarHidden: true)
            }
            .disposed(by: self.disposeBag)
        
        self.acceptTermsCellView.rx.didSelect
            .subscribe(with: self) { object, _ in
                let rermsOfServiceViewController = TermsOfServiceViewController()
                object.navigationPush(rermsOfServiceViewController, animated: true, bottomBarHidden: true)
            }
            .disposed(by: self.disposeBag)
        
        self.resignCellView.rx.didSelect
            .subscribe(with: self) { object, _ in
                let resignViewController = ResignViewController()
                resignViewController.reactor = reactor.reactorForResign()
                object.navigationPush(resignViewController, animated: true, bottomBarHidden: true)
            }
            .disposed(by: self.disposeBag)
        
        self.announcementCellView.rx.didSelect
            .subscribe(with: self) { object, _ in
                let announcementViewControler = AnnouncementViewControler()
                announcementViewControler.reactor = reactor.reactorForAnnouncement()
                object.navigationPush(announcementViewControler, animated: true, bottomBarHidden: true)
            }
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map(\.isProcessing)
            .distinctUntilChanged()
            .bind(to: self.activityIndicatorView.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.banEndAt)
            .distinctUntilChanged()
            .subscribe(with: self) { object, banEndAt in
                object.userBlockedBackgroundView.isHidden = (banEndAt == nil)
                object.unBlockDateLabel.text = "\(Text.unBlockDate) \(banEndAt?.banEndFormatted ?? "")"
            }
            .disposed(by: self.disposeBag)
    }
}
