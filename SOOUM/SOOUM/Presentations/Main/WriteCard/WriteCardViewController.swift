//
//  WriteCardViewController.swift
//  SOOUM
//
//  Created by 오현식 on 10/18/24.
//

import UIKit

import SnapKit
import Then

import ReactorKit
import RxCocoa
import RxKeyboard
import RxSwift


class WriteCardViewController: BaseNavigationViewController, View {
    
    
    enum Text {
        static let timeLimitLabelText: String = "시간제한 카드"
        static let wirteButtonTitle: String = "작성하기"
        static let wirteTagPlacholder: String = "#태그를 입력해주세요!"
        static let relatedTagsTitle: String = "#관련태그"
    }
    
    let timeLimitBackgroundView = UIView().then {
        $0.backgroundColor = .som.secondary
        $0.layer.cornerRadius = 22 * 0.5
        $0.clipsToBounds = true
        $0.isHidden = true
    }
    
    let timeLimitLabel = UILabel().then {
        $0.text = Text.timeLimitLabelText
        $0.textColor = .som.black
        $0.typography = .init(
            fontContainer: BuiltInFont(size: 14, weight: .semibold),
            lineHeight: 14,
            letterSpacing: -0.04
        )
    }
    
    let writeButton = UIButton().then {
        let typography = Typography(
            fontContainer: BuiltInFont(size: 14, weight: .semibold),
            lineHeight: 14,
            letterSpacing: -0.02
        )
        var attributes = typography.attributes
        attributes.updateValue(typography.font, forKey: .font)
        attributes.updateValue(UIColor.som.primary, forKey: .foregroundColor)
        var config = UIButton.Configuration.plain()
        config.attributedTitle = .init(
            Text.wirteButtonTitle,
            attributes: AttributeContainer(attributes)
        )
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { _ in
            AttributeContainer(attributes)
        }
        config.contentInsets = .zero
        $0.configuration = config
    }
    
    lazy var writeCardView = WriteCardView().then {
        $0.writeCardTextView.delegate = self
        $0.writeTagTextField.delegate = self
        $0.writtenTags.delegate = self
        $0.relatedTags.delegate = self
    }
    
    override var navigationBarHeight: CGFloat {
        58
    }
    
    var writtenTagModels = [SOMTagModel]()
    
    
    // MARK: - Life Cycles
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.timeLimitBackgroundView.snp.makeConstraints {
            $0.width.equalTo(93)
            $0.height.equalTo(22)
        }
        
        self.timeLimitBackgroundView.addSubview(self.timeLimitLabel)
        self.timeLimitLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        self.navigationBar.titleView = self.timeLimitBackgroundView
        self.navigationBar.setRightButtons([self.writeButton])
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.writeCardView)
        self.writeCardView.snp.makeConstraints {
            $0.edges.equalTo(self.view.safeAreaLayoutGuide.snp.edges)
        }
    }
    
    override func updatedKeyboard(withoutBottomSafeInset height: CGFloat) {
        super.updatedKeyboard(withoutBottomSafeInset: height)
        
        let isTextFieldFirstResponder = self.writeCardView.writeTagTextField.isFirstResponder
        UIView.animate(withDuration: 0.25) {
            self.writeCardView.snp.updateConstraints {
                $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(isTextFieldFirstResponder ? -height : 0)
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(isTextFieldFirstResponder ? -height : 0)
            }
        }
        self.view.layoutIfNeeded()
    }
    
    
    // MARK: - ReactorKit
    
    func bind(reactor: WriteCardViewReactor) {
        
        /// Set tags
        let writtenTagText = self.writeCardView.writeTagTextField.rx.text.orEmpty.distinctUntilChanged().share()
        self.writeCardView.writeTagTextField.addTagButton.rx.tap
            .withLatestFrom(writtenTagText)
            .filter { $0.isEmpty == false }
            .withUnretained(self)
            .do(onNext: { object, _ in object.writeCardView.writeTagTextField.text = nil })
            .map { object, writtenTagText in
                let toModel: SOMTagModel = .init(
                    id: UUID().uuidString,
                    originalText: writtenTagText,
                    isRemovable: true,
                    configuration: .horizontalWithRemove
                )
                object.writtenTagModels.insert(toModel, at: 0)
                object.writeCardView.writtenTags.snp.updateConstraints {
                    $0.height.equalTo(58)
                }
                
                self.view.layoutIfNeeded()
                
                return object.writtenTagModels
            }
            .bind(to: self.writeCardView.writtenTags.rx.models())
            .disposed(by: self.disposeBag)
        
        /// Action
        writtenTagText
            .map(Reactor.Action.relatedTags)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        /// State
        reactor.state.map(\.relatedTags)
            .distinctUntilChanged()
            .map { relatedTags in
                let toModels: [SOMTagModel] = relatedTags.map { relatedTag in
                    let toModel: SOMTagModel = .init(
                        id: UUID().uuidString,
                        originalText: relatedTag.content,
                        count: "\(relatedTag.count)",
                        isRemovable: false,
                        configuration: .verticalWithoutRemove
                    )
                    return toModel
                }
                return toModels
            }
            .bind(to: self.writeCardView.relatedTags.rx.models())
            .disposed(by: self.disposeBag)
    }
}


extension WriteCardViewController: WriteCardTextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: WriteCardTextView) {
        
        if self.writeCardView.writeCardTextView.isFirstResponder {
            
            RxKeyboard.instance.visibleHeight
                .drive(with: self) { object, height in
                    let connectedScene: UIScene? = UIApplication.shared.connectedScenes.first
                    let sceneDelegate: SceneDelegate? = connectedScene?.delegate as? SceneDelegate
                    let safeAreaInsetBottom: CGFloat = sceneDelegate?.window?.safeAreaInsets.bottom ?? 0
                    let withoutBottomSafeInset: CGFloat = max(0, height - safeAreaInsetBottom)
                    object.updatedKeyboard(withoutBottomSafeInset: withoutBottomSafeInset)
                }
                .disposed(by: self.disposeBag)
        }
    }
}

extension WriteCardViewController: WriteTagTextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: WriteTagTextField) {
        
        if self.writeCardView.writeTagTextField.isFirstResponder {
            
            RxKeyboard.instance.visibleHeight
                .drive(with: self) { object, height in
                    let connectedScene: UIScene? = UIApplication.shared.connectedScenes.first
                    let sceneDelegate: SceneDelegate? = connectedScene?.delegate as? SceneDelegate
                    let safeAreaInsetBottom: CGFloat = sceneDelegate?.window?.safeAreaInsets.bottom ?? 0
                    let withoutBottomSafeInset: CGFloat = max(0, height - safeAreaInsetBottom)
                    object.updatedKeyboard(withoutBottomSafeInset: withoutBottomSafeInset)
                }
                .disposed(by: self.disposeBag)
        }
    }
    
    func textFieldReturnKeyClicked(_ textField: WriteTagTextField) {
        
        if self.writeCardView.writeTagTextField.isFirstResponder {
            self.writeCardView.writeTagTextField.addTagButton.sendActions(for: .touchUpInside)
        }
    }
}

extension WriteCardViewController: SOMTagsDelegate {
    
    func tags(_ tags: SOMTags, didRemove model: SOMTagModel) {
        
        self.writtenTagModels.removeAll(where: { $0 == model })
        if self.writtenTagModels.isEmpty {
            self.writeCardView.writtenTags.snp.updateConstraints {
                $0.height.equalTo(12)
            }
        }
    }
    
    func tags(_ tags: SOMTags, didTouch model: SOMTagModel) {
        
        self.writeCardView.writeTagTextField.text = model.originalText
    }
}
