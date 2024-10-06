//
//  DetailViewController.swift
//  SOOUM
//
//  Created by 오현식 on 10/1/24.
//

import UIKit

import SnapKit
import SwiftEntryKit
import Then

import ReactorKit
import RxCocoa
import RxSwift


 class DetailViewController: BaseNavigationViewController, View {
     
     enum Text {
         static let moreBottomSheetEntryName = "moreButtonBottomSheetViewController"
     }
    
     let titleImageView = UIImageView().then {
         $0.backgroundColor = .clear
     }
     
     let titleLabel = UILabel().then {
         $0.textColor = .som.black
         $0.textAlignment = .center
         $0.typography = .init(
            fontContainer: Pretendard(size: 16, weight: .bold),
            lineHeight: 16,
            letterSpacing: -0.02
         )
     }
     
     let rightHomeButton = UIButton().then {
         var config = UIButton.Configuration.plain()
         config.image = .init(.icon(.outlined(.home)))
         config.image?.withTintColor(.som.black)
         config.imageColorTransformer = UIConfigurationColorTransformer { _ in .som.black }
         $0.configuration = config
     }
     
     private let flowLayout = UICollectionViewFlowLayout().then {
         $0.scrollDirection = .vertical
     }
     
     lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: self.flowLayout
     ).then {
         $0.alwaysBounceVertical = true
         $0.backgroundColor = .som.white
         $0.indicatorStyle = .black
         $0.refreshControl = UIRefreshControl().then {
             $0.tintColor = .som.black
         }
         
         $0.register(DetailViewCell.self, forCellWithReuseIdentifier: "cell")
         $0.register(
            DetailViewFooter.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "footer"
         )
         
         $0.dataSource = self
         $0.delegate = self
     }
     
     let moreButtonBottomSheetViewController = MoreBottomSheetViewController()
     
     override var navigationBarHeight: CGFloat {
         58
     }
     
     var detailCard = Card()
     var tags = [SOMTagModel]()
     
     var commentCards = [Card]()
     
     
     // MARK: - Life Cycles
     
     override func setupNaviBar() {
         super.setupNaviBar()
         
         let titleContainer = UIStackView(arrangedSubviews: [
            self.titleImageView,
            self.titleLabel
         ]).then {
             $0.axis = .horizontal
             $0.alignment = .center
             $0.distribution = .equalSpacing
             $0.spacing = 8
         }
         
         self.navigationBar.titleView = titleContainer
         self.navigationBar.titlePosition = .left
         
         self.navigationBar.isHideBackButton = true
         self.navigationBar.setRightButtons([self.rightHomeButton])
     }
     
     override func setupConstraints() {
         super.setupConstraints()
         
         self.view.addSubview(self.collectionView)
         self.collectionView.snp.makeConstraints {
             $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
             $0.bottom.equalToSuperview().offset(-22)
             $0.leading.trailing.equalToSuperview()
         }
     }
     
     
     // MARK: - Bind
     
     func bind(reactor: DetailViewReactor) {
         /// Navigation pop
         self.rightHomeButton.rx.tap
             .subscribe(with: self) { object, _ in
                 object.navigationPop()
             }
             .disposed(by: self.disposeBag)
         
         /// Action
         self.rx.viewDidLoad
             .map { _ in Reactor.Action.refresh }
             .bind(to: reactor.action)
             .disposed(by: self.disposeBag)
         
         /// State
         reactor.state.map(\.detailCard)
             .distinctUntilChanged()
             .subscribe(with: self) { object, detailCard in
                 object.detailCard = detailCard
                 object.collectionView.reloadData()
             }
             .disposed(by: self.disposeBag)
     }
 }

extension DetailViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: DetailViewCell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            as! DetailViewCell
        
        let model: SOMCardModel = .init(data: self.detailCard)
        cell.setData(model, tags: self.tags)
        
        cell.rightTopSettingButton.rx.tap
            .subscribe(with: self.moreButtonBottomSheetViewController) { bottomSheet, _ in
                var wrapper: SwiftEntryKitViewControllerWrapper = bottomSheet.sek
                wrapper.entryName = Text.moreBottomSheetEntryName
                wrapper.showBottomNote(
                    screenColor: .som.black.withAlphaComponent(0.7),
                    screenInteraction: .dismiss,
                    isHandleBar: true
                )
            }
            .disposed(by: self.disposeBag)
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            
            let footer: DetailViewFooter = collectionView
                .dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "footer",
                    for: indexPath
                ) as! DetailViewFooter
            
            footer.setData(self.commentCards, like: 10, comment: 10)
            return footer
        } else {
            return .init(frame: .zero)
        }
    }
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width: CGFloat = UIScreen.main.bounds.width
        let tagHeight: CGFloat = self.tags.isEmpty ? 40 : 59
        let height: CGFloat = (width - 20 * 2) + tagHeight /// 카드 높이 + 태그 높이
        return CGSize(width: width, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        let width: CGFloat = UIScreen.main.bounds.width
        let tagHeight: CGFloat = self.tags.isEmpty ? 40 : 59
        let cellHeight: CGFloat = (width - 20 * 2) + tagHeight
        let height: CGFloat = collectionView.bounds.height - cellHeight
        return CGSize(width: width, height: height)
    }
}
