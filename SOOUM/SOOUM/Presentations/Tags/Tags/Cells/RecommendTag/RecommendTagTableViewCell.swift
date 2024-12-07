//
//  RecommendTagTableViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 11/26/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift

import SnapKit
import Then

class RecommendTagTableViewCell: UITableViewCell {
    
    /// 셀 사용 모드
    enum Mode {
        case recommendTag
        case searchTag
    }
    
    var mode: Mode = .recommendTag
    
    var recommendTag: RecommendTagsResponse.RecommendTag?
    var searchTag: SearchTagsResponse.RelatedTag?
    
    var disposeBag = DisposeBag()
    
    let recommendTagView = RecommendTagView()
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.disposeBag = DisposeBag()
    }
    
    /// 추천 태그 setData
    func setData(recommendTag: RecommendTagsResponse.RecommendTag) {
        self.disposeBag = DisposeBag()
        self.mode = .recommendTag
        
        self.recommendTag = recommendTag
        self.recommendTagView.tagNameLabel.text = recommendTag.tagContent
        self.recommendTagView.tagsCountLabel.text = recommendTag.tagUsageCnt
    }
    
    /// 검색 태그 setData
    func setData(searchRelatedTag: SearchTagsResponse.RelatedTag) {
        self.disposeBag = DisposeBag()
        
        self.mode = .searchTag
        self.searchTag = searchRelatedTag
        self.recommendTagView.tagNameLabel.text = searchRelatedTag.content
        self.recommendTagView.tagsCountLabel.text = "\(searchRelatedTag.count)"
    }
    
    private func setupConstraint() {
        self.contentView.addSubview(recommendTagView)
        recommendTagView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.height.equalTo(57)
        }
    }
}
