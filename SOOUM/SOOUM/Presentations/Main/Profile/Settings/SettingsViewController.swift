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
        static let commentHistoryTitle: String = "작성된 답카드 히스토리"
        
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
        let range = (Text.userBlockedGuideMessage as NSString).range(of: "정지")
        let typography = Typography.som.body1WithBold
        let attributedString = NSMutableAttributedString(
            string: Text.userBlockedGuideMessage,
            attributes: typography.attributes
        )
        attributedString.addAttribute(.foregroundColor, value: UIColor.som.red, range: range)
        $0.attributedText = attributedString
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
            $0.setCustomSpacing(20, after: self.suggestionCellView)
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
        self.userBlockedBackgroundView.addSubview(userBlockContainer)
        userBlockContainer.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.bottom.equalToSuperview().offset(-22)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    override func bind() {
        super.bind()
        
#if DEVELOP
        self.setupDebugging()
#endif
    }
    
    
    // MARK: ReactorKit bind
    
    func bind(reactor: SettingsViewReactor) {
        
        self.notificationSettingCellView.toggleSwitch.isOn = reactor.initialState.notificationStatus
        
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
                // let enterMemberTransferViewController = EnterMemberTransferViewController()
                // enterMemberTransferViewController.reactor = reactor.reactorForTransferEnter()
                // object.navigationPush(enterMemberTransferViewController, animated: true, bottomBarHidden: true)
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
                    \(reactor.provider.authManager.authInfo.token.refreshToken)\n
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
        
        self.suggestionCellView.rx.didSelect
            .subscribe(onNext: { _ in
                let subject = Text.suggestMailTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let guideMessage = """
                    \(Text.identificationInfo)
                    \(reactor.provider.authManager.authInfo.token.refreshToken)\n
                    \(Text.suggestMailGuideMessage)
                """
                let body = guideMessage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let mailToString = "mailto:\(Text.adminMailStrUrl)?subject=\(subject)&body=\(body)"
                
                if let mailtoUrl = URL(string: mailToString),
                   UIApplication.shared.canOpenURL(mailtoUrl) {
                    
                    UIApplication.shared.open(mailtoUrl, options: [:], completionHandler: nil)
                }
            })
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
        
        reactor.state.map(\.notificationStatus)
            .distinctUntilChanged()
            .bind(to: self.notificationSettingCellView.toggleSwitch.rx.isOn)
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

extension SettingsViewController {
    
    private func setupDebugging() {
        
        let longPressRecognizer = UILongPressGestureRecognizer()
        self.appSettingHeader.addGestureRecognizer(longPressRecognizer)
        
        longPressRecognizer.rx.event
            .flatMapLatest { _ in Log.extract() }
            .subscribe(
                with: self,
                onNext: { object, viewController in
                    object.navigationController?.present(viewController, animated: true)
                },
                onError: { _, error in
                    Log.error(error.localizedDescription)
                }
            )
            .disposed(by: self.disposeBag)
    }
}
