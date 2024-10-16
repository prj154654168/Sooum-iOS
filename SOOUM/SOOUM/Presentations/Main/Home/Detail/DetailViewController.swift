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
         $0.showsVerticalScrollIndicator = false
         $0.showsHorizontalScrollIndicator = false
         $0.refreshControl = SOMRefreshControl()
         
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
     
     var detailCard = DetailCard()
     var prevCard = PrevCard()
     
     var commentCards = [Card]()
     var cardSummary = CardSummary()
     
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
         /// Navigation pop to root
         self.rightHomeButton.rx.tap
             .subscribe(with: self) { object, _ in
                 object.navigationPop(to: MainHomeViewController.self, animated: false)
             }
             .disposed(by: self.disposeBag)
         
         /// Action
         self.rx.viewWillAppear
             .map { _ in Reactor.Action.refresh }
             .bind(to: reactor.action)
             .disposed(by: self.disposeBag)
         
         self.collectionView.refreshControl?.rx.controlEvent(.valueChanged)
             .withLatestFrom(reactor.state.map(\.isLoading))
             .filter { $0 == false }
             .map { _ in Reactor.Action.refresh }
             .bind(to: reactor.action)
             .disposed(by: self.disposeBag)
         
         /// State
         reactor.state.map(\.isLoading)
             .distinctUntilChanged()
             .subscribe(with: self.collectionView) { collectionView, isLoading in
                 if isLoading {
                     collectionView.refreshControl?.manualyBeginRefreshing()
                 } else {
                     collectionView.refreshControl?.endRefreshing()
                 }
             }
             .disposed(by: self.disposeBag)
         
         Observable.combineLatest(
            reactor.state.map(\.detailCard).distinctUntilChanged(),
            reactor.state.map(\.prevCard).distinctUntilChanged()
         )
         .subscribe(with: self) { object, pair in
             object.detailCard = pair.0
             object.prevCard = pair.1
             object.titleLabel.text = pair.0.member.nickname
             object.titleImageView.setImage(strUrl: pair.0.member.profileImgUrl ?? "")
             object.collectionView.reloadData()
         }
         .disposed(by: self.disposeBag)
         
         reactor.state.map(\.commentCards)
             .distinctUntilChanged()
             .subscribe(with: self) { object, commentCards in
                 object.commentCards = commentCards
                 object.collectionView.reloadData()
             }
             .disposed(by: disposeBag)

         reactor.state.map(\.cardSummary)
             .distinctUntilChanged()
             .subscribe(with: self) { object, cardSummary in
                 object.cardSummary = cardSummary
                 object.collectionView.reloadData()
             }
             .disposed(by: disposeBag)
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
        
        let card = Card(
            id: self.detailCard.id,
            content: self.detailCard.content,
            distance: self.detailCard.distance,
            createdAt: self.detailCard.createdAt,
            storyExpirationTime: self.detailCard.storyExpirationTime,
            likeCnt: self.detailCard.likeCnt,
            commentCnt: self.detailCard.commentCnt,
            backgroundImgURL: self.detailCard.backgroundImgURL,
            links: .init(),
            font: self.detailCard.font,
            fontSize: self.detailCard.fontSize,
            isLiked: self.detailCard.isLiked,
            isCommentWritten: self.detailCard.isCommentWritten
        )
        let model: SOMCardModel = .init(data: card, type: .detail)
        
        let tags: [SOMTagModel] = self.detailCard.tags.map {
            SOMTagModel(id: $0.id, originalText: $0.content)
        }
        cell.setDatas(model, tags: tags)
        
        cell.isOwnCard = self.detailCard.isOwnCard
        cell.prevCard = self.prevCard
        
        cell.prevCardBackgroundButton.rx.tap
            .subscribe(with: self) { object, _ in
                let willInsertViewController = DetailViewController()
                willInsertViewController.reactor = object.reactor?.reactorForPop()
                guard var viewControllers = object.navigationController?.viewControllers else { return }
                viewControllers.insert(willInsertViewController, at: 1)
                object.navigationController?.setViewControllers(viewControllers, animated: false)
                if let destination = viewControllers.first(where: { $0 == willInsertViewController }) {
                    object.navigationController?.popToViewController(destination, animated: true)
                } else {
                    object.navigationPop()
                }
            }
            .disposed(by: cell.disposeBag)
        
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
            .disposed(by: cell.disposeBag)
        
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
            
            footer.setDatas(self.commentCards, cardSummary: self.cardSummary)
            
            footer.didTap
                .subscribe(with: self) { object, _ in
                    let willRemoveViewController = object.navigationController?.viewControllers.last as? DetailViewController
                    let selectedId = footer.commentCards[indexPath.row].id
                    let viewController = DetailViewController()
                    viewController.reactor = object.reactor?.reactorForPush(selectedId)
                    object.navigationPush(viewController, animated: true) { _ in
                        object.navigationController?.viewControllers.removeAll(where: { $0 == willRemoveViewController })
                    }
                }
                .disposed(by: footer.disposeBag)
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
        let tagHeight: CGFloat = self.detailCard.tags.isEmpty ? 40 : 59
        let height: CGFloat = (width - 20 * 2) + tagHeight /// 카드 높이 + 태그 높이
        return CGSize(width: width, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        let width: CGFloat = UIScreen.main.bounds.width
        let tagHeight: CGFloat = self.detailCard.tags.isEmpty ? 40 : 59
        let cellHeight: CGFloat = (width - 20 * 2) + tagHeight
        let height: CGFloat = collectionView.bounds.height - cellHeight
        return CGSize(width: width, height: height)
    }
}
