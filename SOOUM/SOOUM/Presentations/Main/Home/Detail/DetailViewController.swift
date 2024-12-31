//
//  DetailViewController.swift
//  SOOUM
//
//  Created by 오현식 on 10/1/24.
//

import UIKit

import SnapKit
import Then

import ReactorKit
import RxCocoa
import RxSwift


class DetailViewController: BaseNavigationViewController, View {

     enum Text {
         static let moreBottomSheetEntryName: String = "moreButtonBottomSheetViewController"
         
         static let deleteDialogTitle: String = "카드를 삭제할까요?"
         static let deleteDialogSubTitle: String = "삭제한 카드는 복구할 수 없어요"
         
         static let blockDialogTitle: String = "해당 사용자를 차단할까요?"
         static let blockDialogSubTitle: String = "해당 사용자의 모든 카드를 모두 볼 수 없어요"
     }
     
     let rightHomeButton = SOMButton().then {
         $0.image = .init(.icon(.outlined(.home)))
         $0.foregroundColor = .som.black
     }
     
     private let flowLayout = UICollectionViewFlowLayout().then {
         $0.scrollDirection = .vertical
     }
     
     lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: self.flowLayout
     ).then {
         $0.backgroundColor = .som.white
         
         $0.alwaysBounceVertical = true
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
     
     var isDeleted = false
     var isRefreshEnabled = false
     
     
     // MARK: - Life Cycles
     
     override func setupNaviBar() {
         super.setupNaviBar()
         
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
     
     override func bind() {
         super.bind()
         
         // Navigation pop to root
         self.rightHomeButton.rx.tap
             .subscribe(with: self) { object, _ in
                 object.navigationPop(to: MainHomeTabBarController.self, animated: false)
             }
             .disposed(by: self.disposeBag)
         
         /// 신고하기 화면으로 전환
         self.moreButtonBottomSheetViewController.reportLabelButton.rx.tap
             .subscribe(with: self) { object, _ in
                 if let reactor = object.reactor {
                     
                     object.dismissBottomSheet()
                     let viewController = ReportViewController()
                     viewController.reactor = reactor.reactorForReport()
                     object.navigationPush(viewController, animated: true, bottomBarHidden: true)
                 }
             }
             .disposed(by: self.disposeBag)
     }
     
     
     // MARK: - Bind
     
     func bind(reactor: DetailViewReactor) {
         
         // Action
         let viewWillAppear = self.rx.viewWillAppear.share()
         viewWillAppear
             .map { _ in Reactor.Action.landing }
             .bind(to: reactor.action)
             .disposed(by: self.disposeBag)
         
         // 탭바 숨김
         viewWillAppear
             .subscribe(with: self) { object, _ in
                 object.hidesBottomBarWhenPushed = true
             }
             .disposed(by: self.disposeBag)
         
         self.collectionView.refreshControl?.rx.controlEvent(.valueChanged)
             .withLatestFrom(reactor.state.map(\.isLoading))
             .filter { $0 == false }
             .map { _ in Reactor.Action.refresh }
             .bind(to: reactor.action)
             .disposed(by: self.disposeBag)
         
         // 차단하기
         self.moreButtonBottomSheetViewController.blockLabelButton.rx.tap
             .subscribe(with: self) { object, _ in
                 
                 SOMDialogViewController.show(
                    title: Text.blockDialogTitle,
                    subTitle: Text.blockDialogSubTitle,
                    leftAction: .init(
                        mode: .cancel,
                        handler: { UIApplication.topViewController?.dismiss(animated: true) }
                    ),
                    rightAction: .init(
                        mode: .block,
                        handler: {
                            UIApplication.topViewController?.dismiss(animated: true) {
                                reactor.action.onNext(.block)
                                object.dismissBottomSheet()
                            }
                        }
                    )
                 )
             }
             .disposed(by: self.disposeBag)
         
         // State
         reactor.state.map(\.isLoading)
             .distinctUntilChanged()
             .subscribe(with: self.collectionView) { collectionView, isLoading in
                 if isLoading {
                     collectionView.refreshControl?.beginRefreshingFromTop()
                 } else {
                     collectionView.refreshControl?.endRefreshing()
                 }
             }
             .disposed(by: self.disposeBag)
         
         let isProcessing = reactor.state.map(\.isProcessing).distinctUntilChanged().share()
         isProcessing
             .bind(to: self.collectionView.rx.isHidden)
             .disposed(by: self.disposeBag)
         isProcessing
             .bind(to: self.activityIndicatorView.rx.isAnimating)
             .disposed(by: self.disposeBag)
         
         Observable.combineLatest(
            reactor.state.map(\.detailCard).distinctUntilChanged(),
            reactor.state.map(\.prevCard).distinctUntilChanged()
         )
         .subscribe(with: self) { object, pair in
             object.detailCard = pair.0
             object.prevCard = pair.1
             
             UIView.performWithoutAnimation {
                 object.collectionView.reloadData()
             }
         }
         .disposed(by: self.disposeBag)
         
         reactor.state.map(\.commentCards)
             .distinctUntilChanged()
             .subscribe(with: self) { object, commentCards in
                 object.commentCards = commentCards
                 
                 UIView.performWithoutAnimation {
                     object.collectionView.reloadData()
                 }
             }
             .disposed(by: disposeBag)
         
         reactor.state.map(\.cardSummary)
             .distinctUntilChanged()
             .subscribe(with: self) { object, cardSummary in
                 object.cardSummary = cardSummary
                 
                 UIView.performWithoutAnimation {
                     object.collectionView.reloadData()
                 }
             }
             .disposed(by: disposeBag)
         
         reactor.state.map(\.isDeleted)
             .distinctUntilChanged()
             .subscribe(with: self) { object, isDeleted in
                 UIApplication.topViewController?.dismiss(animated: true) {
                     object.isDeleted = isDeleted
                     
                     UIView.performWithoutAnimation {
                         object.collectionView.reloadData()
                     }
                     
                     object.navigationPop()
                 }
             }
             .disposed(by: self.disposeBag)
         
         reactor.state.map(\.isBlocked)
             .distinctUntilChanged()
             .subscribe(with: self) { object, _ in
                 object.navigationPop()
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
    
        guard self.isDeleted == false else {
            cell.isDeleted()
            return cell
        }
        
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
        let model: SOMCardModel = .init(data: card)
        
        let tags: [SOMTagModel] = self.detailCard.tags.map {
            SOMTagModel(id: $0.id, originalText: $0.content, isSelectable: true, isRemovable: false)
        }
        cell.setDatas(model, tags: tags)
        cell.tags.delegate = self
        cell.isOwnCard = self.detailCard.isOwnCard
        cell.prevCard = self.prevCard
        cell.member = self.detailCard.member
        
        cell.prevCardBackgroundButton.rx.tap
            .subscribe(with: self) { object, _ in
                /// 현재 쌓인 viewControllers 중 바로 이전 viewController가 전환해야 할 전글이라면 naviPop, 아니면 naviPush
                if let naviStackCount = object.navigationController?.viewControllers.count,
                   let prevViewController = object.navigationController?.viewControllers[naviStackCount - 2] as? DetailViewController,
                   prevViewController.reactor?.selectedCardId == object.prevCard.previousCardId {
                    
                    object.navigationPop()
                } else {
                    
                    let detailViewController = DetailViewController()
                    detailViewController.reactor = object.reactor?.reactorForPush(object.prevCard.previousCardId)
                    object.navigationPush(detailViewController, animated: true, bottomBarHidden: true)
                }
            }
            .disposed(by: cell.disposeBag)
        
        cell.rightTopSettingButton.rx.tap
            .subscribe(with: self) { object, _ in
                
                if object.detailCard.isOwnCard {
                    /// 자신의 카드일 때 카드 삭제하기
                    SOMDialogViewController.show(
                        title: Text.deleteDialogTitle,
                        subTitle: Text.deleteDialogSubTitle,
                        leftAction: .init(
                            mode: .cancel,
                            handler: { UIApplication.topViewController?.dismiss(animated: true) }
                        ),
                        rightAction: .init(
                            mode: .delete,
                            handler: { object.reactor?.action.onNext(.delete) }
                        )
                    )
                } else {
                    /// 자신의 카드가 아닐 때 차단/신고하기
                    object.showBottomSheet(
                        presented: object.moreButtonBottomSheetViewController,
                        dismissWhenScreenDidTap: true,
                        isHandleBar: true,
                        neverDismiss: false,
                        initalHeight: 178
                    )
                }
            }
            .disposed(by: cell.disposeBag)
        
        cell.memberBackgroundButton.rx.tap
            .subscribe(with: self) { object, _ in
                if object.detailCard.isOwnCard {
                    
                    let memberId = object.detailCard.member.id
                    let profileViewController = ProfileViewController()
                    profileViewController.reactor = object.reactor?.reactorForProfile(type: .myWithNavi, memberId)
                    object.navigationPush(profileViewController, animated: true, bottomBarHidden: true)
                } else {
                    
                    let memberId = object.detailCard.member.id
                    let profileViewController = ProfileViewController()
                    profileViewController.reactor = object.reactor?.reactorForProfile(type: .other, memberId)
                    object.navigationPush(profileViewController, animated: true, bottomBarHidden: true)
                }
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
            
            guard let reactor = self.reactor else { return footer }
            
            footer.didTap
                .subscribe(with: self) { object, selectedId in
                    let viewController = DetailViewController()
                    viewController.reactor = reactor.reactorForPush(selectedId)
                    object.navigationPush(viewController, animated: true, bottomBarHidden: true)
                }
                .disposed(by: footer.disposeBag)
            
            footer.likeAndCommentView.likeBackgroundButton.rx.throttleTap(.seconds(1))
                .withLatestFrom(reactor.state.map(\.cardSummary.isLiked))
                .subscribe(onNext: { isLike in
                    reactor.action.onNext(.updateLike(!isLike))
                })
                .disposed(by: footer.disposeBag)
            
            footer.likeAndCommentView.commentBackgroundButton.rx.tap
                .subscribe(with: self) { object, _ in
                    let writeCardViewController = WriteCardViewController()
                    writeCardViewController.setupNaviBar()
                    writeCardViewController.reactor = reactor.reactorForWriteCard()
                    object.navigationPush(writeCardViewController, animated: true, bottomBarHidden: true)
                }
                .disposed(by: footer.disposeBag)
            
            return footer
        } else {
            return .init(frame: .zero)
        }
    }
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        // currentOffset <= 0 일 때, 테이블 뷰 새로고침 가능
        let offset = scrollView.contentOffset.y
        self.isRefreshEnabled = offset <= 0
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let offset = scrollView.contentOffset.y
        
        // isRefreshEnabled == true 이고, 스크롤이 끝났을 경우에만 테이블 뷰 새로고침
        if self.isRefreshEnabled,
           let refreshControl = self.collectionView.refreshControl,
           offset <= -(refreshControl.frame.origin.y + 40) {
            
            refreshControl.beginRefreshingFromTop()
        }
    }
    
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

extension DetailViewController: SOMTagsDelegate {
  func tags(_ tags: SOMTags, didTouch model: SOMTagModel) {
    print("\(type(of: self)) - \(#function)")

    let tagDetailVC = TagDetailViewController()
    let tagDetailReactor = TagDetailViewrReactor(tagID: model.id)
    tagDetailVC.reactor = tagDetailReactor
    self.navigationPush(tagDetailVC, animated: true)
  }
}
