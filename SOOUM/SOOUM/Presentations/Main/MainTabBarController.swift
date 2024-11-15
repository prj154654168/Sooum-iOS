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
    
    let mainHomeViewController = MainHomeViewController()
    let writeCardViewController = WriteCardViewController()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    func bind(reactor: MainTabBarReactor) {
        
        /// 위치 권한 요청
        self.rx.viewDidLoad
            .subscribe(with: self) { object, _ in
                let locationManager = LocationManager.shared
                locationManager.delegate = self
                if locationManager.checkLocationAuthStatus() == .notDetermined {
                    locationManager.requestLocationPermission()
                }
            }
            .disposed(by: self.disposeBag)
        
        /// viewControllers
        self.mainHomeViewController.reactor = reactor.reactorForMainHome()
        self.mainHomeViewController.tabBarItem = .init(
            title: Text.mainHomeTitle,
            image: .init(.icon(.outlined(.home))),
            selectedImage: nil
        )
        
        self.writeCardViewController.tabBarItem = .init(
            title: Text.addCardTitle,
            image: .init(.icon(.outlined(.addCard))),
            selectedImage: nil
        )
        
        let tagViewcontroller = UIViewController()
        tagViewcontroller.tabBarItem = .init(
            title: Text.tagTitle,
            image: .init(.icon(.outlined(.star))),
            selectedImage: nil
        )
        
        let profileViewController = UIViewController()
        profileViewController.tabBarItem = .init(
            title: Text.profileTitle,
            image: .init(.icon(.outlined(.profile))),
            selectedImage: nil
        )
        
        self.viewControllers = [
            self.mainHomeViewController,
            self.writeCardViewController,
            tagViewcontroller,
            profileViewController
        ]
    }
}

extension MainTabBarController: SOMTabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: SOMTabBarController, didSelect viewController: UIViewController) {
        guard viewController == self.writeCardViewController else { return }
        
        let viewController = WriteCardViewController()
        viewController.reactor = self.reactor?.reactorForWriteCard()
        self.navigationPush(viewController, animated: true)
    }
}

extension MainTabBarController: LocationManagerDelegate {
    
    func locationManager(
        _ manager: LocationManager,
        didUpdateCoordinate coordinate: CLLocationCoordinate2D
    ) {
        print("ℹ️ Update location coordinate: \(coordinate)")
    }
    
    func locationManager(_ manager: LocationManager, didChangeAuthStatus status: AuthStatus) {
        print("ℹ️ Change location auth status", status)
    }
    
    func locationManager(_ manager: LocationManager, didFailWithError error: any Error) {
        print("❌ Update location error", error.localizedDescription)
    }
}
