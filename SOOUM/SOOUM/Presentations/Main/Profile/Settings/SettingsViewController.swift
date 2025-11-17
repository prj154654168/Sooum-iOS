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
        
        static let notificationSettingTitle: String = "알림 설정"
        
        static let issueUserTransferCodeTitle: String = "다른 기기에서 로그인하기"
        static let enterUserTransferCodeTitle: String = "이전 계정 불러오기"
        
        static let blockUsersTitle: String = "차단 사용자 관리"
        
        static let announcementTitle: String = "공지사항"
        static let inquiryTitle: String = "문의하기"
        
        static let acceptTermsTitle: String = "이용약관 및 개인정보 처리 방침"
        
        static let appVersionTitle: String = "최신버전 업데이트"
        static let latestVersionTitle: String = "최신버전 : "
        
        static let resignTitle: String = "탈퇴하기"
        
        static let serviceCenterTitle: String = "고객센터"
        
        static let postingBlockedTitle: String = "이용 제한 안내"
        static let postingBlockedLeadingGuideMessage: String = """
        신고된 카드 인해 카드 추가 기능이 제한된 계정입니다.
        필요한 경우 아래 ‘문의하기’를 이용해 주세요.
                제한 기간 : 
        """
        static let postingBlockedTrailingGuideMessage: String = "까지"
        
        static let adminMailStrUrl: String = "sooum1004@gmail.com"
        static let identificationInfo: String = "식별 정보: "
        static let inquiryMailTitle: String = "[문의하기]"
        static let inquiryMailGuideMessage: String = """
            \n
            문의 내용: 식별 정보 삭제에 주의하여 주시고, 이곳에 자유롭게 문의하실 내용을 적어주세요.
            단, 본 양식에 비방, 욕설, 허위 사실 유포 등의 부적절한 내용이 포함될 경우,
            관련 법령에 따라 민·형사상 법적 조치가 이루어질 수 있음을 알려드립니다.
        """
        
        static let suggestMailTitle: String = "[제안하기]"
        static let suggestMailGuideMessage: String = """
            \n
            제안 내용: 식별 정보 삭제에 주의하여 주시고, 이곳에 숨 개발팀에 제안할 내용을  자유롭게 작성해 주세요.
            단, 본 양식에 비방, 욕설, 허위 사실 유포 등의 부적절한 내용이 포함될 경우,
            관련 법령에 따라 민·형사상 법적 조치가 이루어질 수 있음을 알려드립니다.
        """
        
        static let bottomToastEntryName: String = "bottomToastEntryName"
        static let latestVersionToastTitle: String = "현재 최신버전을 사용중입니다"
        
        static let testFlightStrUrl: String = "itms-beta://testflight.apple.com/v1/app"
        static let appStoreStrUrl: String = "itms-apps://itunes.apple.com/app/id"
        
        static let resignDialogTitle: String = "정말 탈퇴하시겠습니까?"
        static let resignDialogMessage: String = "계정이 삭제되면 모든 정보가 영구적으로 삭제되며, 탈퇴일 기준 7일 후부터 재가입이 가능합니다."
        static let resignDialogBannedLeadingMessage: String = "계정이 삭제되면 모든 정보가 영구 삭제되며, 재가입은 이용 제한 해지 날짜인 "
        static let resignDialogBannedTrailingMessage: String = "부터 가능합니다."
        
        static let cancelActionButtonTitle: String = "취소"
    }
    
    
    // MARK: views
    
    private let scrollView = UIScrollView().then {
        $0.isScrollEnabled = true
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let notificationSettingCellView = SettingTextCellView(buttonStyle: .toggle, title: Text.notificationSettingTitle)
    
    private let issueUserTransferCodeCellView = SettingTextCellView(title: Text.issueUserTransferCodeTitle)
    private let enterUserTransferCodeCellView = SettingTextCellView(title: Text.enterUserTransferCodeTitle)
    
    private let blockUsersCellView = SettingTextCellView(title: Text.blockUsersTitle)
    
    private let announcementCellView = SettingTextCellView(title: Text.announcementTitle)
    private let inquiryCellView = SettingTextCellView(title: Text.inquiryTitle)
    
    private let acceptTermsCellView = SettingTextCellView(title: Text.acceptTermsTitle)
    
    private let appVersionCellView = SettingVersionCellView(title: Text.appVersionTitle)
    
    private let resignCellView = SettingTextCellView(title: Text.resignTitle)
    
    private let postingBlockedBackgroundView = UIView().then {
        $0.isHidden = true
    }
    private let postingBlockedTitleLabel = UILabel().then {
        $0.text = Text.postingBlockedTitle
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.caption1
    }
    private let postingBlockedMessageLabel = UILabel().then {
        $0.text = Text.postingBlockedLeadingGuideMessage
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.caption3
    }
    
    
    // MARK: Override variables
    
    override var bottomToastMessageOffset: CGFloat {
        /// bottom safe layout guide + padding
        return 34 + 8
    }
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
    }
    
    override func setupConstraints() {
        
        self.view.backgroundColor = .som.v2.gray100
        
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.bottom.leading.trailing.equalToSuperview()
        }
        
        let container = UIStackView(arrangedSubviews: [
            self.notificationSettingCellView,
            self.issueUserTransferCodeCellView,
            self.enterUserTransferCodeCellView,
            self.blockUsersCellView,
            self.announcementCellView,
            self.inquiryCellView,
            self.acceptTermsCellView,
            self.appVersionCellView,
            self.resignCellView,
            self.postingBlockedBackgroundView
        ]).then {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.setCustomSpacing(16, after: self.notificationSettingCellView)
            $0.setCustomSpacing(16, after: self.enterUserTransferCodeCellView)
            $0.setCustomSpacing(16, after: self.blockUsersCellView)
            $0.setCustomSpacing(16, after: self.inquiryCellView)
            $0.setCustomSpacing(16, after: self.acceptTermsCellView)
            $0.setCustomSpacing(16, after: self.appVersionCellView)
        }
        self.scrollView.addSubview(container)
        container.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.postingBlockedBackgroundView.addSubview(self.postingBlockedTitleLabel)
        self.postingBlockedTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        self.postingBlockedBackgroundView.addSubview(self.postingBlockedMessageLabel)
        self.postingBlockedMessageLabel.snp.makeConstraints {
            $0.top.equalTo(self.postingBlockedTitleLabel.snp.bottom).offset(6)
            $0.bottom.equalToSuperview().offset(-16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
    }
    
    override func bind() {
        
        self.navigationBar.backButton.rx.tap
            .subscribe(with: self) { object, _ in
                object.navigationPop(bottomBarHidden: false)
            }
            .disposed(by: self.disposeBag)
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: SettingsViewReactor) {
        
        // Action
        self.rx.viewWillAppear
            .map { _ in Reactor.Action.landing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.notificationSettingCellView.rx.didSelect
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .map { object, _ in Reactor.Action.updateNotificationStatus(!object.notificationSettingCellView.toggleSwitch.isOn) }
            .bind(to: reactor.action)
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
        
        self.blockUsersCellView.rx.didSelect
            .subscribe(with: self) { object, _ in
                let blockUsersViewController = BlockUsersViewController()
                blockUsersViewController.reactor = reactor.reactorForBlock()
                object.navigationPush(blockUsersViewController, animated: true, bottomBarHidden: true)
            }
            .disposed(by: self.disposeBag)
        
        self.announcementCellView.rx.didSelect
            .subscribe(with: self) { object, _ in
                let announcementViewController = AnnouncementViewController()
                announcementViewController.reactor = reactor.reactorForAnnouncement()
                object.navigationPush(announcementViewController, animated: true, bottomBarHidden: true)
            }
            .disposed(by: self.disposeBag)
        
        self.inquiryCellView.rx.didSelect
            .subscribe(onNext: { _ in
                
                let subject = Text.inquiryMailTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let guideMessage = """
                    \(Text.identificationInfo)
                    \(reactor.initialState.tokens.refreshToken)\n
                    \(Text.inquiryMailGuideMessage)
                """
                let body = guideMessage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let mailToString = "mailto:\(Text.adminMailStrUrl)?subject=\(subject)&body=\(body)"

                if let mailtoUrl = URL(string: mailToString),
                   UIApplication.shared.canOpenURL(mailtoUrl) {

                    UIApplication.shared.open(mailtoUrl, options: [:], completionHandler: nil)
                }
            })
            .disposed(by: self.disposeBag)
        
        self.acceptTermsCellView.rx.didSelect
            .subscribe(with: self) { object, _ in
                let rermsOfServiceViewController = TermsOfServiceViewController()
                object.navigationPush(rermsOfServiceViewController, animated: true, bottomBarHidden: true)
            }
            .disposed(by: self.disposeBag)
        
        let version = reactor.state.map(\.version).filterNil().distinctUntilChanged().share()
        self.appVersionCellView.rx.didSelect
            .withLatestFrom(version)
            .subscribe(with: self) { object, version in
                if version.mustUpdate {
                    #if DEVELOP
                    // 개발 버전일 때 testFlight로 전환
                    let strUrl = "\(Text.testFlightStrUrl)/\(Info.appId)"
                    if let testFlightUrl = URL(string: strUrl) {
                        UIApplication.shared.open(testFlightUrl, options: [:], completionHandler: nil)
                    }
                    #elseif PRODUCTION
                    // 운영 버전일 때 app store로 전환
                    let strUrl = "\(Text.appStoreStrUrl)\(Info.appId)"
                    if let appStoreUrl = URL(string: strUrl) {
                        UIApplication.shared.open(appStoreUrl, options: [:], completionHandler: nil)
                    }
                    #endif
                } else {
                    let bottomFloatView = SOMBottomToastView(title: Text.latestVersionToastTitle, actions: nil)
                    
                    var wrapper: SwiftEntryKitViewWrapper = bottomFloatView.sek
                    wrapper.entryName = Text.bottomToastEntryName
                    // TODO: 임시, 하단 네비바 높이를 34로 가정 후 사용
                    wrapper.showBottomToast(verticalOffset: 34 + 8, displayDuration: 4)
                }
            }
            .disposed(by: self.disposeBag)
        
        self.resignCellView.rx.didSelect
            .map { _ in Reactor.Action.rejoinableDate }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map(\.banEndAt)
            .distinctUntilChanged()
            .subscribe(with: self) { object, banEndAt in
                object.postingBlockedBackgroundView.isHidden = (banEndAt == nil)
                object.postingBlockedMessageLabel.text = Text.postingBlockedLeadingGuideMessage +
                    (banEndAt?.banEndDetailFormatted ?? "") +
                    Text.postingBlockedTrailingGuideMessage
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.rejoinableDate)
            .filterNil()
            .subscribe(with: self) { object, rejoinableDate in
                object.showResignDialog(rejoinableDate: rejoinableDate)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.notificationStatus)
            .distinctUntilChanged()
            .bind(to: self.notificationSettingCellView.toggleSwitch.rx.isOn)
            .disposed(by: self.disposeBag)
        
        version
            .subscribe(with: self) { object, version in
                object.appVersionCellView.setLatestVersion(Text.latestVersionTitle + version.latestVersion)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.shouldHideTransfer)
            .distinctUntilChanged()
            .subscribe(with: self) { object, shouldHide in
                object.issueUserTransferCodeCellView.isHidden = shouldHide
                object.enterUserTransferCodeCellView.isHidden = shouldHide
            }
            .disposed(by: self.disposeBag)
    }
}


// MARK: Show dialog

extension SettingsViewController {
    
    func showResignDialog(rejoinableDate: RejoinableDateInfo) {
        
        guard let reactor = self.reactor else { return }
        
        let cancelAction = SOMDialogAction(
            title: Text.cancelActionButtonTitle,
            style: .gray,
            action: {
                UIApplication.topViewController?.dismiss(animated: true) {
                    reactor.action.onNext(.resetState)
                }
            }
        )
        
        let resignAction = SOMDialogAction(
            title: Text.resignTitle,
            style: .primary,
            action: {
                UIApplication.topViewController?.dismiss(animated: true) {
                    let resignViewController = ResignViewController()
                    resignViewController.reactor = reactor.reactorForResign()
                    self.navigationPush(
                        resignViewController,
                        animated: true,
                        bottomBarHidden: true
                    ) { _ in
                        reactor.action.onNext(.resetState)
                    }
                }
            }
        )

        var message: String {
            if rejoinableDate.isActivityRestricted == false {
                return Text.resignDialogMessage
            } else {
                return Text.resignDialogBannedLeadingMessage +
                    rejoinableDate.rejoinableDate.banEndFormatted +
                    Text.resignDialogBannedTrailingMessage
            }
        }
        
        SOMDialogViewController.show(
            title: Text.resignDialogTitle,
            message: message,
            textAlignment: .left,
            actions: [cancelAction, resignAction]
        )
    }
}
