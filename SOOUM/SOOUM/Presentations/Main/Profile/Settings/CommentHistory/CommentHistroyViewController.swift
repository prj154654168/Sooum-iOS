//
//  CommentHistroyViewController.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import UIKit

import SnapKit
import Then

import ReactorKit
import RxCocoa
import RxSwift


class CommentHistroyViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let navigationTitle: String = "덧글 히스토리"
    }
    
    private let flowLayout = SOMTagsLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = .zero
        $0.minimumInteritemSpacing = .zero
        $0.sectionInset = .zero
    }
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: self.flowLayout
    ).then {
        $0.alwaysBounceVertical = true
        
        $0.contentInsetAdjustmentBehavior = .never
        $0.contentInset = .zero
        
        $0.decelerationRate = .fast
        
        $0.showsHorizontalScrollIndicator = false
        
        $0.register(CommentHistoryViewCell.self, forCellWithReuseIdentifier: CommentHistoryViewCell.cellIdentifier)
        
        $0.dataSource = self
        $0.delegate = self
    }
    
    private(set) var commentHistroies = [CommentHistory]()
    
    private var currentOffset: CGFloat = 0
    private var isLoadingMore: Bool = true
    
    override var navigationBarHeight: CGFloat {
        46
    }
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: CommentHistroyViewReactor) {
        
        // Action
        self.rx.viewDidLoad
            .map { _ in Reactor.Action.landing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map(\.isProcessing)
            .distinctUntilChanged()
            .do(onNext: { [weak self] isProcessing in
                if isProcessing { self?.isLoadingMore = false }
            })
            .bind(to: self.activityIndicatorView.rx.isAnimating)
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.commentHistories)
            .distinctUntilChanged()
            .subscribe(with: self) { object, commentHistories in
                object.commentHistroies = commentHistories
                object.collectionView.reloadData()
            }
            .disposed(by: self.disposeBag)
    }
}

extension CommentHistroyViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.commentHistroies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CommentHistoryViewCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CommentHistoryViewCell.cellIdentifier,
            for: indexPath
        ) as! CommentHistoryViewCell
        let commentHistory = self.commentHistroies[indexPath.row]
        cell.setModel(commentHistory.backgroundImgURL.url, content: commentHistory.content)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedId = self.commentHistroies[indexPath.row].id
        
        let detailViewController = DetailViewController()
        detailViewController.reactor = self.reactor?.reactorForDetail(selectedId)
        self.navigationPush(detailViewController, animated: true, bottomBarHidden: true)
    }
}

extension CommentHistroyViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width: CGFloat = UIScreen.main.bounds.width / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard self.commentHistroies.isEmpty == false else { return }
        
        let lastSectionIndex = collectionView.numberOfSections - 1
        let lastRowIndex = collectionView.numberOfItems(inSection: lastSectionIndex) - 1
        
        if self.isLoadingMore, indexPath.section == lastSectionIndex, indexPath.item == lastRowIndex {
            let lastId = self.commentHistroies[indexPath.item].id
            self.reactor?.action.onNext(.moreFind(lastId))
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        
        // 당겨서 새로고침 상황일 때
        guard offset > 0 else { return }
        
        // 아래로 스크롤 중일 때, 데이터 추가로드 가능
        self.isLoadingMore = offset > self.currentOffset
        self.currentOffset = offset
    }
}
