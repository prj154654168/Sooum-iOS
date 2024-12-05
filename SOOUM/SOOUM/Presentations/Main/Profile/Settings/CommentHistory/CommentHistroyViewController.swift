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
        
        $0.register(CommentHistoryViewCell.self, forCellWithReuseIdentifier: CommentHistoryViewCell.cellIdentifier)
        
        $0.dataSource = self
        $0.delegate = self
    }
    
    private(set) var commentHistroies = [CommentHistory]()
    
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
}
