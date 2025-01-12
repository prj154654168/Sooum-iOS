//
//  MainTabBarController.swift
//  SOOUM
//
//  Created by 오현식 on 9/25/24.
//

import CoreLocation
import UIKit

import ReactorKit
import RxSwift

import SnapKit
import Then


class MainTabBarController: SOMTabBarController, View {
    
    enum Text {
        static let mainHomeTitle: String = "메인홈"
        static let addCardTitle: String = "글추가"
        static let tagTitle: String = "태그"
        static let profileTitle: String = "프로필"
    }
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func bind(reactor: MainTabBarReactor) {
        
        self.rx.viewDidLoad
            .subscribe(with: self) { object, _ in
                // 위치 권한 요청
                let locationManager = LocationManager.shared
                locationManager.delegate = object
                if locationManager.checkLocationAuthStatus() == .notDetermined {
                    locationManager.requestLocationPermission()
                }
                
                // 알리 권한 요청
                let pushManager = PushManager.shared
                pushManager.switchNotification(isOn: true)
            }
            .disposed(by: self.disposeBag)
        
        // viewControllers
        let mainHomeTabBarController = MainHomeTabBarController()
        mainHomeTabBarController.reactor = reactor.reactorForMainHome()
        let mainHomeNavigationController = UINavigationController(
            rootViewController: mainHomeTabBarController
        )
        mainHomeTabBarController.tabBarItem = .init(
            title: Text.mainHomeTitle,
            image: .init(.icon(.outlined(.home))),
            tag: 0
        )
        
        let writeCardViewController = UIViewController()
        writeCardViewController.tabBarItem = .init(
            title: Text.addCardTitle,
            image: .init(.icon(.outlined(.addCard))),
            tag: 1
        )
        
        let tagViewcontroller = TagsViewController()
        tagViewcontroller.reactor = TagsViewReactor()
        tagViewcontroller.tabBarItem = .init(
            title: Text.tagTitle,
            image: .init(.icon(.outlined(.star))),
            tag: 2
        )
        
        let profileViewController = ProfileViewController()
        profileViewController.reactor = reactor.reactorForProfile()
        let profileNavigationController = UINavigationController(
            rootViewController: profileViewController
        )
        profileNavigationController.tabBarItem = .init(
            title: Text.profileTitle,
            image: .init(.icon(.outlined(.profile))),
            tag: 3
        )
        
        self.viewControllers = [
            mainHomeNavigationController,
            writeCardViewController,
            tagViewcontroller,
            profileNavigationController
        ]
        
        self.rx.viewWillAppear
            .map { _ in Reactor.Action.judgeEntrance }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.entranceType)
            .distinctUntilChanged()
            .subscribe(with: self) { object, entranceType in
                
                guard let navigationController = object.viewControllers[0] as? UINavigationController,
                      let mainHomeTabBarController = navigationController.viewControllers.first as? MainHomeTabBarController,
                      let targetCardId = reactor.pushInfo?.targetCardId,
                      let notificationId = reactor.pushInfo?.notificationId
                else { return }
                
                mainHomeTabBarController.reactor?.action.onNext(.requestRead(notificationId))
                
                switch entranceType {
                case .pushForNoti:
                    
                    let notificationTabBarController = NotificationTabBarController()
                    notificationTabBarController.reactor = reactor.reactorForNoti()
                    mainHomeTabBarController.navigationPush(
                        notificationTabBarController,
                        animated: false,
                        bottomBarHidden: true
                    )
                case .pushForDetail:
                    
                    let detailViewController = DetailViewController()
                    detailViewController.reactor = reactor.reactorForDetail(targetCardId)
                    mainHomeTabBarController.navigationPush(
                        detailViewController,
                        animated: false,
                        bottomBarHidden: true
                    )
                default: break
                }
            }
            .disposed(by: self.disposeBag)
    }
}

extension MainTabBarController: SOMTabBarControllerDelegate {
    
    func tabBarController(
        _ tabBarController: SOMTabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        
        if viewController.tabBarItem.tag == 1 {
        
            let writeCardViewController = WriteCardViewController()
            writeCardViewController.reactor = self.reactor?.reactorForWriteCard()
            if let selectedViewController = tabBarController.selectedViewController {
                selectedViewController.navigationPush(writeCardViewController, animated: true)
            }
            return false
        }
         
        return true
    }
    
    
    func tabBarController(
        _ tabBarController: SOMTabBarController,
        didSelect viewController: UIViewController
    ) { }
}

extension MainTabBarController: LocationManagerDelegate {
    
    func locationManager(
        _ manager: LocationManager,
        didUpdateCoordinate coordinate: CLLocationCoordinate2D
    ) {
        Log.debug("Update location coordinate: \(coordinate)")
    }
    
    func locationManager(_ manager: LocationManager, didChangeAuthStatus status: AuthStatus) {
        Log.debug("Change location auth status", status)
    }
    
    func locationManager(_ manager: LocationManager, didFailWithError error: any Error) {
        Log.error("Update location error", error.localizedDescription)
    }
}
