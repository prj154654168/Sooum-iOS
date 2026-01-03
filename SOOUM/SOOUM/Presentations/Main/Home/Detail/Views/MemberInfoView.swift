//
//  MemberInfoView.swift
//  SOOUM
//
//  Created by 오현식 on 11/2/25.
//

import UIKit

import SnapKit
import Then

class MemberInfoView: UIView {
    
    enum Text {
        static let visitedPrefix: String = "조회 "
        static let deletedUserNickname: String = "알 수 없는 사용자"
    }
    
    
    // MARK: Views
    
    /// 상세보기, 멤버 이미지
    let memberBackgroundButton = UIButton()
    private let memberImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .som.v2.gray300
        $0.layer.borderColor = UIColor.som.v2.gray300.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 36 * 0.5
        $0.clipsToBounds = true
    }
    /// 상세보기, 멤버 닉네임
    private let memberLabel = UILabel().then {
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.subtitle2
    }
    
    /// 상세보기, 거리 뷰
    private let distanceBackgroundView = UIView().then {
        $0.backgroundColor = .som.v2.pLight1
        $0.layer.cornerRadius = 21 * 0.5
        $0.clipsToBounds = true
    }
    /// 상세보기, 거리 아이콘
    private let distanceImageView = UIImageView().then {
        $0.image = .init(.icon(.v2(.filled(.location))))
        $0.tintColor = .som.v2.pMain
    }
    /// 상세보기, 거리 라벨
    private let distanceLabel = UILabel().then {
        $0.textColor = .som.v2.pDark
        $0.typography = .som.v2.caption3
    }
    
    /// 상세보기, 타임 갭 라벨
    private let timeGapLabel = UILabel().then {
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.caption2
    }
    
    
    // MARK: Variables
    
    var member: (nickname: String, imgURL: String?)? {
        didSet {
            guard let member = self.member else { return }
            
            if let strUrl = member.imgURL {
                self.memberImageView.setImage(strUrl: strUrl)
            } else {
                self.memberImageView.image = .init(.image(.v2(.profile_small)))
            }
            self.memberLabel.text = member.nickname
        }
    }
    
    var distance: String? {
        didSet {
            guard let distance = self.distance else {
                self.distanceBackgroundView.isHidden = true
                return
            }
            
            self.distanceLabel.text = distance
            self.distanceLabel.typography = .som.v2.caption3
            self.distanceBackgroundView.isHidden = false
        }
    }
    
    var createAt: Date? {
        didSet {
            guard let createAt = self.createAt else { return }
            
            self.timeGapLabel.text = createAt.toKorea().infoReadableTimeTakenFromThis(to: Date().toKorea())
            self.timeGapLabel.typography = .som.v2.caption2
        }
    }
    
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.backgroundColor = .som.v2.white
        
        self.snp.makeConstraints {
            $0.height.equalTo(52)
        }
        
        let container = UIStackView(arrangedSubviews: [
            self.memberImageView,
            self.memberLabel,
            self.distanceBackgroundView
        ]).then {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalSpacing
            $0.spacing = 10
        }
        self.addSubview(container)
        container.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }
        
        self.memberImageView.snp.makeConstraints {
            $0.size.equalTo(36)
        }
        
        self.distanceBackgroundView.snp.makeConstraints {
            $0.height.equalTo(21)
        }
        self.distanceBackgroundView.addSubview(self.distanceImageView)
        self.distanceImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(4)
            $0.size.equalTo(12)
        }
        self.distanceBackgroundView.addSubview(self.distanceLabel)
        self.distanceLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.distanceImageView.snp.trailing).offset(2)
            $0.trailing.equalToSuperview().offset(-6)
        }
        
        self.addSubview(self.timeGapLabel)
        self.timeGapLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(container.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        self.addSubview(self.memberBackgroundButton)
        self.memberBackgroundButton.snp.makeConstraints {
            $0.verticalEdges.equalTo(container.snp.verticalEdges)
            $0.leading.equalTo(container.snp.leading)
            $0.trailing.equalTo(self.memberLabel.snp.trailing)
        }
    }
    
    func updateViewsWhenDeleted() {
        self.memberImageView.image = .init(.image(.v2(.profile_small)))
        self.memberLabel.text = Text.deletedUserNickname
        self.distanceBackgroundView.removeFromSuperview()
        self.timeGapLabel.removeFromSuperview()
    }
}
