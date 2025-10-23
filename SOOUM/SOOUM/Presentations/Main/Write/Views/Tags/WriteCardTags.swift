//
//  WriteCardTags.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/25.
//

import UIKit

import SnapKit
import Then

import RxCocoa

class WriteCardTags: UIView {
    
    enum Text {
        static let tagPlaceholder = "태그 추가"
    }
    
    enum Section: Int {
        case main
    }
    
    enum Item: Hashable {
        case tag(WriteCardTagModel)
        case footer
    }
    
    
    // MARK: Views
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.scrollDirection = .horizontal
            $0.minimumInteritemSpacing = 6
            $0.minimumLineSpacing = 0
        }
    ).then {
        $0.backgroundColor = .clear
        
        $0.alwaysBounceHorizontal = true
        
        $0.contentInsetAdjustmentBehavior = .never
        $0.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        
        $0.register(WriteCardTag.self, forCellWithReuseIdentifier: WriteCardTag.cellIdentifier)
        $0.register(WriteCardTagFooter.self, forCellWithReuseIdentifier: WriteCardTagFooter.cellIdentifier)
        
        $0.delegate = self
    }
    
    
    // MARK: Variables
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private lazy var dataSource = DataSource(collectionView: self.collectionView) { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
        guard let self = self else { return nil }
        
        switch item {
        case let .tag(model):
            
            let cell: WriteCardTag = collectionView.dequeueReusableCell(
                withReuseIdentifier: WriteCardTag.cellIdentifier,
                for: indexPath
            ) as! WriteCardTag
            cell.setModel(model)
            cell.delegate = self
            
            return cell
        case .footer:
            
            let footer: WriteCardTagFooter = collectionView.dequeueReusableCell(
                withReuseIdentifier: WriteCardTagFooter.cellIdentifier,
                for: indexPath
            ) as! WriteCardTagFooter
            footer.placeholder = Text.tagPlaceholder
            footer.typography = self.typography
            footer.delegate = self
            
            footer.addTargetToTextField(self, action: #selector(self.textDidChanged(_:)), for: .editingChanged)
            
            return footer
        }
    }
    
    var updateWrittenTags = BehaviorRelay<[WriteCardTagModel]?>(value: nil)
    
    private(set) var models = [WriteCardTagModel]()
    
    private var footerText: String? = Text.tagPlaceholder
    private var footerWidth: CGFloat {
        guard let text = self.footerText else { return 36 }
        let textWidth: CGFloat = (text as NSString).size(
            withAttributes: [.font: self.typography.font]
        ).width
        
        return max(36, 8 + 14 + 2 + ceil(textWidth) + 8)
    }
    
    var typography: Typography = .som.v2.caption2 {
        didSet {
            let current = self.models
            current.forEach { $0.typography = self.typography }
            self.models = current
            
            let itemsToReconfigure = self.dataSource.snapshot().itemIdentifiers
            var reconfigureSnapshot = self.dataSource.snapshot()
            reconfigureSnapshot.reconfigureItems(itemsToReconfigure)
            self.dataSource.apply(reconfigureSnapshot, animatingDifferences: false) { [weak self] in
                self?.scrollToRight()
            }
        }
    }
    
    
    // MARK: Delegate
    
    weak var delegate: WriteCardTagsDelegate?
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        
        self.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func scrollToRight(animated: Bool = false) {
        
        let contentWidth: CGFloat = self.collectionView.collectionViewLayout.collectionViewContentSize.width
        let boundsWidth: CGFloat = self.collectionView.bounds.width
        guard contentWidth >= (boundsWidth - 16 * 2) else { return }
        let newOffset: CGPoint = CGPoint(
            x: ceil(contentWidth - boundsWidth) + self.collectionView.contentInset.right,
            y: 0
        )
        self.collectionView.setContentOffset(newOffset, animated: animated)
    }
    
    
    // MARK: Public func
    
    func setModels(_ models: [WriteCardTagModel]) {
        
        guard models.isEmpty == false else {
            self.models = []
            var snapshot = Snapshot()
            snapshot.appendSections([.main])
            snapshot.appendItems([.footer], toSection: .main)
            self.dataSource.apply(snapshot, animatingDifferences: false)
            return
        }
        
        let current = self.models
        var new = models
        /// 변경사항이 없다면 종료
        guard current != new else { return }
        
        /// 새로운 태그가 유효한지 확인 (중복 여부 확인)
        if new.count != Set(new).count {
            Log.warning("중복된 태그가 존재합니다. 태그의 순서를 유지하고 중복된 태그를 제거합니다.")
            new = new.removeOlderfromDuplicated()
        }
        
        self.models = new
        
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        
        var items = new.map { Item.tag($0) }
        items.append(Item.footer)
        snapshot.appendItems(items, toSection: .main)
        self.dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            self?.scrollToRight()
        }
    }
    
    func isFooterFirstResponder() -> Bool {
        
        guard let indexPath = self.dataSource.indexPath(for: .footer),
            let footer: WriteCardTagFooter = self.collectionView.cellForItem(
                at: indexPath
            ) as? WriteCardTagFooter
        else { return false }
        
        return footer.isFirstResponder
    }
    
    func footerResignFirstResponder() {
        
        guard let indexPath = self.dataSource.indexPath(for: .footer),
            let footer: WriteCardTagFooter = self.collectionView.cellForItem(
                at: indexPath
            ) as? WriteCardTagFooter
        else { return }
        
        footer.resignFirstResponder()
    }
    
    
    // MARK: Objc func
    
    @objc
    func textDidChanged(_ textField: UITextField) {
        self.footerText = textField.text
        self.collectionView.collectionViewLayout.invalidateLayout()
        
        self.scrollToRight(animated: true)
        self.delegate?.textDidChanged(textField.text)
    }
}


// MARK: UICollectionViewDelegateFlowLayout

extension WriteCardTags: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case .footer:
            let footer = collectionView.dequeueReusableCell(
                withReuseIdentifier: WriteCardTagFooter.cellIdentifier,
                for: indexPath
            ) as! WriteCardTagFooter
            footer.becomeFirstResponder()
        default:
            return
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return .zero }
        
        switch item {
        case let .tag(model):
            
            var size: CGSize {
                let textWidth: CGFloat = (model.originalText as NSString).size(
                    withAttributes: [.font: self.typography.font]
                ).width
                /// leading offset + hash image width + spacing + text width + spacing + remove button width + trailing offset
                let tagWidth: CGFloat = 8 + 14 + 2 + ceil(textWidth) + 2 + 16 + 8
                return CGSize(width: tagWidth, height: 28)
            }
            
            return size
        case .footer:
            
            return CGSize(width: self.footerWidth, height: 28)
        }
    }
}


// MARK: WriteCardTagDelegate

extension WriteCardTags: WriteCardTagDelegate {
    
    func tag(_ tag: WriteCardTag, didRemoveSelect model: WriteCardTagModel) {
        var models = self.models
        models.removeAll(where: { $0 == model })
        self.updateWrittenTags.accept(models)
    }
}


// MARK: WriteCardFooterViewDelegate

extension WriteCardTags: WriteCardTagFooterDelegate {
    
    func textFieldDidBeginEditing(_ textField: WriteCardTagFooter) {
        self.footerText = nil
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.delegate?.textFieldDidBeginEditing(textField)
    }
    
    func textFieldDidEndEditing(_ textField: WriteCardTagFooter) {
        self.footerText = textField.text
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.scrollToRight(animated: true)
    }

    func textFieldReturnKeyClicked(_ textField: WriteCardTagFooter) -> Bool {
        
        guard let text = textField.text, text.isEmpty == false else {
            self.footerResignFirstResponder()
            return false
        }
        
        let addedTag: WriteCardTagModel = .init(originalText: text, typography: self.typography)
        var new = self.models
        new.append(addedTag)
        self.updateWrittenTags.accept(new)
        
        textField.text = nil
        textField.sendActionsToTextField(for: .editingChanged)
        
        return false
    }
}
