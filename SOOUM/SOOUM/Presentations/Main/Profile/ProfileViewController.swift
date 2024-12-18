//
//  ProfileViewController.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/24.
//


import UIKit

import SnapKit
import Then

import ReactorKit
import RxCocoa
import RxSwift


class ProfileViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let blockButtonTitle: String = "차단하기"
        
        static let blockDialogTitle: String = "정말 차단하시겠어요?"
        static let blockDialogSubTitle: String = "해당 사용자의 카드와 댓글을 볼 수 없어요"
    }
    
    
    // MARK: Navi Views
    
    private let titleView = UILabel().then {
        $0.textColor = .som.gray800
        $0.typography = .som.body1WithBold
    }
    
    private let subTitleView = UILabel().then {
        $0.textColor = .som.gray400
        $0.typography = .som.body3WithRegular
    }
    
    private let rightBlockButton = SOMButton().then {
        $0.title = Text.blockButtonTitle
        $0.typography = .som.body3WithBold
        $0.foregroundColor = .som.gray500
    }
    
    private let rightSettingButton = SOMButton().then {
        $0.image = .init(.icon(.outlined(.hamburger)))
        $0.foregroundColor = .som.black
    }
    
    
    // MARK: Views
    
    private let flowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
    }
    private lazy var collectionView = UICollectionView(
       frame: .zero,
       collectionViewLayout: self.flowLayout
    ).then {
        $0.backgroundColor = .som.white
        
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        
        $0.refreshControl = SOMRefreshControl()
        
        $0.register(MyProfileViewCell.self, forCellWithReuseIdentifier: MyProfileViewCell.cellIdentifier)
        $0.register(OtherProfileViewCell.self, forCellWithReuseIdentifier: OtherProfileViewCell.cellIdentifier)
        $0.register(
           ProfileViewFooter.self,
           forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
           withReuseIdentifier: "footer"
        )
        
        $0.dataSource = self
        $0.delegate = self
    }
    
    
    // MARK: Variables
    
    private(set) var profile = Profile()
    private(set) var writtenCards = [WrittenCard]()
    
    override var navigationBarHeight: CGFloat {
         68
    }
    
    private var isRefreshEnabled: Bool = true
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        let isMine = self.reactor?.entranceType == .my
        
        let titleContainer = UIView()
        titleContainer.addSubview(self.titleView)
        self.titleView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        titleContainer.addSubview(self.subTitleView)
        self.subTitleView.snp.makeConstraints {
            $0.top.equalTo(self.titleView.snp.bottom).offset(2)
            $0.bottom.leading.trailing.equalToSuperview()
        }
        
        self.navigationBar.hidesBackButton = isMine
        self.navigationBar.titleView = titleContainer
        if isMine {
            self.navigationBar.setRightButtons([self.rightSettingButton])
        } else {
            self.navigationBar.setRightButtons([self.rightBlockButton])
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    override func bind() {
        super.bind()
        
        // 탭바 표시
        self.rx.viewWillAppear
            .subscribe(with: self) { object, _ in
                object.hidesBottomBarWhenPushed = self.reactor?.entranceType == .my ? false : true
            }
            .disposed(by: self.disposeBag)
        
        self.rightSettingButton.rx.tap
            .subscribe(with: self) { object, _ in
                let settingsViewController = SettingsViewController()
                settingsViewController.reactor = self.reactor?.reactorForSettings()
                object.navigationPush(settingsViewController, animated: true, bottomBarHidden: true)
            }
            .disposed(by: self.disposeBag)
        
        self.rightBlockButton.rx.tap
            .subscribe(with: self) { object, _ in
                SOMDialogViewController.show(
                    title: Text.blockDialogTitle,
                    subTitle: Text.blockDialogSubTitle,
                    leftAction: .init(
                        mode: .cancel,
                        handler: { UIApplication.topViewController?.dismiss(animated: true) }
                    ),
                    rightAction: .init(
                        mode: .ok,
                        handler: { object.reactor?.action.onNext(.block) }
                    )
                )
            }
            .disposed(by: self.disposeBag)
    }
    
    
    // MARK: Bind
    
    func bind(reactor: ProfileViewReactor) {
        
        // Action
        self.rx.viewWillAppear
            .map { _ in Reactor.Action.landing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.collectionView.refreshControl?.rx.controlEvent(.valueChanged)
            .withLatestFrom(reactor.state.map(\.isLoading))
            .filter { $0 == false }
            .map { _ in Reactor.Action.refresh }
            .bind(to: reactor.action)
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
        
        reactor.state.map(\.isProcessing)
            .distinctUntilChanged()
            .bind(to: self.activityIndicatorView.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.profile)
            .distinctUntilChanged()
            .subscribe(with: self) { object, profile in
                object.profile = profile
                object.titleView.text = profile.nickname
                object.subTitleView.text = "TOTAL \(profile.totalVisitorCnt) TODAY \(profile.currentDayVisitors)"
                object.collectionView.reloadData()
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.writtenCards)
            .distinctUntilChanged()
            .subscribe(with: self) { object, writtenCards in
                object.writtenCards = writtenCards
                object.collectionView.reloadData()
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isBlocked)
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(with: self) { object, _ in
                object.dismiss(animated: true)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isFollow)
            .distinctUntilChanged()
            .filter { $0 != nil }
            .subscribe(onNext: { _ in
                reactor.action.onNext(.landing)
            })
            .disposed(by: self.disposeBag)
    }
}

extension ProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let entranceType = self.reactor?.entranceType ?? .my
        switch entranceType {
        case .my:
            let myCell: MyProfileViewCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MyProfileViewCell.cellIdentifier,
                for: indexPath
            ) as! MyProfileViewCell
            myCell.setModel(self.profile)
            
            myCell.updateProfileButton.rx.tap
                .subscribe(with: self) { object, _ in
                    let updateProfileViewController = UpdateProfileViewController()
                    updateProfileViewController.reactor = self.reactor?.reactorForUpdate()
                    object.navigationPush(updateProfileViewController, animated: true, bottomBarHidden: true)
                }
                .disposed(by: myCell.disposeBag)
            
            myCell.followingButton.rx.tap
                .subscribe(with: self) { object, _ in
                    let followViewController = FollowViewController()
                    followViewController.reactor = self.reactor?.reactorForFollow(type: .following)
                    object.navigationPush(followViewController, animated: true, bottomBarHidden: true)
                }
                .disposed(by: myCell.disposeBag)
            
            myCell.followerButton.rx.tap
                .subscribe(with: self) { object, _ in
                    let followViewController = FollowViewController()
                    followViewController.reactor = self.reactor?.reactorForFollow(type: .follower)
                    object.navigationPush(followViewController, animated: true, bottomBarHidden: true)
                }
                .disposed(by: myCell.disposeBag)
            
            return myCell
        case .other:
            let otherCell: OtherProfileViewCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: OtherProfileViewCell.cellIdentifier,
                for: indexPath
            ) as! OtherProfileViewCell
            otherCell.setModel(self.profile)
            
            otherCell.followButton.rx.throttleTap(.seconds(1))
                .subscribe(with: self) { object, _ in
                    object.reactor?.action.onNext(.follow)
                }
                .disposed(by: otherCell.disposeBag)
            
            otherCell.followingButton.rx.tap
                .subscribe(with: self) { object, _ in
                    let followViewController = FollowViewController()
                    followViewController.reactor = self.reactor?.reactorForFollow(type: .following)
                    object.navigationPush(followViewController, animated: true, bottomBarHidden: true)
                }
                .disposed(by: otherCell.disposeBag)
            
            otherCell.followerButton.rx.tap
                .subscribe(with: self) { object, _ in
                    let followViewController = FollowViewController()
                    followViewController.reactor = self.reactor?.reactorForFollow(type: .follower)
                    object.navigationPush(followViewController, animated: true, bottomBarHidden: true)
                }
                .disposed(by: otherCell.disposeBag)
            
            return otherCell
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionFooter {
            
            let footer: ProfileViewFooter = collectionView
                .dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "footer",
                    for: indexPath
                ) as! ProfileViewFooter
            footer.setModel(self.writtenCards)
            
            footer.didTap
                .subscribe(with: self) { object, selectedId in
                    let detailViewController = DetailViewController()
                    detailViewController.reactor = object.reactor?.ractorForDetail(selectedId)
                    object.navigationPush(detailViewController, animated: true, bottomBarHidden: true)
                }
                .disposed(by: footer.disposeBag)
            
            return footer
        } else {
            return .init(frame: .zero)
        }
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
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
           offset <= -refreshControl.bounds.height {
            
            refreshControl.beginRefreshingFromTop()
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width: CGFloat = UIScreen.main.bounds.width
        // 내 프로필 일 때, 프로필 - 컨텐츠 + 컨텐츠 - 버튼 + 버튼 - 하단
        // 상대 프로필 일 때, 프로필 - 버튼 + 버튼 - 하단
        let isMine = self.reactor?.entranceType == .my
        let spacing: CGFloat = isMine ? (16 + 18 + 30) : (22 + 22)
        // 내 프로필 일 떄, 프로필 + 간격 + 컨텐츠 + 버튼
        // 상대 프로필 일 때, 프로필 + 간격 + 버튼
        let height: CGFloat = isMine ? (128 + spacing + 42 + 48) : (128 + spacing + 48)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        let width: CGFloat = UIScreen.main.bounds.width
        // 내 프로필 일 때, 프로필 - 컨텐츠 + 컨텐츠 - 버튼 + 버튼 - 하단
        // 상대 프로필 일 때, 프로필 - 버튼 + 버튼 - 하단
        let isMine = self.reactor?.entranceType == .my
        let spacing: CGFloat = isMine ? (16 + 18 + 30) : (22 + 22)
        // 내 프로필 일 떄, 프로필 + 간격 + 컨텐츠 + 버튼
        // 상대 프로필 일 때, 프로필 + 간격 + 버튼
        let cellHeight: CGFloat = isMine ? (128 + spacing + 42 + 48) : (128 + spacing + 48)
        let height: CGFloat = collectionView.bounds.height - cellHeight
        return CGSize(width: width, height: height)
    }
}
