//
//  SelectVoteView.swift
//  SOOUM
//
//  Created by 오현식 on 6/30/26.
//

import UIKit

import SnapKit
import Then

import RxCocoa
import RxGesture
import RxSwift

class SelectVoteView: UIView {
    
    enum Text {
        static let title: String = "투표"
    }
    
    
    // MARK: Views
    
    private let titleLabel = UILabel().then {
        $0.text = Text.title
        $0.textColor = .som.v2.pDark
        $0.typography = .som.v2.caption1
    }
    
    private let editButton = SOMButton().then {
        $0.image = UIImage(.icon(.v2(.filled(.pencil))))?.resized(
            .init(width: 16, height: 16),
            color: .som.v2.black
        )
        $0.foregroundColor = .som.v2.black
        
        $0.backgroundColor = .som.v2.gray100
        $0.layer.cornerRadius = 24 * 0.5
        $0.clipsToBounds = true
    }
    
    private let deleteButton = SOMButton().then {
        $0.image = .init(.icon(.v2(.outlined(.delete))))
        $0.foregroundColor = .som.v2.black
        
        $0.backgroundColor = .som.v2.gray100
        $0.layer.cornerRadius = 24 * 0.5
        $0.clipsToBounds = true
    }
    
    private let container = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 8
    }
    
    
    // MARK: Variables
    
    var items: [String] = [] {
        didSet {
            self.setupItems(self.items)
        }
    }
    
    var editButtonTap: ControlEvent<Void> {
        self.editButton.rx.tap
    }
    
    var deleteButtonTap: ControlEvent<Void> {
        self.deleteButton.rx.tap
    }
    
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        
        self.addSubview(self.deleteButton)
        self.deleteButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
            $0.size.equalTo(24)
        }
        
        self.addSubview(self.editButton)
        self.editButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalTo(self.deleteButton.snp.leading).offset(-8)
            $0.size.equalTo(24)
        }
        
        self.addSubview(self.container)
        self.container.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
    
    private func setupItems(_ items: [String]) {
        self.container.arrangedSubviews.forEach {
            self.container.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        items.forEach { value in
            
            let backgroundView = UIView().then {
                $0.backgroundColor = .som.v2.gray100
                $0.layer.cornerRadius = 10
            }
            
            let label = UILabel().then {
                $0.text = value
                $0.textColor = .som.v2.black
                $0.textAlignment = .left
                $0.typography = .som.v2.subtitle1.withAlignment(.left)
            }
            
            self.container.addArrangedSubview(backgroundView)
            backgroundView.snp.makeConstraints {
                $0.horizontalEdges.equalToSuperview()
                $0.height.equalTo(48)
            }
            
            backgroundView.addSubview(label)
            label.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.lessThanOrEqualToSuperview().offset(-20)
            }
        }
    }
}
