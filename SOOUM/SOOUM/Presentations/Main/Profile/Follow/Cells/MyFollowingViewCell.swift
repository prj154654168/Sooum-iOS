//
//  MyFollowingViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 12/7/24.
//

import UIKit

import SnapKit
import Then

import RxSwift

class MyFollowingViewCell: UITableViewCell {
    
    enum Text {
        static let followingButtonTitle: String = "팔로잉"
    }
    
    static let cellIdentifier = String(reflecting: MyFollowingViewCell.self)
    
    
    // MARK: Views
    
    let profileBackgroundButton = UIButton()
    private let profileImageView = UIImageView().then {
        $0.image = .init(.image(.v2(.profile_small)))
        $0.backgroundColor = .som.v2.gray300
        $0.layer.cornerRadius = 36 * 0.5
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.som.v2.gray300.cgColor
        $0.clipsToBounds = true
    }
    
    private let nicknameLabel = UILabel().then {
        $0.textColor = .som.v2.gray600
        $0.typography = .som.v2.subtitle2
    }
    
    let cancelFollowButton = SOMButton().then {
        $0.title = Text.followingButtonTitle
        $0.typography = .som.v2.body1
        $0.foregroundColor = .som.v2.gray600
        
        $0.backgroundColor = .som.v2.gray100
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    
    // MARK: Variables
    
    private(set) var model: FollowInfo = .defaultValue
    
    
    // MARK: Variables + Rx
    
    var disposeBag = DisposeBag()
    
    
    // MARK: Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Override func
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.profileImageView.image = nil
        self.nicknameLabel.text = nil
        
        self.disposeBag = DisposeBag()
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.profileImageView)
        self.profileImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(36)
        }
        
        self.contentView.addSubview(self.nicknameLabel)
        self.nicknameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.profileImageView.snp.trailing).offset(10)
        }
        
        self.contentView.addSubview(self.profileBackgroundButton)
        self.profileBackgroundButton.snp.makeConstraints {
            $0.top.equalTo(self.profileImageView.snp.top)
            $0.bottom.equalTo(self.profileImageView.snp.bottom)
            $0.leading.equalTo(self.profileImageView.snp.leading)
            $0.trailing.equalTo(self.nicknameLabel.snp.trailing)
        }
        
        self.contentView.addSubview(self.cancelFollowButton)
        self.cancelFollowButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(self.nicknameLabel.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(68)
            $0.height.equalTo(32)
        }
    }
    
    
    // MARK: Public func
    
    func setModel(_ model: FollowInfo) {
        
        self.model = model
        
        if let profileImageUrl = model.profileImageUrl {
            self.profileImageView.setImage(strUrl: profileImageUrl)
        } else {
            self.profileImageView.image = .init(.image(.v2(.profile_small)))
        }
        
        self.nicknameLabel.text = model.nickname
        self.nicknameLabel.typography = .som.v2.subtitle2
    }
}
