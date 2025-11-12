//
//  BaseViewController.swift
//  SOOUM
//
//  Created by 오현식 on 9/21/24.
//

import UIKit

import Network

import RxKeyboard
import RxSwift

import SnapKit
import Then

import Lottie

class BaseViewController: UIViewController {
    
    enum Text {
        static let bottomToastEntryName: String = "bottomToastEntryName"
        static let instabilityNetworkToastTitle: String = "네트워크 연결이 원활하지 않습니다. 네트워크 확인 후 재접속해주세요"
    }

    var disposeBag = DisposeBag()
    
    private let monitor = NWPathMonitor()
    
    private let instabilityNetworkToastView = SOMBottomToastView(title: Text.instabilityNetworkToastTitle, actions: nil)
    
    let activityIndicatorView = SOMActivityIndicatorView()
    let loadingIndicatorView = SOMLoadingIndicatorView()

    private(set) var isEndEditingWhenWillDisappear: Bool = true
    private(set) var bottomToastMessageOffset: CGFloat = 88
    
    override var hidesBottomBarWhenPushed: Bool {
        didSet {
            NotificationCenter.default.post(name: .hidesBottomBarWhenPushedDidChange, object: self)
        }
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// show deinit class name and remove all observer
    deinit {
        NotificationCenter.default.removeObserver(self)
        Log.debug("Deinit: ", type(of: self).description().components(separatedBy: ".").last ?? "")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .som.v2.white
        self.setupConstraints()
        
        self.activityIndicatorView.color = .black
        
        self.view.addSubview(self.activityIndicatorView)
        self.activityIndicatorView.snp.makeConstraints {
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
            $0.centerY.equalTo(self.view.safeAreaLayoutGuide.snp.centerY)
        }
        
        self.view.addSubview(self.loadingIndicatorView)
        self.loadingIndicatorView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        self.bind()

        RxKeyboard.instance.visibleHeight
            .drive(with: self) { object, height in
                let connectedScene: UIScene? = UIApplication.shared.connectedScenes.first
                let sceneDelegate: SceneDelegate? = connectedScene?.delegate as? SceneDelegate
                let safeAreaInsetBottom: CGFloat = sceneDelegate?.window?.safeAreaInsets.bottom ?? 0
                let withoutBottomSafeInset: CGFloat = max(0, height - safeAreaInsetBottom)
                object.updatedKeyboard(withoutBottomSafeInset: withoutBottomSafeInset)
            }
            .disposed(by: self.disposeBag)
        
        SimpleReachability.shared.isConnected
            .skip(1)
            .filter { $0 == false }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, _ in
                guard object.isViewLoaded, object.view.window != nil else { return }
                
                var wrapper: SwiftEntryKitViewWrapper = self.instabilityNetworkToastView.sek
                wrapper.entryName = Text.bottomToastEntryName
                wrapper.showBottomToast(verticalOffset: self.bottomToastMessageOffset, displayDuration: 4)
            }
            .disposed(by: self.disposeBag)
    }

    /// Set auto layouts
    func setupConstraints() {
        // override point
    }
    /// View action with rx
    func bind() {
        // override point
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.setupNaviBar()
    }
    /// Set navigationBar
    func setupNaviBar() {
        // override point
    }

    func updatedKeyboard(withoutBottomSafeInset height: CGFloat) {
        // override point
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isEndEditingWhenWillDisappear {
            self.view.endEditing(true)
        }
    }
}
