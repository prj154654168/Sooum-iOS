//
//  VotedView.swift
//  SOOUM
//
//  Created by 오현식 on 6/30/26.
//

import UIKit

import SnapKit
import Then

final class VotedView: UIView {
    
    private enum Text {
        static let votedCountTraillingText: String = "명 참여"
    }

    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let topInset: CGFloat = 20
        static let bottomInset: CGFloat = 8
        static let rowHeight: CGFloat = 48
        static let rowSpacing: CGFloat = 8
        static let rowCornerRadius: CGFloat = 10
        static let rowHorizontalInset: CGFloat = 16
        static let iconSize: CGFloat = 20
        static let labelSpacing: CGFloat = 8
        static let fillAnimationDuration: TimeInterval = 0.45
    }
    
    var onOptionTap: ((String) -> Void)?

    private final class VoteOptionRowView: UIView {

        private let trackView = UIView().then {
            $0.backgroundColor = .som.v2.gray100
            $0.layer.cornerRadius = Layout.rowCornerRadius
            $0.clipsToBounds = true
        }

        private let selectedBackgroundView = UIView().then {
            $0.backgroundColor = .som.v2.pLight1
            $0.isHidden = true
        }

        private let fillView = UIView().then {
            $0.backgroundColor = .som.v2.gray200
        }

        private let checkImageView = UIImageView().then {
            $0.image = UIImage(.icon(.v2(.outlined(.check))))?.withRenderingMode(.alwaysTemplate)
            $0.tintColor = .som.v2.pMain
            $0.contentMode = .scaleAspectFit
            $0.isHidden = true
        }

        private let titleLabel = UILabel().then {
            $0.textColor = .som.v2.black
            $0.typography = .som.v2.subtitle1.withAlignment(.left)
            $0.numberOfLines = 1
        }

        private let resultLabel = UILabel().then {
            $0.textColor = .som.v2.black
            $0.typography = .som.v2.subtitle1.withAlignment(.right)
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
            $0.isHidden = true
        }

        private let actionButton = UIButton(type: .custom)

        private var selectedBackgroundWidthConstraint: Constraint?
        private var fillWidthConstraint: Constraint?
        private var percentage: Double = 0

        var onTap: (() -> Void)?

        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setupConstraints()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            self.updateFillWidth()
        }

        private func setupConstraints() {
            
            self.addSubview(self.trackView)
            self.trackView.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.height.equalTo(Layout.rowHeight)
            }

            self.trackView.addSubview(self.selectedBackgroundView)
            self.selectedBackgroundView.snp.makeConstraints {
                $0.leading.top.bottom.equalToSuperview()
                self.selectedBackgroundWidthConstraint = $0.width.equalTo(0).constraint
            }

            self.trackView.addSubview(self.fillView)
            self.fillView.snp.makeConstraints {
                $0.leading.top.bottom.equalToSuperview()
                self.fillWidthConstraint = $0.width.equalTo(0).constraint
            }

            let titleStackView = UIStackView(arrangedSubviews: [self.checkImageView, self.titleLabel]).then {
                $0.axis = .horizontal
                $0.alignment = .center
                $0.spacing = Layout.labelSpacing
            }

            self.trackView.addSubview(self.resultLabel)
            self.resultLabel.snp.makeConstraints {
                $0.trailing.equalToSuperview().offset(-Layout.rowHorizontalInset)
                $0.centerY.equalToSuperview()
            }

            self.trackView.addSubview(titleStackView)
            titleStackView.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(Layout.rowHorizontalInset)
                $0.centerY.equalToSuperview()
                $0.trailing.lessThanOrEqualTo(self.resultLabel.snp.leading).offset(-Layout.labelSpacing)
            }

            self.checkImageView.snp.makeConstraints {
                $0.size.equalTo(Layout.iconSize)
            }

            self.trackView.addSubview(self.actionButton)
            self.actionButton.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            self.actionButton.addAction(
                UIAction { [weak self] _ in
                    self?.onTap?()
                },
                for: .touchUpInside
            )
        }

        func configure(option: DetailCardInfo.Poll.Option, isPollVoted: Bool, animated: Bool) {
            self.titleLabel.text = option.content

            if isPollVoted {
                let targetPercentage = min(max(option.votePercentage, 0), 100)
                self.trackView.backgroundColor = .som.v2.gray100
                self.selectedBackgroundView.isHidden = option.isVoted == false
                self.fillView.backgroundColor = option.isVoted ? .som.v2.pLight1 : .som.v2.gray200
                self.titleLabel.typography = option.isVoted ? .som.v2.title2 : .som.v2.subtitle1
                self.resultLabel.typography = option.isVoted ? .som.v2.title2 : .som.v2.subtitle1
                self.resultLabel.text = "\(Int(option.votePercentage.rounded()))% (\(option.voteCnt)명)"
                self.resultLabel.isHidden = false
                self.checkImageView.isHidden = option.isVoted == false

                if animated {
                    self.resultLabel.alpha = 0
                    self.checkImageView.alpha = option.isVoted ? 0 : 1
                    self.percentage = 0
                    self.updateFillWidth()
                    self.layoutIfNeeded()

                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.percentage = targetPercentage
                        self.updateFillWidth()
                        UIView.animate(
                            withDuration: Layout.fillAnimationDuration,
                            delay: 0,
                            options: [.curveEaseOut]
                        ) {
                            self.resultLabel.alpha = 1
                            self.checkImageView.alpha = 1
                            self.layoutIfNeeded()
                        }
                    }
                } else {
                    self.resultLabel.alpha = 1
                    self.checkImageView.alpha = 1
                    self.percentage = targetPercentage
                    self.updateFillWidth()
                }
            } else {
                self.percentage = 0
                self.trackView.backgroundColor = .som.v2.gray100
                self.selectedBackgroundView.isHidden = true
                self.fillView.backgroundColor = .som.v2.gray200
                self.titleLabel.textColor = .som.v2.black
                self.resultLabel.text = nil
                self.resultLabel.isHidden = true
                self.resultLabel.alpha = 1
                self.checkImageView.isHidden = true
                self.checkImageView.alpha = 1
                self.updateFillWidth()
            }

            self.setNeedsLayout()
        }

        private func updateFillWidth() {
            let width = self.trackView.bounds.width * CGFloat(self.percentage / 100)
            self.selectedBackgroundWidthConstraint?.update(offset: width)
            self.fillWidthConstraint?.update(offset: width)
        }
    }


    // MARK: Views

    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = Layout.rowSpacing
    }
    
    private let votedCountLabel = UILabel().then {
        $0.textColor = .som.v2.gray400
        $0.textAlignment = .left
        $0.typography = .som.v2.caption2.withAlignment(.left)
    }


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
        self.addSubview(self.stackView)
        self.stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.topInset)
            $0.horizontalEdges.equalToSuperview().inset(Layout.horizontalInset)
        }
        
        self.addSubview(self.votedCountLabel)
        self.votedCountLabel.snp.makeConstraints {
            $0.top.equalTo(self.stackView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(Layout.horizontalInset)
            $0.bottom.equalToSuperview().offset(-Layout.bottomInset)
            $0.height.equalTo(18)
        }
    }

    private func makeOptionView(
        option: DetailCardInfo.Poll.Option,
        isPollVoted: Bool,
        animated: Bool
    ) -> UIView {
        let optionView = VoteOptionRowView()
        optionView.configure(option: option, isPollVoted: isPollVoted, animated: animated)
        optionView.onTap = { [weak self] in
            self?.onOptionTap?(option.id)
        }
        optionView.snp.makeConstraints {
            $0.height.equalTo(Layout.rowHeight)
        }
        return optionView
    }


    // MARK: Public func

    func setModels(_ poll: DetailCardInfo.Poll?, animatesResult: Bool) {
        self.stackView.arrangedSubviews.forEach {
            self.stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let options = poll?.options ?? []
        let isPollVoted = poll?.isVoted == true
        self.isHidden = options.isEmpty

        options.forEach { option in
            self.stackView.addArrangedSubview(
                self.makeOptionView(
                    option: option,
                    isPollVoted: isPollVoted,
                    animated: animatesResult && isPollVoted
                )
            )
        }
        
        self.votedCountLabel.text = "\(poll?.totalVoterCnt ?? 0)" + Text.votedCountTraillingText
    }

    static func height(for poll: DetailCardInfo.Poll?) -> CGFloat {
        guard let options = poll?.options, options.isEmpty == false else { return 0 }
        let count = options.count

        let rowsHeight = CGFloat(count) * Layout.rowHeight
        let spacingHeight = CGFloat(max(count - 1, 0)) * Layout.rowSpacing
        return Layout.topInset + rowsHeight + spacingHeight + 8 + Layout.bottomInset + 18
    }
}
