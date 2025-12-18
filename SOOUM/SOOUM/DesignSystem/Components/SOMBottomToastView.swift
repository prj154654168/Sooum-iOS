//
//  SOMBottomToastView.swift
//  SOOUM
//
//  Created by 오현식 on 11/2/25.
//

import UIKit

import SnapKit
import Then

class SOMBottomToastView: UIView {
    
    
    // MARK: Views
    
    private let container = UIView()
    
    private let titleLabel = UILabel().then {
        $0.textColor = .som.v2.white
        $0.typography = .som.v2.caption2
        $0.lineBreakMode = .byTruncatingTail
        $0.lineBreakStrategy = .hangulWordPriority
    }
    
    
    // MARK: Variables
    
    private var actions: [ToastAction]?
    
    
    // MARK: Initalization
    
    convenience init(title: String, actions: [ToastAction]?) {
        self.init(frame: .zero)
        
        self.actions = actions
        self.setupActions(title: title, actions)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SOMBottomToastView {
    
    func setupConstraints() {
        
        self.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width - 8 * 2)
            $0.height.equalTo(40)
        }
        
        self.addSubview(self.container)
        self.container.snp.makeConstraints {
            $0.centerY.trailing.equalToSuperview()
            $0.leading.equalToSuperview().offset(12)
        }
    }
    
    func setupActions(title: String, _ actions: [ToastAction]?) {
        
        self.container.subviews.forEach { $0.removeFromSuperview() }
        
        self.titleLabel.text = title
        self.titleLabel.typography = .som.v2.caption2
        
        self.container.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
        }
        
        guard let actions = actions else { return }
        
        actions.forEach { action in
            
            let button = SOMButton().then {
                $0.title = action.title
                $0.typography = .som.v2.caption1
                $0.foregroundColor = .som.v2.pMain
                
                $0.inset = .init(top: 11, left: 10, bottom: 11, right: 10)
                
                $0.tag = action.tag
                $0.addTarget(self, action: #selector(self.tap(_:)), for: .touchUpInside)
            }
            
            self.container.addSubview(button)
            button.snp.makeConstraints {
                $0.verticalEdges.trailing.equalToSuperview()
                $0.leading.greaterThanOrEqualTo(self.titleLabel.snp.trailing)
                $0.height.equalTo(40)
            }
        }
    }
    
    @objc
    func tap(_ button: UIButton) {
        if let action = self.actions?.first(where: { $0.tag == button.tag }) {
            action.action()
        }
    }
}

extension SOMBottomToastView {
    
    struct ToastAction {
        let tag: Int
        let title: String
        let action: (() -> Void)
        
        init(
            title: String,
            action: @escaping (() -> Void)
        ) {
            self.tag = UUID().hashValue
            self.title = title
            self.action = action
        }
    }
}
