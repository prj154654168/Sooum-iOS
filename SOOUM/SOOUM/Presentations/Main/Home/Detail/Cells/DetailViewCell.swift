//
//  DetailViewCell.swift
//  SOOUM
//
//  Created by 오현식 on 10/3/24.
//

import UIKit

import RxSwift

import SnapKit
import Then


class DetailViewCell: UICollectionViewCell {
    
    enum Text {
        static let prevCardTitle: String = "전글"
        static let pungedPrevCardTitle: String = "삭제됨"
    }
    
    let cardView = SOMCard().then {
        $0.likeInfoStackView.isHidden = true
        $0.commentInfoStackView.isHidden = true
    }
    
    let prevCardBackgroundButton = UIButton().then {
        $0.isHidden = true
    }
    /// 상세보기, 전글 배경
    let prevCardBackgroundImageView = UIImageView().then {
        $0.layer.borderColor = UIColor.som.white.cgColor
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 14
        $0.layer.masksToBounds = true
        $0.isHidden = true
    }
    /// 상세보기, 전글 라벨
    let prevCardTextLabel = UILabel().then {
        $0.text = Text.prevCardTitle
        $0.textColor = .som.white
        $0.textAlignment = .center
        $0.typography = .init(
            fontContainer: Pretendard(size: 14, weight: .medium),
            lineHeight: 15.56,
            letterSpacing: -0.04
        )
    }
    
    /// 상세보기, 상단 오른쪽 (더보기/삭제) 버튼, 기본 = 더보기
    let rightTopSettingButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .init(.icon(.outlined(.more)))
        config.image?.withTintColor(.som.gray04)
        config.imageColorTransformer = UIConfigurationColorTransformer { _ in .som.gray04 }
        $0.configuration = config
    }
    
    lazy var tags = SOMTags()
    
    var isOwnCard: Bool = false {
        didSet {
            let image = UIImage(.icon(.outlined(self.isOwnCard ? .trash : .more)))
            self.rightTopSettingButton.configuration?.image = image
        }
    }
    
    var prevCard: PrevCard = .init() {
        didSet {
            if prevCard.previousCardImgLink.url.isEmpty {
                self.isPrevCardExist = false
            } else {
                self.isPrevCardExist = true
                self.prevCardBackgroundImageView.setImage(strUrl: prevCard.previousCardImgLink.url)
            }
        }
    }
    private var isPrevCardExist: Bool = false {
        didSet {
            self.prevCardBackgroundImageView.isHidden = !self.isPrevCardExist
            self.prevCardBackgroundButton.isHidden = !self.isPrevCardExist
        }
    }
    
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cardView.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    
    private func setupConstraints() {
        
        self.contentView.addSubview(self.cardView)
        self.cardView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            let width: CGFloat = UIScreen.main.bounds.width - 20 * 2
            $0.height.equalTo(width)
        }
        
        self.contentView.addSubview(self.prevCardBackgroundImageView)
        self.prevCardBackgroundImageView.snp.makeConstraints {
            $0.top.equalTo(self.cardView.snp.top).offset(16)
            $0.leading.equalTo(self.cardView.snp.leading).offset(16)
            $0.size.equalTo(44)
        }
        
        self.prevCardBackgroundImageView.addSubviews(self.prevCardTextLabel)
        self.prevCardTextLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        self.contentView.addSubview(self.prevCardBackgroundButton)
        self.prevCardBackgroundButton.snp.makeConstraints {
            $0.top.equalTo(self.cardView.snp.top).offset(16)
            $0.leading.equalTo(self.cardView.snp.leading).offset(16)
            $0.size.equalTo(44)
        }
        
        self.contentView.addSubview(self.rightTopSettingButton)
        self.rightTopSettingButton.snp.makeConstraints {
            $0.top.equalTo(self.cardView.snp.top).offset(26)
            $0.trailing.equalTo(self.cardView.snp.trailing).offset(-26)
            $0.size.equalTo(24)
        }
        
        self.contentView.addSubview(self.tags)
        self.tags.snp.makeConstraints {
            $0.top.equalTo(self.cardView.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
            let isEmpty = self.tags.models.isEmpty
            $0.height.equalTo(isEmpty ? 40 : 59)
        }
    }
    
    func setDatas(_ model: SOMCardModel, tags: [SOMTagModel]) {
        self.cardView.setModel(model: model)
        self.tags.setDatas(tags)
        self.tags.snp.updateConstraints {
            $0.height.equalTo(tags.isEmpty ? 40 : 59)
        }
    }
}
