//
//  MakeVoteView.swift
//  SOOUM
//
//  Created by 오현식 on 6/14/26.
//

import UIKit

import SnapKit
import Then

protocol MakeVoteViewDelegate: AnyObject {
    
    func makeVoteViewDidTapClose(_ makeVoteView: MakeVoteView)
    func makeVoteView(_ makeVoteView: MakeVoteView, didTapComplete votes: [String])
}

final class MakeVoteView: UIView {
    
    enum Text {
        static let entryName: String = "MakeVoteEntry"
        static let navigationTitle: String = "투표 만들기"
        static let navigationCompleteButtonTitle: String = "완료"
        
        static let makeVoteTextFieldPlaceholderText: String = "항목 입력"
        
        static let addVoteButtonTitle: String = "항목 추가"
    }
    
    enum Constants {
        static let minimumVoteCount: Int = 2
        static let maximumVoteCount: Int = 4
        static let rowHeight: CGFloat = 48
    }
    
    
    // MARK: Views
    
    private lazy var closeButton = SOMButton().then {
        $0.image = .init(.icon(.v2(.outlined(.delete_full))))
        $0.foregroundColor = .som.v2.black
        
        $0.addTarget(
            self,
            action: #selector(self.closeButtonDidTapped(_:)),
            for: .touchUpInside
        )
    }
    
    private let titleLabel = UILabel().then {
        $0.text = Text.navigationTitle
        $0.textColor = .som.v2.black
        $0.typography = .som.v2.title1
    }
    
    private lazy var completeButton = SOMButton().then {
        $0.title = Text.navigationCompleteButtonTitle
        $0.typography = .som.v2.subtitle1
        $0.foregroundColor = .som.v2.black
        
        $0.isEnabled = false
        
        $0.addTarget(
            self,
            action: #selector(self.completeButtonDidTapped(_:)),
            for: .touchUpInside
        )
    }
    
    private let container = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 8
    }
    
    private lazy var addVoteButton = SOMButton().then {
        $0.image = .init(.icon(.v2(.outlined(.plus))))
        
        $0.title = Text.addVoteButtonTitle
        $0.typography = .som.v2.subtitle1
        $0.foregroundColor = .som.v2.gray600
        $0.backgroundColor = .som.v2.white
        $0.inset = .init(top: 12, left: 16, bottom: 12, right: 16)
        
        $0.contentHorizontalAlignment = .center
        
        $0.isDashedBorderEnabled = true
        
        $0.addTarget(self, action: #selector(self.addVoteButtonDidTapped(_:)), for: .touchUpInside)
    }
    
    
    // MARK: Variables
    
    weak var delegate: MakeVoteViewDelegate?
    
    var makedVotes: [String] {
        get {
            return self.voteOptions
        }
        set {
            let prefixVotes = Array(newValue.prefix(Constants.maximumVoteCount))
            let normalizedVotes = prefixVotes.isEmpty
            ? Array(repeating: "", count: Constants.minimumVoteCount)
            : prefixVotes
            
            self.voteOptions = normalizedVotes.count >= Constants.minimumVoteCount
            ? normalizedVotes
            : normalizedVotes + Array(
                repeating: "",
                count: Constants.minimumVoteCount - normalizedVotes.count
            )
            
            self.renderVoteRows()
        }
    }
    
    private var voteOptions: [String] = Array(
        repeating: "",
        count: Constants.minimumVoteCount
    )
    
    
    // MARK: Initialize
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setupConstraints()
        self.renderVoteRows()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Private func
    
    private func setupConstraints() {
        self.backgroundColor = .som.v2.white
        
        self.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(UIScreen.main.bounds.height)
        }
        
        self.addSubview(self.closeButton)
        self.closeButton.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(24)
        }
        
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.closeButton.snp.centerY)
            $0.centerX.equalToSuperview()
        }
        
        self.addSubview(self.completeButton)
        self.completeButton.snp.makeConstraints {
            $0.centerY.equalTo(self.closeButton.snp.centerY)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        self.addSubview(self.container)
        self.container.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(26.5)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        self.addSubview(self.addVoteButton)
        self.addVoteButton.snp.makeConstraints {
            $0.top.equalTo(self.container.snp.bottom).offset(10)
            $0.bottom.lessThanOrEqualTo(self.safeAreaLayoutGuide.snp.bottom).offset(-16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(48)
        }
    }
    
    private func renderVoteRows() {
        self.container.arrangedSubviews.forEach {
            self.container.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        self.voteOptions.enumerated().forEach { index, vote in
            let voteRowView = VoteOptionRowView(
                text: vote,
                placeholder: Text.makeVoteTextFieldPlaceholderText,
                showsRemoveButton: index >= Constants.minimumVoteCount
            )
            
            voteRowView.onTextChanged = { [weak self] text in
                self?.updateVoteOption(text, at: index)
            }
            
            voteRowView.onRemoveTapped = { [weak self] in
                self?.removeVoteOption(at: index)
            }
            
            self.container.addArrangedSubview(voteRowView)
            voteRowView.snp.makeConstraints {
                $0.height.equalTo(Constants.rowHeight)
            }
        }
        
        self.updateAddVoteButtonVisibility()
        self.updateCompleteButtonState()
    }
    
    private func updateVoteOption(_ text: String, at index: Int) {
        guard self.voteOptions.indices.contains(index) else { return }
        self.voteOptions[index] = text.trimmingCharacters(in: .whitespacesAndNewlines)
        self.updateCompleteButtonState()
    }
    
    private func addVoteOption() {
        guard self.voteOptions.count < Constants.maximumVoteCount else { return }
        self.voteOptions.append("")
        self.renderVoteRows()
    }
    
    private func removeVoteOption(at index: Int) {
        guard index >= Constants.minimumVoteCount else { return }
        guard self.voteOptions.indices.contains(index) else { return }
        self.voteOptions.remove(at: index)
        self.renderVoteRows()
    }
    
    private func updateAddVoteButtonVisibility() {
        self.addVoteButton.isHidden = self.voteOptions.count >= Constants.maximumVoteCount
    }
    
    private func uniqueValidVotes() -> [String] {
        var seenVotes = Set<String>()
        
        return self.voteOptions
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .filter { seenVotes.insert($0).inserted }
    }
    
    private func updateCompleteButtonState() {
        let validVotes = self.uniqueValidVotes()
        self.completeButton.isEnabled = validVotes.count >= Constants.minimumVoteCount
    }
    
    
    // MARK: Objc func
    
    @objc
    private func addVoteButtonDidTapped(_ button: UIButton) {
        self.addVoteOption()
    }
    
    @objc
    private func closeButtonDidTapped(_ button: UIButton) {
        self.delegate?.makeVoteViewDidTapClose(self)
    }
    
    @objc
    private func completeButtonDidTapped(_ button: UIButton) {
        let validVotes = self.uniqueValidVotes()
        
        guard validVotes.count >= Constants.minimumVoteCount else { return }
        self.delegate?.makeVoteView(self, didTapComplete: validVotes)
    }
}
