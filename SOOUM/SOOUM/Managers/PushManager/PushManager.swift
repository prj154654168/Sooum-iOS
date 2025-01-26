//
//  PushManager.swift
//  SOOUM
//
//  Created by 오현식 on 12/12/24.
//

import UIKit


protocol PushManagerDelegate: AnyObject {
    
    var window: UIWindow? { get }
    func setupRootViewController(_ info: NotificationInfo?, terminated: Bool)
    
    var canReceiveNotifications: Bool { get }
    var notificationStatus: Bool { get }
    func switchNotification(isOn: Bool, completion: ((Error?) -> Void)?)
}

class PushManager: CompositeManager<PushManagerConfiguration> {
    
    var window: UIWindow? {
        let application = UIApplication.shared
        if let windowScene: UIWindowScene = application.connectedScenes.first as? UIWindowScene,
           let window: UIWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return window
        } else {
            return nil
        }
    }
    
    var canReceiveNotifications: Bool = true
    @objc dynamic var notificationStatus: Bool = true
    
    override init(provider: ManagerTypeDelegate, configure: PushManagerConfiguration) {
        super.init(provider: provider, configure: configure)
        
        self.registerNotificationObserver()
        self.updateNotificationStatus()
    }
}

extension PushManager: PushManagerDelegate {
    
    
    // MARK: Navigation
    
    func setupRootViewController(_ info: NotificationInfo?, terminated: Bool) {
        
        DispatchQueue.main.async { [weak self] in
            if self?.window != nil {
                if terminated {
                    self?.setupLaunchScreenViewController(info)
                } else {
                    self?.setupMainTabBarController(info)
                }
            }
        }
    }
    
    fileprivate func setupLaunchScreenViewController(_ pushInfo: NotificationInfo?) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let provider = appDelegate.provider
        
        let launchScreenReactor = LaunchScreenViewReactor(provider: provider, pushInfo: pushInfo)
        let launchScreenViewController = LaunchScreenViewController()
        launchScreenViewController.reactor = launchScreenReactor
        
        let navigationController = UINavigationController(rootViewController: launchScreenViewController)
        self.window?.rootViewController = navigationController
    }
    
    fileprivate func setupMainTabBarController(_ pushInfo: NotificationInfo?) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let provider = appDelegate.provider
        
        let mainTabBarReactor = MainTabBarReactor(provider: provider, pushInfo: pushInfo)
        let mainTabBarController = MainTabBarController()
        mainTabBarController.reactor = mainTabBarReactor
        
        let navigationController = UINavigationController(rootViewController: mainTabBarController)
        self.window?.rootViewController = navigationController
    }
    
    
    // MARK: Notification

    private func registerNotificationObserver() {

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateNotificationStatus),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        self.updateNotificationStatus()
    }

    @objc
    private func updateNotificationStatus() {

        UNUserNotificationCenter.current()
            .getNotificationSettings { [weak self] settings in
                let authorized: Bool = (settings.authorizationStatus == .authorized)
                DispatchQueue.main.async { [weak self] in
                    if authorized && UIApplication.shared.isRegisteredForRemoteNotifications == false {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    let registered: Bool = UIApplication.shared.isRegisteredForRemoteNotifications
                    let localStatus: Bool = SimpleDefaults.shared.loadRemoteNotificationActivation()
                    self?.canReceiveNotifications = registered && authorized
                    self?.notificationStatus = localStatus && registered && authorized
                }
            }
    }

    func switchNotification(isOn: Bool, completion: ((Error?) -> Void)? = nil) {

        DispatchQueue.main.async { [weak self] in

            let application: UIApplication = .shared
            self?.notificationStatus = isOn
            SimpleDefaults.shared.saveRemoteNotificationActivation(isOn)

            if isOn {

                let appDelegate: AppDelegate? = application.delegate as? AppDelegate
                appDelegate?.registerRemoteNotificationCompletion = { [weak self] error in
                    if let error: Error = error {
                        self?.notificationStatus = false
                        completion?(error)
                    } else {
                        completion?(nil)
                    }
                }

                UNUserNotificationCenter.current().requestAuthorization(
                    options: [.alert, .badge, .sound],
                    completionHandler: { granted, error in
                        DispatchQueue.main.async { [weak self] in
                            if granted {
                                application.registerForRemoteNotifications()
                                self?.updateNotificationStatus()
                            } else {
                                self?.notificationStatus = false
                                if let error: Error = error {
                                    completion?(error)
                                } else {
                                    completion?(nil)
                                }
                            }
                        }
                    }
                )
            } else {
                application.unregisterForRemoteNotifications()
                completion?(nil)
            }
        }
    }
}

extension PushManagerDelegate {

    func switchNotification(isOn: Bool, completion: ((Error?) -> Void)? = nil) { }
}
