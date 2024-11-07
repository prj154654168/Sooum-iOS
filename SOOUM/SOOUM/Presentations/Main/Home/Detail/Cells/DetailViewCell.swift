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
        static let deletedCardInDetailText: String = "이 글은 삭제되었어요"
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
        $0.backgroundColor = .clear
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
        $0.typography = .som.body2WithBold
    }
    
    /// 상세보기, 상단 오른쪽 (더보기/삭제) 버튼, 기본 = 더보기
    let rightTopSettingButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .init(.icon(.outlined(.more)))
        config.image?.withTintColor(.som.gray300)
        config.imageColorTransformer = UIConfigurationColorTransformer { _ in .som.gray300 }
        $0.configuration = config
    }
    
    /// 상세보기, 카드 삭제 됐을 때 배경
    let deletedCardInDetailBackgroundView = UIView().then {
        $0.backgroundColor = .init(hex: "#F8F8F8")
        $0.layer.cornerRadius = 40
        $0.layer.masksToBounds = true
        $0.isHidden = true
    }
    /// 상세보기, 카드 삭제 됐을 때 이미지
    let deletedCardInDetailImageView = UIImageView().then {
        $0.image = .init(.icon(.outlined(.trash)))
        $0.tintColor = .som.gray300
    }
    /// 상세보기, 카드 삭제 됐을 때 라벨
    let deletedCardInDetailLabel = UILabel().then {
        $0.text = Text.deletedCardInDetailText
        $0.textColor = .som.gray500
        $0.textAlignment = .center
        $0.typography = .som.body1WithBold
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
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(36)
            $0.size.equalTo(44)
        }
        self.prevCardBackgroundImageView.addSubviews(self.prevCardTextLabel)
        self.prevCardTextLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        self.contentView.addSubview(self.prevCardBackgroundButton)
        self.prevCardBackgroundButton.snp.makeConstraints {
            $0.edges.equalTo(self.prevCardBackgroundImageView.snp.edges)
        }
        
        self.contentView.addSubview(self.rightTopSettingButton)
        self.rightTopSettingButton.snp.makeConstraints {
            $0.top.equalTo(self.cardView.snp.top).offset(26)
            $0.trailing.equalTo(self.cardView.snp.trailing).offset(-26)
            $0.size.equalTo(24)
        }
        
        self.contentView.addSubview(self.deletedCardInDetailBackgroundView)
        self.deletedCardInDetailBackgroundView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            let width: CGFloat = UIScreen.main.bounds.width - 20 * 2
            $0.height.equalTo(width)
        }
        
        let container = UIStackView(arrangedSubviews: [
            self.deletedCardInDetailImageView,
            self.deletedCardInDetailLabel
        ]).then {
            $0.axis = .vertical
            $0.alignment = .center
        }
        self.deletedCardInDetailBackgroundView.addSubview(container)
        container.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        self.deletedCardInDetailImageView.snp.makeConstraints {
            $0.size.equalTo(60)
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
        self.tags.setModels(tags)
        self.tags.snp.updateConstraints {
            $0.height.equalTo(tags.isEmpty ? 40 : 59)
        }
    }
    
    func isDeleted() {
        self.cardView.removeFromSuperview()
        self.rightTopSettingButton.removeFromSuperview()
        self.deletedCardInDetailBackgroundView.isHidden = false
    }
}
