//
//  SOMDialogViewController.swift
//  SOOUM
//
//  Created by JDeoks on 10/3/24.
//

import UIKit

import SnapKit
import Then


class SOMDialogViewController: UIViewController {
    
    
    // MARK: Views
    
    /// container 밖의 영역
    private let backgroundButton = UIButton().then {
        $0.backgroundColor = .som.dim
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = .som.white
        $0.layer.cornerRadius = 20
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.black
        $0.typography = .som.body1WithBold
        $0.lineBreakMode = .byWordWrapping
        $0.lineBreakStrategy = .hangulWordPriority
        $0.numberOfLines = 0
    }
    
    private let messageLabel = UILabel().then {
        $0.textColor = .som.gray600
        $0.typography = .som.body2WithRegular
        $0.lineBreakMode = .byWordWrapping
        $0.lineBreakStrategy = .hangulWordPriority
        $0.numberOfLines = 0
    }
    private let messageView: UIView?
    
    private let buttonContainer = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.spacing = 8
    }
    
    
    // MARK: Variables
    
    private(set) var actions = [SOMDialogAction]()
    
    private var message: String? {
        set {
            if let message = newValue {
                let attributes = Typography.som.body2WithRegular.attributes
                self.messageLabel.attributedText = .init(string: message, attributes: attributes)
            }
            self.messageLabel.isHidden = (newValue == nil)
        }
        get {
            self.messageLabel.text
        }
    }
    
    var dismissesWhenBackgroundTouched: Bool {
        set {
            self.backgroundButton.removeTarget(self, action: #selector(self.touched), for: .touchUpInside)
            if newValue {
                self.backgroundButton.addTarget(self, action: #selector(self.touched), for: .touchUpInside)
            }
            self.backgroundButton.isEnabled = newValue
        }
        get {
            return self.backgroundButton.isEnabled
        }
    }
    
    var completion: ((SOMDialogViewController) -> Void)?
    
    
    // MARK: Objc func
    
    @objc
    private func touched(_ button: UIButton) {
        self.dismiss(animated: true)
    }
    
    @objc
    private func tap(_ button: UIButton) {
        if let action = self.actions.first(where: { $0.tag == button.tag }) {
            action.action?()
        }
    }
    
    
    // MARK: Initalization
    
    convenience init(
        title: String,
        message: String,
        completion: ((SOMDialogViewController) -> Void)? = nil
    ) {
        self.init(title: title, messageView: nil, completion: completion)
        
        self.message = message
    }
    
    init(title: String, messageView: UIView?, completion: ((SOMDialogViewController) -> Void)? = nil) {
        self.messageView = messageView
        
        super.init(nibName: nil, bundle: nil)
        
        self.setupConstraints()
        
        let attributes = Typography.som.body1WithBold.attributes
        self.titleLabel.attributedText = .init(string: title, attributes: attributes)
        self.completion = completion
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Override func
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.completion?(self)
    }

    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.view.addSubview(self.backgroundButton)
        self.backgroundButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.view.addSubview(self.containerView)
        self.containerView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
        }
        
        self.containerView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.greaterThanOrEqualToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
            $0.centerX.equalToSuperview()
        }
        
        if let messageView = self.messageView {
            
            self.containerView.addSubview(messageView)
            messageView.snp.makeConstraints {
                $0.top.equalTo(self.titleLabel.snp.bottom).offset(20)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
            }
        } else {
            
            self.containerView.addSubview(self.messageLabel)
            self.messageLabel.snp.makeConstraints {
                $0.top.equalTo(self.titleLabel.snp.bottom).offset(12)
                $0.leading.greaterThanOrEqualToSuperview().offset(20)
                $0.trailing.lessThanOrEqualToSuperview().offset(-20)
                $0.centerX.equalToSuperview()
            }
        }
        
        self.containerView.addSubview(self.buttonContainer)
        self.buttonContainer.snp.makeConstraints {
            let hasMessage = self.message != nil
            $0.top.equalTo((self.messageView ?? self.messageLabel).snp.bottom).offset(hasMessage ? 20 : 27)
            $0.bottom.equalToSuperview().offset(-14)
            $0.leading.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-14)
            $0.height.equalTo(46)
        }
    }
    
    
    // MARK: Public func
    
    func setAction(_ action: SOMDialogAction) {
        
        self.actions.append(action)
        
        let button = SOMButton().then {
            $0.title = action.title
            $0.typography = .som.body1WithBold
            $0.foregroundColor = action.style.foregroundColor
            
            $0.backgroundColor = action.style.backgroundColor
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }
        button.tag = action.tag
        button.addTarget(self, action: #selector(self.tap), for: .touchUpInside)
        
        self.buttonContainer.addArrangedSubview(button)
    }
}
