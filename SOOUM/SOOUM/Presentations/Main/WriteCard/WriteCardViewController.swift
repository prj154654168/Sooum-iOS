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
        
        static let uploadCardBottomSheetEntryName: String = "uploadCardBottomSheetViewController"
    }
    
    let timeLimitBackgroundView = UIView().then {
        $0.backgroundColor = .som.p200
        $0.layer.cornerRadius = 22 * 0.5
        $0.clipsToBounds = true
        $0.isHidden = true
    }
    
    let timeLimitLabel = UILabel().then {
        $0.text = Text.timeLimitLabelText
        $0.textColor = .som.black
        $0.typography = .som.body2WithBold
    }
    
    let writeButton = UIButton().then {
        let typography = Typography.som.body2WithBold
        var attributes = typography.attributes
        attributes.updateValue(typography.font, forKey: .font)
        attributes.updateValue(UIColor.som.p300, forKey: .foregroundColor)
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
    
    let uploadCardBottomSheetViewController = UploadCardBottomSheetViewController()
    
    var writtenTagModels = [SOMTagModel]()
    
    var keyboardHeight: CGFloat = 0
    
    
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
        
        self.keyboardHeight = height == 0 ? self.keyboardHeight : height
        
        let isTextFieldFirstResponder = self.writeCardView.writeTagTextField.isFirstResponder
        UIView.animate(withDuration: 0.25) {
            self.writeCardView.snp.updateConstraints {
                $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(isTextFieldFirstResponder ? -height : 0)
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(isTextFieldFirstResponder ? -height : 0)
            }
        }
        self.view.layoutIfNeeded()
    }
    
    override func bind() {
        
        self.backButton.rx.tap
            .subscribe(with: self) { object, _ in
                object.dismissBottomSheet(completion: {
                    object.navigationPop(
                        animated: true,
                        bottomBarHidden: object.navigationPopWithBottomBarHidden
                    )
                })
            }
            .disposed(by: self.disposeBag)
    }
    
    
    // MARK: - ReactorKit
    
    func bind(reactor: WriteCardViewReactor) {
        
        // Life Cycle
        self.rx.viewWillAppear
            .subscribe(with: self) { object, _ in
                object.uploadCardBottomSheetViewController.reactor = reactor.reactorForUploadCard()
                object.presentBottomSheet(
                    presented: object.uploadCardBottomSheetViewController,
                    isHandleBar: true,
                    neverDismiss: true,
                    maxHeight: 550,
                    initalHeight: 20 + 34 + 32 + 100 * 2
                )
            }
            .disposed(by: self.disposeBag)
        
        // Keyboard, bottomSheet interaction
        RxKeyboard.instance.isHidden
            .distinctUntilChanged()
            .filter { $0 }
            .drive(with: self) { object, _ in
                object.uploadCardBottomSheetViewController.reactor = reactor.reactorForUploadCard()
                object.presentBottomSheet(
                    presented: object.uploadCardBottomSheetViewController,
                    isHandleBar: true,
                    neverDismiss: true,
                    maxHeight: 550,
                    initalHeight: 20 + 34 + 32 + 100 * 2
                )
            }
            .disposed(by: self.disposeBag)
        
        RxKeyboard.instance.willShowVisibleHeight
            .drive(with: self) { objcet, _ in
                objcet.dismissBottomSheet()
            }
            .disposed(by: self.disposeBag)
        
        // Update image for textView
        self.uploadCardBottomSheetViewController.bottomSheetImageSelected
            .distinctUntilChanged()
            .bind(to: self.writeCardView.writeCardTextView.rx.image)
            .disposed(by: self.disposeBag)
        
        // Update time limit view
        self.uploadCardBottomSheetViewController.bottomSheetOptionState
            .compactMap { $0[.timeLimit] }
            .distinctUntilChanged()
            .map { !$0 }
            .bind(to: self.timeLimitBackgroundView.rx.isHidden)
            .disposed(by: self.disposeBag)
        
        // Set tags
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
            .filter { $0.isEmpty == false }
            .map(Reactor.Action.relatedTags)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        let optionState = self.uploadCardBottomSheetViewController.bottomSheetOptionState.distinctUntilChanged().share()
        let imageName = self.uploadCardBottomSheetViewController.bottomSheetImageNameSeleted.distinctUntilChanged().share()
        let imageType = imageName.map { $0.count < 14 ? "DEFAULT" : "USER" }
        let font = self.uploadCardBottomSheetViewController.bottomSheetFontState.map { $0 == .gothic ? Font.pretendard : Font.school }
        let content = self.writeCardView.writeCardTextView.rx.text.orEmpty.distinctUntilChanged().share()
        
        self.writeButton.rx.tap
            .withLatestFrom(Observable.combineLatest(optionState, imageName, imageType, font, content))
            .subscribe(onNext: { [weak self] optionState, imageName, imageType, font, content in
                let feedTags = self?.writtenTagModels.map { $0.originalText }
                reactor.action.onNext(
                    .writeCard(
                        isDistanceShared: optionState[.distanceLimit] ?? false,
                        isPublic: optionState[.privateCard] ?? false,
                        isStory: optionState[.timeLimit] ?? false,
                        content: content,
                        font: font.rawValue,
                        imgType: imageType,
                        imgName: imageName,
                        feedTags: feedTags ?? []
                    )
                )
            })
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
        
        reactor.state.map(\.isWrite)
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(with: self) { object, _ in
                object.dismissBottomSheet(completion: {
                    object.navigationPop(
                        animated: true,
                        bottomBarHidden: object.navigationPopWithBottomBarHidden
                    )
                })
            }
            .disposed(by: self.disposeBag)
    }
}


extension WriteCardViewController: WriteCardTextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: WriteCardTextView) {
        
        if self.writeCardView.writeCardTextView.isFirstResponder {
            
            RxKeyboard.instance.isHidden
                .filter { $0 == false }
                .drive(with: self) { object, _ in
                    object.updatedKeyboard(withoutBottomSafeInset: object.keyboardHeight)
                }
                .disposed(by: self.disposeBag)
        }
    }
}

extension WriteCardViewController: WriteTagTextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: WriteTagTextField) {
        
        if self.writeCardView.writeTagTextField.isFirstResponder {
            
            RxKeyboard.instance.isHidden
                .filter { $0 == false }
                .drive(with: self) { object, _ in
                    object.updatedKeyboard(withoutBottomSafeInset: object.keyboardHeight)
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
