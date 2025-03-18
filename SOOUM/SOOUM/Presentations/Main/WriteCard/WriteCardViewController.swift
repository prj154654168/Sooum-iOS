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
        
        static let writeDialogTitle: String = "카드를 작성할까요?"
        static let writeDialogMessage: String = "추가한 카드는 수정할 수 없어요"
        
        static let failedWriteDialogTitle: String = "부적절한 사진으로 보여져요"
        static let failedWriteDialogMessage: String = "적절한 사진으로 바꾸거나\n기본 이미지를 사용해주세요"
        
        static let donotWirteDialogTitle: String = "카드를 작성할 수 없어요"
        static let donotWirteDialogTopMessage: String = "지속적인 신고 접수로 인해"
        static let donotWirteDialogBottomMessage: String = "까지\n카드를 작성할 수 없어요"
        
        
        static let cancelActionTitle: String = "취소"
        static let addCardActionTitle: String = "카드추가"
        static let confirmActionTitle: String = "확인"
    }
    
    enum ConstValue {
        static let maxCharacterForTag: Int = 15
    }
    
    
    // MARK: Views
    
    private let timeLimitBackgroundView = UIView().then {
        $0.backgroundColor = .som.p200
        $0.layer.cornerRadius = 22 * 0.5
        $0.clipsToBounds = true
        $0.isHidden = true
    }
    
    private let timeLimitLabel = UILabel().then {
        $0.text = Text.timeLimitLabelText
        $0.textColor = .som.black
        $0.typography = .som.body2WithBold
    }
    
    private let writeButton = SOMButton().then {
        $0.title = Text.wirteButtonTitle
        $0.typography = .som.body2WithBold
        $0.foregroundColor = .som.gray700
        
        $0.isEnabled = false
    }
    
    private lazy var writeCardView = WriteCardView().then {
        $0.writeCardTextView.delegate = self
        $0.writeTagTextField.delegate = self
        $0.writtenTags.delegate = self
        $0.relatedTags.delegate = self
    }
    
    private let uploadCardBottomSheetViewController = UploadCardBottomSheetViewController()
    
    private var writtenTagModels = [SOMTagModel]()
    
    
    // MARK: Override variables
    
    override var navigationBarHeight: CGFloat {
        58
    }
    
    override var navigationPopGestureEnabled: Bool {
        false
    }
    
    
    // MARK: Variables
    
    private var keyboardHeight: CGFloat = 0
    
    private let initalHeight: CGFloat = 38 + 24 + ((UIScreen.main.bounds.width - 40) * 0.5) + 28
    private var maxHeight: CGFloat = 38 + 24 + ((UIScreen.main.bounds.width - 40) * 0.5) + 28 + 92 + (74 * 3) + 19
    
    // 펑 이벤트 처리 위해 추가
    private var serialTimer: Disposable?
    
    
    // MARK: Override func
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupNaviBar()
        
        guard self.presentedViewController == nil else { return }
        self.showBottomSheet(
            presented: self.uploadCardBottomSheetViewController,
            dismissWhenScreenDidTap: true,
            isHandleBar: true,
            neverDismiss: true,
            maxHeight: self.maxHeight,
            initalHeight: self.initalHeight
        )
    }
  
    deinit {
      guard let isWrite = self.reactor?.currentState.isWrite else {
        return
      }
      let tagStrs = writtenTagModels.map { $0.originalText }
      if isWrite {
        GAManager.shared.logEvent(
          event: SOMEvent.WriteCard.add_tag(tag_count: tagStrs.count, tag_texts: tagStrs)
        )
      } else {
        GAManager.shared.logEvent(
          event: SOMEvent.WriteCard.dismiss_with_tag(tag_count: tagStrs.count, tag_texts: tagStrs)
        )
      }
    }
    
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
        self.writeCardView.snp.updateConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(isTextFieldFirstResponder ? -height : 0)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(isTextFieldFirstResponder ? -height : 0)
        }
        
        UIView.performWithoutAnimation {
            self.view.layoutIfNeeded()
        }
    }
    
    override func bind() {
        super.bind()
        
        self.uploadCardBottomSheetViewController.reactor = self.reactor?.reactorForUploadCard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.serialTimer?.dispose()
        
        self.presentedViewController?.dismiss(animated: false)
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: WriteCardViewReactor) {
        
        // landing
        self.rx.viewWillAppear
            .map { _ in Reactor.Action.landing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // 피드 및 답글 작성 시 바텀 시트 높이 및 태그 입력 영역 숨김 처리
        if reactor.requestType == .comment {
            self.maxHeight = 38 + 24 + ((UIScreen.main.bounds.width - 40) * 0.5) + 28 + 92 + 74 + 19
            
            self.writeCardView.writeTagTextField.isHidden = reactor.parentPungTime != nil
            self.writeCardView.pungTimeView.isHidden = reactor.parentPungTime == nil
            
            if reactor.parentPungTime != nil {
                self.subscribePungTime()
            }
        }
        
        // Keyboard, bottomSheet interaction
        RxKeyboard.instance.isHidden
            .drive(with: self) { object, isHidden in
                
                // 부모 뷰로 돌아갈 때, 아래 조건 무시
                guard object.isMovingFromParent == false else { return }
                
                if isHidden {
                    
                    // 현재 present 된 viewController가 없을 때 표시
                    guard object.presentedViewController == nil else { return }
                    
                    object.showBottomSheet(
                        presented: object.uploadCardBottomSheetViewController,
                        dismissWhenScreenDidTap: true,
                        isHandleBar: true,
                        neverDismiss: true,
                        maxHeight: object.maxHeight,
                        initalHeight: object.initalHeight
                    )
                } else {
                    
                    // 현재 present 된 viewController가 있을 때 dismiss
                    guard object.presentedViewController != nil else { return }
                    
                    object.dismissBottomSheet()
                }
            }
            .disposed(by: self.disposeBag)
            
        // Update image for textView
        let bottomSheetImageSelected = self.uploadCardBottomSheetViewController.bottomSheetImageSelected.distinctUntilChanged().share()
        bottomSheetImageSelected
            .filterNil()
            .bind(to: self.writeCardView.writeCardTextView.rx.image)
            .disposed(by: self.disposeBag)
        
        // Set tags
        let writtenTagText = self.writeCardView.writeTagTextField.rx.text.orEmpty.distinctUntilChanged().share()
        self.writeCardView.writeTagTextField.addTagButton.rx.throttleTap(.seconds(3))
            .withLatestFrom(writtenTagText)
            .filter { $0.isEmpty == false }
            .withUnretained(self)
            .do(onNext: { object, writtenTagText in
                object.writeCardView.writeTagTextField.text = nil
                object.writeCardView.writeTagTextField.sendActionsToTextField(for: .editingChanged)
            })
            .map { object, writtenTagText in
                let toModel: SOMTagModel = .init(
                    id: UUID().uuidString,
                    originalText: writtenTagText,
                    isRemovable: true
                )
                
                guard object.writtenTagModels.contains(toModel) == false else { return object.writtenTagModels }
                
                object.writtenTagModels.append(toModel)
                object.writeCardView.writtenTagsHeightConstraint?.deactivate()
                object.writeCardView.writtenTags.snp.makeConstraints {
                    object.writeCardView.writtenTagsHeightConstraint = $0.height.equalTo(58).constraint
                }
                
                UIView.performWithoutAnimation {
                    object.view.layoutIfNeeded()
                }
                
                return object.writtenTagModels
            }
            .bind(to: self.writeCardView.writtenTags.rx.models())
            .disposed(by: self.disposeBag)
        
        // Action
        writtenTagText
            .filter { $0.isEmpty == false }
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .map(Reactor.Action.relatedTags)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        let optionState = self.uploadCardBottomSheetViewController.bottomSheetOptionState
            .distinctUntilChanged()
            .share(replay: 1, scope: .whileConnected)
        let imageName = self.uploadCardBottomSheetViewController.bottomSheetImageNameSeleted
            .distinctUntilChanged()
            .share(replay: 1, scope: .whileConnected)
        let imageType = imageName.map { $0.count < 14 ? "DEFAULT" : "USER" }
        let font = self.uploadCardBottomSheetViewController.bottomSheetFontState
            .distinctUntilChanged()
            .map { $0 == .gothic ? Font.pretendard : Font.school }
            .share(replay: 1, scope: .whileConnected)
        let content = self.writeCardView.writeCardTextView.rx.text.orEmpty
            .distinctUntilChanged()
            .share(replay: 1, scope: .whileConnected)
        
        // 네비게이션 바 작성하기 버튼 attributes 설정
        Observable.combineLatest(
            content,
            bottomSheetImageSelected,
            resultSelector: { $0.isEmpty == false && $1 != nil }
        )
            .subscribe(with: self) { object, isEnabled in
                
                object.writeButton.isEnabled = isEnabled
                object.writeButton.foregroundColor = isEnabled ? .som.p300 : .som.gray700
            }
            .disposed(by: self.disposeBag)
        
        // 시간제한 카드 뷰 및 태그 표시
        optionState
            .skip(1)
            .compactMap { $0[.timeLimit] }
            .subscribe(with: self) { object, isTimeLimit in
                
                object.timeLimitBackgroundView.isHidden = isTimeLimit == false
                
                object.writeCardView.relatedTagsBackgroundView.isHidden = isTimeLimit
                
                object.writeCardView.writeTagTextField.isHidden = isTimeLimit
                object.writeCardView.writtenTagsHeightConstraint?.deactivate()
                object.writeCardView.writtenTags.snp.makeConstraints {
                    let height = object.writtenTagModels.isEmpty ? 12 : 58
                    let constraint = isTimeLimit ? $0.height.equalTo(0).constraint : $0.height.equalTo(height).constraint
                    object.writeCardView.writtenTagsHeightConstraint = constraint
                }
            }
            .disposed(by: self.disposeBag)
        
        font
            .subscribe(with: self.writeCardView) { writeCardView, font in
                let isChange = font == .school
                writeCardView.writeCardTextView.typography = isChange ? .som.schoolBody1WithBold : .som.body1WithBold
            }
            .disposed(by: self.disposeBag)
        
        let combined = Observable.combineLatest(optionState, imageName, imageType, font, content)
        self.writeButton.rx.throttleTap(.seconds(3))
            .withLatestFrom(combined)
            .filter { $4.isEmpty == false }
            .subscribe(with: self) { object, combine in
                let (optionState, imageName, imageType, font, content) = combine
                
                let cancelAction = SOMDialogAction(
                    title: Text.cancelActionTitle,
                    style: .gray,
                    action: {
                        UIApplication.topViewController?.dismiss(animated: true)
                    }
                )
                let addCardAction = SOMDialogAction(
                    title: Text.addCardActionTitle,
                    style: .primary,
                    action: {
                        let feedTags = object.writtenTagModels.map { $0.originalText }
                        if reactor.requestType == .card {
                            GAManager.shared.logEvent(
                                event: SOMEvent.Comment.add_comment(
                                  comment_length: content.count,
                                  parent_post_id: reactor.parentCardId ?? "",
                                  image_attached: imageType == "USER"
                                )
                            )
                            reactor.action.onNext(
                                .writeCard(
                                    isDistanceShared: optionState[.distanceLimit] ?? false,
                                    isPublic: optionState[.privateCard] ?? false,
                                    isStory: optionState[.timeLimit] ?? false,
                                    content: content,
                                    font: font.rawValue,
                                    imgType: imageType,
                                    imgName: imageName,
                                    feedTags: feedTags
                                )
                            )
                        } else {
                                    
                            reactor.action.onNext(
                                .writeComment(
                                    isDistanceShared: optionState[.distanceLimit] ?? false,
                                    content: content,
                                    font: font.rawValue,
                                    imgType: imageType,
                                    imgName: imageName,
                                    commentTags: feedTags
                                )
                            )
                        }
                                
                        UIApplication.topViewController?.dismiss(animated: true)
                    }
                )
                
                SOMDialogViewController.show(
                    title: Text.writeDialogTitle,
                    message: Text.writeDialogMessage,
                    actions: [cancelAction, addCardAction]
                )
            }
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map(\.banEndAt)
            .filterNil()
            .subscribe(with: self) { object, banEndAt in
                let confirmAction = SOMDialogAction(
                    title: Text.confirmActionTitle,
                    style: .primary,
                    action: {
                        UIApplication.topViewController?.dismiss(animated: true) {
                            object.navigationPop()
                        }
                    }
                )
                
                SOMDialogViewController.show(
                    title: Text.donotWirteDialogTitle,
                    message: "\(Text.donotWirteDialogTopMessage)\n\(banEndAt.banEndDetailFormatted)\(Text.donotWirteDialogBottomMessage)",
                    actions: [confirmAction]
                )
            }
            .disposed(by: self.disposeBag)
        
        let relatedTags = reactor.state.map(\.relatedTags).distinctUntilChanged().share()
        writtenTagText
            .map { $0.isEmpty }
            .bind(to: self.writeCardView.relatedTagsBackgroundView.rx.isHidden)
            .disposed(by: self.disposeBag)
        relatedTags
            .map { relatedTags in
                let toModels: [SOMTagModel] = relatedTags.map { relatedTag in
                    let toModel: SOMTagModel = .init(
                        id: UUID().uuidString,
                        originalText: relatedTag.content,
                        count: "0\(relatedTag.count)",
                        isSelectable: true,
                        isRemovable: false
                    )
                    return toModel
                }
                return toModels
            }
            .bind(to: self.writeCardView.relatedTags.rx.models())
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isWrite)
            .filterNil()
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(with: self) { object, isWrite in
                
                // 글추가 성공
                if isWrite {
                    // 키보드가 표시되어 있을 때, 이전 화면으로 전환
                    if object.presentedViewController == nil {
                        
                        object.navigationPop()
                    } else {
                        // 바텀싯이 표시되어 있을 때, 바텀싯 제거 후 이전 화면으로 전환
                        object.dismissBottomSheet(completion: {
                            object.navigationPop()
                        })
                    }
                } else {
                    // 글추가 실패, 실패 다이얼로그 표시
                    let confirmAction = SOMDialogAction(
                        title: Text.confirmActionTitle,
                        style: .primary,
                        action: {
                            UIApplication.topViewController?.dismiss(animated: true)
                        }
                    )
                    
                    SOMDialogViewController.show(
                        title: Text.failedWriteDialogTitle,
                        message: Text.failedWriteDialogMessage,
                        actions: [confirmAction]
                    )
                }
            }
            .disposed(by: self.disposeBag)
    }
    
    
    // MARK: Private func
    
    // 펑 이벤트 구독
    private func subscribePungTime() {
        self.serialTimer?.dispose()
        self.serialTimer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .startWith((self, 0))
            .map { object, _ in
                guard let pungTime = object.reactor?.parentPungTime else {
                    object.serialTimer?.dispose()
                    return "00 : 00 : 00"
                }
                
                let currentDate = Date()
                let remainingTime = currentDate.infoReadableTimeTakenFromThisForPung(to: pungTime)
                if remainingTime == "00 : 00 : 00" {
                    object.serialTimer?.dispose()
                }
                
                return remainingTime
            }
            .bind(to: self.writeCardView.pungTimeView.rx.text)
    }
}


// MARK: WriteCardTextViewDelegate

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


// MARK: WriteTagTextFieldDelegate

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
    
    func textField(
        _ textField: WriteTagTextField,
        shouldChangeTextIn range: NSRange,
        replacementText string: String
    ) -> Bool {
        
        let nsString: NSString? = textField.text as NSString?
        let newString: String = nsString?.replacingCharacters(in: range, with: string) ?? ""
        
        return newString.count < ConstValue.maxCharacterForTag + 1
    }
    
    func textFieldReturnKeyClicked(_ textField: WriteTagTextField) -> Bool {
        
        if self.writeCardView.writeTagTextField.isFirstResponder {
            self.writeCardView.writeTagTextField.addTagButton.sendActions(for: .touchUpInside)
            return false
        }
        
        return true
    }
}


// MARK: SOMTagsDelegate

extension WriteCardViewController: SOMTagsDelegate {
    
    // writtenTags.tag == 0
    // relatedTags.tag == 1
    func tags(_ tags: SOMTags, didRemove model: SOMTagModel) {
        
        if tags.tag == 0 {
            self.writtenTagModels.removeAll(where: { $0 == model })
            if self.writtenTagModels.isEmpty {
                self.writeCardView.writtenTagsHeightConstraint?.deactivate()
                self.writeCardView.writtenTags.snp.makeConstraints {
                    self.writeCardView.writtenTagsHeightConstraint = $0.height.equalTo(12).constraint
                }
            }
        }
    }
    
    func tags(_ tags: SOMTags, didTouch model: SOMTagModel) {
        
        if tags.tag == 1 {
            guard self.writtenTagModels.contains(model) == false else { return }
            
            let toModel: SOMTagModel = .init(
                id: model.id,
                originalText: model.originalText,
                isRemovable: true
            )
            
            self.writtenTagModels.append(toModel)
            self.writeCardView.writtenTagsHeightConstraint?.deactivate()
            self.writeCardView.writtenTags.snp.makeConstraints {
                self.writeCardView.writtenTagsHeightConstraint = $0.height.equalTo(58).constraint
            }
            
            UIView.performWithoutAnimation {
                self.view.layoutIfNeeded()
            }
            
            self.writeCardView.writtenTags.setModels(self.writtenTagModels)
        }
    }
}
