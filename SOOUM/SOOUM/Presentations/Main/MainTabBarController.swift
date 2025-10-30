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
            static let userTitle: String = "마이"
            
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
        
        let tagViewController = UIViewController()
        tagViewController.tabBarItem = .init(
            title: Constants.Text.tagTitle,
            image: .init(.icon(.v2(.filled(.tag)))),
            tag: 2
        )
        
        let userViewController = UIViewController()
        userViewController.tabBarItem = .init(
            title: Constants.Text.userTitle,
            image: .init(.icon(.v2(.filled(.user)))),
            tag: 3
        )
        
        self.viewControllers = [
            mainHomeNavigationController,
            writeCardViewController,
            tagViewController,
            userViewController
        ]
        
        self.rx.viewDidLoad
            .subscribe(with: self) { object, _ in
                // 위치 권한 요청
                if reactor.locationManager.checkLocationAuthStatus() == .notDetermined {
                    reactor.locationManager.requestLocationPermission()
                }
            }
            .disposed(by: self.disposeBag)
        
        // Action
        
        self.rx.viewWillAppear
            .map { _ in Reactor.Action.judgeEntrance }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.willPushWriteCard
            .map { _ in Reactor.Action.postingPermission }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        
        reactor.state.map(\.entranceType)
            .distinctUntilChanged()
            .subscribe(with: self) { object, entranceType in
                
//                guard let navigationController = object.viewControllers[0] as? UINavigationController,
//                      let mainHomeTabBarController = navigationController.viewControllers.first as? MainHomeTabBarController,
//                      let targetCardId = reactor.pushInfo?.targetCardId,
//                      let notificationId = reactor.pushInfo?.notificationId
//                else { return }
//                
//                mainHomeTabBarController.reactor?.action.onNext(.requestRead(notificationId))
//                
//                switch entranceType {
//                case .pushForNoti:
//                    
//                    let notificationTabBarController = NotificationTabBarController()
//                    notificationTabBarController.reactor = reactor.reactorForNoti()
//                    mainHomeTabBarController.navigationPush(
//                        notificationTabBarController,
//                        animated: false,
//                        bottomBarHidden: true
//                    )
//                case .pushForDetail:
//                    
//                    let detailViewController = DetailViewController()
//                    detailViewController.reactor = reactor.reactorForDetail(targetCardId)
//                    mainHomeTabBarController.navigationPush(
//                        detailViewController,
//                        animated: false,
//                        bottomBarHidden: true
//                    )
//                case .none:
//                    break
//                }
            }
            .disposed(by: self.disposeBag)
        
        let couldPosting = reactor.state.map(\.couldPosting).filterNil()
        
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
        
        if viewController.tabBarItem.tag == 2 || viewController.tabBarItem.tag == 3 {
            self.showPrepare()
            
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
