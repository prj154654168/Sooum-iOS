//
//  HomeGADViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 3/29/26.
//

import UIKit

import SnapKit
import Then

import GoogleMobileAds

final class HomeGADViewCell: UITableViewCell {
    
    static let cellIdentifier = String(reflecting: HomeGADViewCell.self)
    
    enum Text {
        static let adTitleText: String = "AD"
    }
    
    
    // MARK: Views
    
    private lazy var shadowbackgroundView = UIView().then {
        $0.backgroundColor = .som.v2.white
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.som.v2.gray100.cgColor
        $0.layer.cornerRadius = 16
    }
    
    private let nativeAdView = NativeAdView()
    
    private let iconView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .som.v2.gray400
        $0.layer.borderColor = UIColor.som.v2.gray100.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    private let adTitleBackgroundView = UIView().then {
        $0.backgroundColor = .som.v2.gray100
        $0.layer.cornerRadius = 20 * 0.5
    }
    
    private let adTitleLabel = UILabel().then {
        $0.text = Text.adTitleText
        $0.textColor = .som.v2.gray400
        $0.typography = .som.v2.caption3
    }
    
    private let headlineLabel = UILabel().then {
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.subtitle3.withAlignment(.left)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.lineBreakStrategy = .hangulWordPriority
    }
    
    private let bodyLabel = UILabel().then {
        $0.textColor = .som.v2.gray500
        $0.typography = .som.v2.caption2.withAlignment(.left)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.lineBreakStrategy = .hangulWordPriority
    }
    
    
    // MARK: Initialize
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        self.configure()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Override func
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.shadowbackgroundView.setShadow(
            radius: 6,
            color: UIColor(hex: "#ABBED1").withAlphaComponent(0.1),
            blur: 16,
            offset: .init(width: 0, height: 6)
        )
    }
    
    
    // MARK: Private func
    
    private func configure() {
        
        /// mediaView를 등록해야 경고가 발생하지 않음
        let mediaView = MediaView()
        self.nativeAdView.mediaView = mediaView
        
        self.nativeAdView.iconView = self.iconView
        self.nativeAdView.headlineView = self.headlineLabel
        self.nativeAdView.bodyView = self.bodyLabel
    }
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.shadowbackgroundView)
        self.shadowbackgroundView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-10)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.greaterThanOrEqualTo(65)
        }
        
        self.shadowbackgroundView.addSubview(self.nativeAdView)
        self.nativeAdView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.nativeAdView.addSubview(self.iconView)
        self.iconView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(32)
        }
        
        self.nativeAdView.addSubview(self.headlineLabel)
        self.headlineLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalTo(self.iconView.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualToSuperview().offset(-48)
        }
        
        self.nativeAdView.addSubview(self.bodyLabel)
        self.bodyLabel.snp.makeConstraints {
            $0.top.equalTo(self.headlineLabel.snp.bottom).offset(2)
            $0.bottom.equalToSuperview().offset(-12)
            $0.leading.equalTo(self.iconView.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
        }
        
        
        self.adTitleBackgroundView.addSubview(self.adTitleLabel)
        self.adTitleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        self.contentView.addSubview(self.adTitleBackgroundView)
        self.adTitleBackgroundView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-16 * 2)
            $0.width.equalTo(30)
            $0.height.equalTo(20)
        }
        self.contentView.bringSubviewToFront(self.adTitleBackgroundView)
    }
    
    
    // MARK: Public func
    
    func bind(_ model: NativeAd?) {
        
        self.nativeAdView.nativeAd = model
        self.shadowbackgroundView.isHidden = model == nil
        
        if let model = model {
            
            self.shadowbackgroundView.backgroundColor = .som.v2.white
            
            (self.nativeAdView.iconView as? UIImageView)?.image = model.icon?.image
            (self.nativeAdView.headlineView as? UILabel)?.text = model.headline
            (self.nativeAdView.headlineView as? UILabel)?.typography = .som.v2.subtitle3.withAlignment(.left)
            (self.nativeAdView.bodyView as? UILabel)?.text = model.body
            (self.nativeAdView.bodyView as? UILabel)?.typography = .som.v2.caption2.withAlignment(.left)
        } else {
            self.shadowbackgroundView.backgroundColor = .som.v2.gray400
        }
    }
}
