//
//  SelectProfileBottomFloatView.swift
//  SOOUM
//
//  Created by 오현식 on 9/12/25.
//

import UIKit

import SnapKit
import Then

class SelectProfileBottomFloatView: UIView {
    
    
    // MARK: Views
    
    private let container = UIStackView().then {
        $0.axis = .vertical
    }
    
    
    // MARK: Variables
    
    private var actions: [FloatAction]?
    
    
    // MARK: Initalization
    
    convenience init(actions: [FloatAction]) {
        self.init(frame: .zero)
        
        self.actions = actions
        self.setupActions(actions)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SelectProfileBottomFloatView {
    
    func setupConstraints() {
        
        self.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width -  16 * 2)
        }
        
        let handleView = UIView().then {
            $0.backgroundColor = .som.v2.gray300
            $0.layer.cornerRadius = 2
        }
        self.addSubview(handleView)
        handleView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(44)
            $0.height.equalTo(4)
        }
        
        self.addSubview(self.container)
        self.container.snp.makeConstraints {
            $0.top.equalTo(handleView.snp.bottom).offset(14)
            $0.bottom.equalToSuperview().offset(-16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
    
    func setupActions(_ actions: [FloatAction]) {
        
        self.container.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        actions.forEach { action in
            
            let button = SOMButton().then {
                $0.title = action.title
                $0.typography = .som.v2.subtitle1
                $0.foregroundColor = .som.v2.gray500
                $0.backgroundColor = .som.v2.white
                $0.inset = .init(top: 12, left: 16, bottom: 12, right: 16)
                
                $0.contentHorizontalAlignment = .left
                
                $0.tag = action.tag
                $0.addTarget(self, action: #selector(self.tap(_:)), for: .touchUpInside)
            }
            button.snp.makeConstraints {
                $0.height.equalTo(48)
            }
            
            self.container.addArrangedSubview(button)
        }
    }
    
    @objc
    func tap(_ button: UIButton) {
        if let action = self.actions?.first(where: { $0.tag == button.tag }) {
            action.action()
        }
    }
}

extension SelectProfileBottomFloatView {
    
    struct FloatAction {
        let tag: Int
        let title: String
        let action: (() -> Void)
        
        init(title: String, action: @escaping (() -> Void)) {
            self.tag = UUID().hashValue
            self.title = title
            self.action = action
        }
    }
}
