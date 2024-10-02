//
//  SOMNavigationBar.swift
//  SOOUM
//
//  Created by 오현식 on 9/10/24.
//

import UIKit

import SnapKit
import Then

/**
네비게이션 바 옵션 초기화 순서
    1. title
    2. titlePosition
    3. left buttons or right buttons
 */
class SOMNavigationBar: UIView {
    
    enum TitlePosition {
        case left
        case center
    }
    
    /// 네비게이션 바 높이
    static let height: CGFloat = 44
    
    private let centerContainer = UIView()

    private let leftContainer = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
    }
    
    private let leftButtonsView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
    }
    
    private let rightButtonsView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
    }
    
    private var centerContainerCenterXConstraint: Constraint?
    private var centerContainerLeadingConstraint: Constraint?
    
    /// 타이틀 (text == label / logo == image)
    let titleLabel = UILabel().then {
        $0.textColor = .som.black
        $0.typography = .init(
            fontContainer: Pretendard(size: 18, weight: .semibold),
            lineHeight: 18,
            letterSpacing: 0.005
        )
    }
    var title: String? {
        set { self.titleLabel.text = newValue }
        get { self.titleLabel.text }
    }
    var titleView: UIView? {
        didSet { self.setTitleViewConstraints(self.titleView ?? self.titleLabel) }
    }
    var titlePosition: TitlePosition = .center {
        didSet {
            self.setTitlePosition(self.titlePosition, titleView: self.titleView ?? self.titleLabel)
        }
    }
    
    /// 네비게이션 바 뒤로가기 버튼
    let backButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .init(.icon(.outlined(.arrowBack)))
        config.image?.withTintColor(.som.black)
        config.imageColorTransformer = UIConfigurationColorTransformer { _ in .som.black }
        $0.configuration = config
    }
    var isHideBackButton: Bool {
        set { self.backButton.isHidden = newValue }
        get { self.backButton.isHidden }
    }
    
    
    /// leftButtons 혹은 rightButtons 간격
    var spacing: CGFloat = 0 {
        didSet {
            self.leftContainer.spacing = self.spacing
            self.leftButtonsView.spacing = self.spacing
            self.rightButtonsView.spacing = self.spacing
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
        self.prepare()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        self.addSubview(self.centerContainer)
        self.centerContainer.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            self.centerContainerCenterXConstraint = $0.centerX.equalToSuperview().constraint
        }
        
        self.addSubview(self.leftContainer)
        self.leftContainer.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        
        self.leftContainer.addArrangedSubview(self.backButton)
        self.backButton.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        
        self.leftContainer.addArrangedSubview(self.leftButtonsView)
        
        self.addSubview(self.rightButtonsView)
        self.rightButtonsView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
    
    private func setTitleViewConstraints(_ titleView: UIView) {
        
        self.centerContainer.subviews.forEach { $0.removeFromSuperview() }
        self.centerContainer.addSubview(titleView)
        
        titleView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.setTitlePosition(self.titlePosition, titleView: titleView)
    }
    
    private func setTitlePosition(_ titlePosition: TitlePosition, titleView: UIView) {
        
        if titlePosition == .left {
            self.centerContainerCenterXConstraint?.deactivate()
            
            self.centerContainer.snp.makeConstraints {
                self.centerContainerLeadingConstraint = $0.leading.equalTo(
                    self.leftContainer.snp.trailing
                ).constraint
            }
        } else {
            self.centerContainerLeadingConstraint?.deactivate()
        }
    }
    
    private func prepare() {
        self.titleView = nil
    }
    
    var leftButtons: [UIButton]? {
        let buttons = self.leftButtonsView.arrangedSubviews as? [UIButton]
        return (buttons?.count ?? 0) == 0 ? nil : buttons
    }
    
    var rightButtons: [UIButton]? {
        let buttons = self.rightButtonsView.arrangedSubviews as? [UIButton]
        return (buttons?.count ?? 0) == 0 ? nil : buttons
    }
    
    func setLeftButtons(_ buttons: [UIButton]) {
        self.leftButtons?.forEach { $0.removeFromSuperview() }
        buttons.forEach {
            $0.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
            $0.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
            self.leftButtonsView.addArrangedSubview($0)
        }
    }
    
    func setRightButtons(_ buttons: [UIButton]) {
        self.rightButtons?.forEach { $0.removeFromSuperview() }
        buttons.forEach {
            $0.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
            $0.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
            self.rightButtonsView.addArrangedSubview($0)
        }
    }
}
