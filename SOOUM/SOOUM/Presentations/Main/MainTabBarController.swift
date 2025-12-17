//
//  MainTabBarController.swift
//  SOOUM
//
//  Created by 오현식 on 9/25/24.
//

import CoreLocation
import UIKit

import ReactorKit
import RxCocoa
import RxSwift

import SnapKit
import Then

class MainTabBarController: SOMTabBarController, View {
    
    enum Constants {
        enum Text {
            static let homeTitle: String = "홈"
            static let writeTitle: String = "카드추가"
            static let tagTitle: String = "태그"
            static let profileTitle: String = "마이"
            
            static let banUserDialogTitle: String = "이용 제한 안내"
            static let banUserDialogFirstLeadingMessage: String = "신고된 카드로 인해 "
            static let banUserDialogFirstTrailingMessage: String = " 카드 추가가 제한됩니다."
            static let banUserDialogSecondLeadingMessage: String = " 카드 추가는 "
            static let banUserDialogSecondTrailingMessage: String = "부터 가능합니다."
            
            static let confirmActionTitle: String = "확인"
        }
        
        static let tabBarItemTitleTypography: Typography = Typography.som.v2.caption1
        
        static let tabBarItemSelectedColor: UIColor = UIColor.som.v2.black
        static let tabBarItemUnSelectedColor: UIColor = UIColor.som.v2.gray400
    }
    
    
    // MARK: Variables
    
    var disposeBag = DisposeBag()
    
    
    // MARK: Variables + Rx
    
    private let willPushWriteCard = PublishRelay<Void>()
    
    
    // MARK: Initialize
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Override func
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hasFirstLaunchGuide = UserDefaults.showGuideMessage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: MainTabBarReactor) {
        
        let homeViewController = HomeViewController()
        homeViewController.reactor = reactor.reactorForHome()
        let mainHomeNavigationController = UINavigationController(
            rootViewController: homeViewController
        )
        mainHomeNavigationController.tabBarItem = .init(
            title: Constants.Text.homeTitle,
            image: .init(.icon(.v2(.filled(.home)))),
            tag: 0
        )
        
        let writeCardViewController = UIViewController()
        writeCardViewController.tabBarItem = .init(
            title: Constants.Text.writeTitle,
            image: .init(.icon(.v2(.filled(.write)))),
            tag: 1
        )
        
        let tagViewController = TagViewController()
        tagViewController.reactor = reactor.reactorForTags()
        let tagNavigationController = UINavigationController(
            rootViewController: tagViewController
        )
        tagNavigationController.tabBarItem = .init(
            title: Constants.Text.tagTitle,
            image: .init(.icon(.v2(.filled(.tag)))),
            tag: 2
        )
        
        let profileViewController = ProfileViewController()
        profileViewController.reactor = reactor.reactorForProfile()
        let profileNavigationController = UINavigationController(
            rootViewController: profileViewController
        )
        profileNavigationController.tabBarItem = .init(
            title: Constants.Text.profileTitle,
            image: .init(.icon(.v2(.filled(.user)))),
            tag: 3
        )
        
        self.viewControllers = [
            mainHomeNavigationController,
            writeCardViewController,
            tagNavigationController,
            profileNavigationController
        ]
        
        // Action
        /// 위치 권한 요청
        self.rx.viewDidLoad
            .map { _ in Reactor.Action.requestLocationPermission }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.rx.viewWillAppear
            .map { _ in Reactor.Action.judgeEntrance }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.willPushWriteCard.throttle(.seconds(3), scheduler: MainScheduler.instance)
            .map { _ in Reactor.Action.postingPermission }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.pulse(\.$profileInfo)
            .filterNil()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, profileInfo in
                
                switch reactor.currentState.entranceType {
                case .pushToDetail:
                    
                    object.didSelectedIndex(0)
                    
                    guard let selectedViewController = object.selectedViewController,
                          let targetCardId = reactor.pushInfo?.targetCardId
                    else { return }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak object] in
                        object?.setupDetailViewController(
                            selectedViewController,
                            with: reactor.reactorForDetail(targetCardId),
                            completion: { reactor.action.onNext(.cleanup) }
                        )
                    }
                case .pushToNotification:
                    
                    object.didSelectedIndex(0)
                    
                    guard let selectedViewController = object.selectedViewController else { return }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak object] in
                        object?.setupNotificationViewController(
                            selectedViewController,
                            with: reactor.reactorForNoti(),
                            completion: { reactor.action.onNext(.cleanup) }
                        )
                    }
                case .pushToTagDetail:
                    
                    object.didSelectedIndex(2)
                    
                    guard let selectedViewController = object.selectedViewController,
                          let targetCardId = reactor.pushInfo?.targetCardId
                    else { return }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak object] in
                        object?.setupTagDetailViewController(
                            selectedViewController,
                            with: reactor.reactorForDetail(targetCardId),
                            completion: { reactor.action.onNext(.cleanup) }
                        )
                    }
                case .pushToFollow:
                    
                    object.didSelectedIndex(3)
                    
                    guard let selectedViewController = object.selectedViewController else { return }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak object] in
                        object?.setupFollowViewController(
                            selectedViewController,
                            with: reactor.reactorForFollow(nickname: profileInfo.nickname, with: profileInfo.userId),
                            completion: { reactor.action.onNext(.cleanup) }
                        )
                    }
                case .pushToLaunchScreen:
                    
                    guard let windowScene: UIWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                        let window: UIWindow = windowScene.windows.first(where: { $0.isKeyWindow })
                    else { return }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak object] in
                        object?.setupLaunchScreenViewController(
                            window,
                            with: reactor.reactorForLaunchScreen()
                        )
                    }
                case .none:
                    
                    break
                }
            }
            .disposed(by: self.disposeBag)
        
        let couldPosting = reactor.pulse(\.$couldPosting).distinctUntilChanged().filterNil()
        couldPosting
            .filter { $0.isBaned == false }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, _ in
                
                object.hasFirstLaunchGuide = false
                
                let writeCardViewController = WriteCardViewController()
                writeCardViewController.reactor = reactor.reactorForWriteCard()
                if let selectedViewController = object.selectedViewController {
                    selectedViewController.navigationPush(
                        writeCardViewController,
                        animated: true
                    ) { _ in
                        reactor.action.onNext(.cleanup)
                    }
                }
            }
            .disposed(by: self.disposeBag)
        couldPosting
            .filter { $0.isBaned }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, postingPermission in
                
                let banEndGapToDays = postingPermission.expiredAt?.infoReadableTimeTakenFromThisForBanEndPosting(to: Date().toKorea())
                let banEndToString = postingPermission.expiredAt?.banEndDetailFormatted
                
                object.showDialog(gapDays: banEndGapToDays ?? "", banEndFormatted: banEndToString ?? "")
            }
            .disposed(by: self.disposeBag)
    }
}


// MARK: SOMTabBarControllerDelegate

extension MainTabBarController: SOMTabBarControllerDelegate {
    
    func tabBarController(
        _ tabBarController: SOMTabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        
        if viewController.tabBarItem.tag == 1 {
            
            self.willPushWriteCard.accept(())
            
            GAHelper.shared.logEvent(event: GAEvent.TabBar.moveToCreateFeedCardView_btn_click)
            
            return false
        }
        
        return true
    }
    
    func tabBarController(
        _ tabBarController: SOMTabBarController,
        didSelect viewController: UIViewController
    ) { }
}


// MARK: Show dialog

private extension MainTabBarController {
    
    func showDialog(gapDays: String, banEndFormatted: String) {
        let dialogFirstMessage = Constants.Text.banUserDialogFirstLeadingMessage +
            gapDays +
            Constants.Text.banUserDialogFirstTrailingMessage
        let dialogSecondMessage = Constants.Text.banUserDialogSecondLeadingMessage +
            banEndFormatted +
            Constants.Text.banUserDialogSecondTrailingMessage
        
        let confirmAction = SOMDialogAction(
            title: Constants.Text.confirmActionTitle,
            style: .primary,
            action: {
                SOMDialogViewController.dismiss {
                    self.reactor?.action.onNext(.cleanup)
                }
            }
        )
        
        SOMDialogViewController.show(
            title: Constants.Text.banUserDialogTitle,
            message: dialogFirstMessage + dialogSecondMessage,
            textAlignment: .left,
            actions: [confirmAction]
        )
    }
}


// MARK: Setup ViewController

private extension MainTabBarController {
    
    func setupDetailViewController(
        _ selectedViewController: UIViewController,
        with reactor: DetailViewReactor,
        completion: @escaping (() -> Void)
    ) {
        
        let detailViewController = DetailViewController()
        detailViewController.reactor = reactor
        selectedViewController.navigationPush(
            detailViewController,
            animated: true,
            completion: { _ in completion() }
        )
    }
    
    func setupNotificationViewController(
        _ selectedViewController: UIViewController,
        with reactor: NotificationViewReactor,
        completion: @escaping (() -> Void)
    ) {
        
        let notificationViewController = NotificationViewController()
        notificationViewController.reactor = reactor
        selectedViewController.navigationPush(
            notificationViewController,
            animated: true,
            completion: { _ in completion() }
        )
    }
    
    func setupTagDetailViewController(
        _ selectedViewController: UIViewController,
        with reactor: DetailViewReactor,
        completion: @escaping (() -> Void)
    ) {
        
        let detailViewController = DetailViewController()
        detailViewController.reactor = reactor
        selectedViewController.navigationPush(
            detailViewController,
            animated: true,
            completion: { _ in completion() }
        )
    }
    
    func setupFollowViewController(
        _ selectedViewController: UIViewController,
        with reactor: FollowViewReactor,
        completion: @escaping (() -> Void)
    ) {
        
        let followViewController = FollowViewController()
        followViewController.reactor = reactor
        selectedViewController.navigationPush(
            followViewController,
            animated: true,
            completion: { _ in completion() }
        )
    }
    
    func setupLaunchScreenViewController(_ window: UIWindow, with reactor: LaunchScreenViewReactor) {
        
        let launchScreenViewController = LaunchScreenViewController()
        launchScreenViewController.reactor = reactor
        window.rootViewController = UINavigationController(rootViewController: launchScreenViewController)
    }
}
