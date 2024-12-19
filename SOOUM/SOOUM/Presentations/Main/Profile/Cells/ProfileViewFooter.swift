//
//  ProfileViewFooter.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/24.
//

import UIKit

import SnapKit
import Then

import RxCocoa
import RxSwift


class ProfileViewFooter: UICollectionReusableView {
    
    enum Text {
        static let blockedText: String = "차단한 계정입니다"
    }
    
    private let flowLayout = SOMTagsLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = .zero
        $0.minimumInteritemSpacing = .zero
        $0.sectionInset = .zero
        $0.estimatedItemSize = .zero
    }
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: self.flowLayout
    ).then {
        $0.alwaysBounceVertical = true
        
        $0.contentInsetAdjustmentBehavior = .never
        $0.contentInset = .zero
        
        $0.showsHorizontalScrollIndicator = false
        
        $0.register(ProfileViewFooterCell.self, forCellWithReuseIdentifier: ProfileViewFooterCell.cellIdentifier)
        
        $0.dataSource = self
        $0.delegate = self
    }
    
    private let blockedLabel = UILabel().then {
        $0.text = Text.blockedText
        $0.textColor = .som.gray400
        $0.typography = .som.body1WithBold
        $0.isHidden = true
    }
    
    private(set) var writtenCards = [WrittenCard]()
    
    let didTap = PublishRelay<String>()
    
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
        
        self.disposeBag = DisposeBag()
    }
    
    private func setupConstraints() {
        
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.addSubview(self.blockedLabel)
        self.blockedLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func setModel(_ writtenCards: [WrittenCard], isBlocked: Bool) {
        self.blockedLabel.isHidden = isBlocked == false
        self.collectionView.isHidden = isBlocked
        
        self.writtenCards = writtenCards
        if self.writtenCards != writtenCards {
            self.collectionView.reloadData()
        }
    }
}

extension ProfileViewFooter: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.writtenCards.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell: ProfileViewFooterCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProfileViewFooterCell.cellIdentifier,
            for: indexPath
        ) as! ProfileViewFooterCell
        let writtenCard = self.writtenCards[indexPath.row]
        cell.setModel(writtenCard)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedId = self.writtenCards[indexPath.row].id
        self.didTap.accept(selectedId)
    }
}

extension ProfileViewFooter: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width: CGFloat = UIScreen.main.bounds.width / 3
        return CGSize(width: width, height: width)
    }
}
