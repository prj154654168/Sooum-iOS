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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
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
        
        self.willPushWriteCard
            .map { _ in Reactor.Action.postingPermission }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        Observable.combineLatest(
            reactor.state.map(\.entranceType),
            reactor.state.map(\.profileInfo).filterNil()
        )
            .subscribe(with: self) { object, entranceInfo in
                
                let (entranceType, profileInfo) = entranceInfo
                
                guard let notificationId = reactor.pushInfo?.notificationId,
                      let targetCardId = reactor.pushInfo?.targetCardId
                else { return }
                
                reactor.action.onNext(.requestRead(notificationId))
                
                switch entranceType {
                case .pushToFeedDetail:
                    
                    guard let navigationController = object.viewControllers[0] as? UINavigationController,
                          let homeViewController = navigationController.viewControllers.first as? HomeViewController
                    else { return }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        object.setupDetailViewController(
                            homeViewController,
                            with: reactor.reactorForDetail(targetCardId, type: .feed)
                        )
                    }
                case .pushToCommentDetail:
                    
                    guard let navigationController = object.viewControllers[0] as? UINavigationController,
                          let homeViewController = navigationController.viewControllers.first as? HomeViewController
                    else { return }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        object.setupDetailViewController(
                            homeViewController,
                            with: reactor.reactorForDetail(targetCardId, type: .comment)
                        )
                    }
                case .pushToNotification:
                    
                    guard let navigationController = object.viewControllers[0] as? UINavigationController,
                          let homeViewController = navigationController.viewControllers.first as? HomeViewController
                    else { return }
                    
                    object.setupNotificationViewController(
                        homeViewController,
                        with: reactor.reactorForNoti()
                    )
                case .pushToTagDetail:
                    
                    object.didSelectedIndex(2)
                    
                    guard let navigationController = object.viewControllers[2] as? UINavigationController,
                          let tagViewController = navigationController.viewControllers.first as? TagViewController
                    else { return }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        object.setupTagDetailViewController(
                            tagViewController,
                            with: reactor.reactorForDetail(targetCardId, type: .feed)
                        )
                    }
                case .pushToFollow:
                    
                    object.didSelectedIndex(3)
                    
                    guard let navigationController = object.viewControllers[3] as? UINavigationController,
                          let profileViewController = navigationController.viewControllers.first as? ProfileViewController
                    else { return }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        object.setupFollowViewController(
                            profileViewController,
                            with: reactor.reactorForFollow(
                                nickname: profileInfo.nickname,
                                with: profileInfo.userId
                            )
                        )
                    }
                case .pushToLaunchScreen:
                    
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                        let windowScene: UIWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                        let window: UIWindow = windowScene.windows.first(where: { $0.isKeyWindow })
                    else { return }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        object.setupLaunchScreenViewController(
                            window,
                            with: reactor.reactorForLaunchScreen()
                        )
                    }
                case .none:
                    
                    return
                }
            }
            .disposed(by: self.disposeBag)
        
        let couldPosting = reactor.state.map(\.couldPosting).distinctUntilChanged().filterNil()
        
        couldPosting
            .filter { $0.isBaned == false }
            .subscribe(with: self) { object, _ in
                
                let writeCardViewController = WriteCardViewController()
                writeCardViewController.reactor = reactor.reactorForWriteCard()
                if let selectedViewController = object.selectedViewController {
                    selectedViewController.navigationPush(
                        writeCardViewController,
                        animated: true
                    ) { _ in
                        reactor.action.onNext(.reset)
                    }
                }
            }
            .disposed(by: self.disposeBag)
        
        couldPosting
            .filter { $0.isBaned }
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
                UIApplication.topViewController?.dismiss(animated: true)
            }
        )
        
        SOMDialogViewController.show(
            title: Constants.Text.banUserDialogTitle,
            message: dialogFirstMessage + dialogSecondMessage,
            textAlignment: .left,
            actions: [confirmAction]
        )
    }
    
    func showPrepare() {
        
        let confirmAction = SOMDialogAction(
            title: "확인",
            style: .primary,
            action: {
                UIApplication.topViewController?.dismiss(animated: true)
            }
        )
        
        SOMDialogViewController.show(
            title: "서비스 준비중입니다.",
            message: "추후 개발 완료되면 사용가능합니다.",
            actions: [confirmAction]
        )
    }
}


// MARK: Setup ViewController

private extension MainTabBarController {
    
    func setupDetailViewController(
        _ homeViewController: HomeViewController,
        with reactor: DetailViewReactor
    ) {
        
        let detailViewController = DetailViewController()
        detailViewController.reactor = reactor
        homeViewController.navigationPush(detailViewController, animated: true, bottomBarHidden: true)
    }
    
    func setupNotificationViewController(
        _ homeViewController: HomeViewController,
        with reactor: NotificationViewReactor
    ) {
        
        let notificationViewController = NotificationViewController()
        notificationViewController.reactor = reactor
        homeViewController.navigationPush(notificationViewController, animated: true, bottomBarHidden: true)
    }
    
    func setupTagDetailViewController(
        _ tagViewController: TagViewController,
        with reactor: DetailViewReactor
    ) {
        
        let detailViewController = DetailViewController()
        detailViewController.reactor = reactor
        tagViewController.navigationPush(detailViewController, animated: true, bottomBarHidden: true)
    }
    
    func setupFollowViewController(
        _ profileViewController: ProfileViewController,
        with reactor: FollowViewReactor
    ) {
        
        let followViewController = FollowViewController()
        followViewController.reactor = reactor
        profileViewController.navigationPush(followViewController, animated: true, bottomBarHidden: true)
    }
    
    func setupLaunchScreenViewController(_ window: UIWindow, with reactor: LaunchScreenViewReactor) {
        
        let launchScreenViewController = LaunchScreenViewController()
        launchScreenViewController.reactor = reactor
        window.rootViewController = UINavigationController(rootViewController: launchScreenViewController)
    }
}
