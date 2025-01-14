//
//  BaseViewController.swift
//  SOOUM
//
//  Created by 오현식 on 9/21/24.
//

import UIKit

import RxKeyboard
import RxSwift

import SnapKit
import Then


class BaseViewController: UIViewController {

    var disposeBag = DisposeBag()
    
    let activityIndicatorView = SOMActivityIndicatorView()

    private(set) var isEndEditingWhenWillDisappear: Bool = true
    
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
    /// Show deinit class name
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: .hidesBottomBarWhenPushedDidChange,
            object: nil
        )
        Log.debug("Deinit: ", type(of: self).description().components(separatedBy: ".").last ?? "")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.setupConstraints()
        
        self.activityIndicatorView.color = .black
        
        self.view.addSubview(self.activityIndicatorView)
        self.activityIndicatorView.snp.makeConstraints {
            $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
            $0.centerY.equalTo(self.view.safeAreaLayoutGuide.snp.centerY)
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
