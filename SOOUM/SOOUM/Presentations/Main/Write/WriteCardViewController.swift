//
//  WriteCardViewController.swift
//  SOOUM
//
//  Created by 오현식 on 10/18/24.
//

import UIKit

import SnapKit
import Then

import Photos
import SwiftEntryKit
import YPImagePicker

import Clarity

import ReactorKit
import RxCocoa
import RxKeyboard
import RxSwift

class WriteCardViewController: BaseNavigationViewController, View {
    
    private enum Layout {
        static let voteGuideLabelLeadingInset: CGFloat = 10
        static let voteGuideDeleteSpacing: CGFloat = 2
        static let voteGuideDeleteButtonSize: CGFloat = 16
        static let voteGuideDeleteTrailingInset: CGFloat = 8
        static let voteGuideBottomSpacing: CGFloat = 4
    }
    
    enum VoteSheetPresentationContext {
        case create
        case edit
    }
    
    enum VoteSheetDismissalPolicy {
        case preserveSelection
        case clearSelection
    }
    
    enum DeleteVoteFlow {
        case deleteOnly
        case recreate
    }
    
    enum Text {
        static let navigationTitle: String = "새로운 카드"
        static let commentNavigationTitle: String = "댓글카드"
        static let navigationWriteButtonTitle: String = "완료"
        
        static let pretendardTitle: String = "프리텐다드"
        static let ridiBatangTitle: String = "리디바탕"
        static let yoonwooTitle: String = "윤우체"
        static let kkookkkookTitle: String = "꾹꾹체"
        
        static let articleTitle: String = "아티클 카드"
        static let defaultTitle: String = "피드 카드"
        
        static let locationDialogTitle: String = "위치 정보 사용 설정"
        static let locationDialogMessage: String = "내 위치 확인을 위해 ‘설정 > 앱 > 숨 > 위치’에서 위치 정보 사용을 허용해 주세요."
        
        static let libraryDialogTitle: String = "앱 접근 권한 안내"
        static let libraryDialogMessage: String = "사진첨부를 위해 접근 권한이 필요해요. [설정 > 앱 > 숨 > 사진]에서 사진 보관함 접근 권한을 허용해 주세요."
        
        static let inappositeDialogTitle: String = "부적절한 사진으로 보여져요"
        static let inappositeDialogMessage: String = "다른 사진으로 변경하거나 기본 이미지를 사용해 주세요."
        
        static let banUserDialogTitle: String = "이용 제한 안내"
        static let banUserDialogFirstLeadingMessage: String = "신고된 카드로 인해 "
        static let banUserDialogFirstTrailingMessage: String = " 카드 추가가 제한됩니다."
        static let banUserDialogSecondLeadingMessage: String = " 카드 추가는 "
        static let banUserDialogSecondTrailingMessage: String = "부터 가능합니다."
        
        static let deletedCardDialogTitle: String = "삭제된 카드예요"
        static let deleteVoteDialogTitle: String = "투표를 삭제할까요?"
        
        static let cancelActionTitle: String = "취소"
        static let deleteActionTitle: String = "삭제"
        static let settingActionTitle: String = "설정"
        static let confirmActionTitle: String = "확인"
        
        static let bottomFloatEntryName: String = "SOMBottomFloatView"
        static let makeVoteEntryName: String = "MakeVoteEntry"
        static let selectLibraryButtonTitle: String = "앨범에서 사진 선택"
        static let takePictureButtonTitle: String = "사진 찍기"
        
        static let selectPhotoFullScreenNextTitle: String = "다음"
        static let selectPhotoFullScreenCancelTitle: String = "취소"
        static let selectPhotoFullScreenSaveTitle: String = "저장"
        static let selectPhotoFullScreenAlbumsTitle: String = "앨범"
        static let selectPhotoFullScreenCameraTitle: String = "카메라"
        static let selectPhotoFullScreenLibraryTitle: String = "갤러리"
        static let selectPhotoFullScreenCropTitle: String = "자르기"
        static let voteStoryDisabledToastMessage: String = "투표가 추가된 카드는 24시간 설정을 사용할 수 없어요"
        static let voteStoryDeselectedToastMessage: String = "투표가 추가된 카드는 24시간 설정을 사용할 수 없어 옵션이 해제됐어요"
    }
    
    
    // MARK: Views
    
    private let writeCardGuideView = WriteCardGuideView()
    
    private let writeButton = SOMButton().then {
        $0.title = Text.navigationWriteButtonTitle
        $0.typography = .som.v2.subtitle1
        $0.foregroundColor = .som.v2.black
        
        $0.isEnabled = false
    }
    
    private lazy var scrollContainer = UIScrollView().then {
        $0.isScrollEnabled = true
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        
        $0.contentInset.top = 8
        $0.contentInset.bottom = 24
        
        $0.delegate = self
    }
    
    private let writeCardView = WriteCardView()
    
    private let selectVoteView = SelectVoteView().then {
        $0.isHidden = true
    }
    
    private let selectImageView = WriteCardSelectImageView()
    
    private let selectTypographyView = SelectTypographyView().then {
        $0.items = [
            (Text.pretendardTitle, .som.v2.subtitle1),
            (Text.ridiBatangTitle, .som.v2.ridiButton),
            (Text.yoonwooTitle, .som.v2.yoonwooButton),
            (Text.kkookkkookTitle, .som.v2.kkookkkookButton)
        ]
    }
    
    private let selectCardTypeView = SelectCardTypeView().then {
        $0.items = [Text.articleTitle, Text.defaultTitle]
    }
    
    private let selectOptionsView = SelectOptionsView()
    
    private lazy var voteGuideBubbleView = SOMMessageBubbleView(isDeletable: true).then {
        $0.message = SelectOptionsView.Text.voteGuideMessage
        $0.isHidden = true
    }
    
    private let makeVoteView = MakeVoteView()
    
    private lazy var contentStackView = UIStackView(arrangedSubviews: [
        self.writeCardView,
        self.selectVoteView,
        self.selectImageView,
        self.selectTypographyView,
        self.selectCardTypeView
    ]).then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 24
    }
    
    private let relatedTagsView = RelatedTagsView().then {
        $0.isHidden = true
    }
    
    
    // MARK: Override variables
    
    override var navigationPopGestureEnabled: Bool {
        false
    }
    
    
    // MARK: Variables
    
    private var isScrollingByFirstResponder: Bool = false
    private var keyboardHeight: CGFloat = 0
    private var selectedVotes: [String] = []
    private var isPresentingMakeVoteView: Bool = false
    private var isVoteGuideTemporarilyHidden: Bool = false
    private var shouldShowVoteGuide: Bool = false
    private var lastVoteGuideAnchorFrame: CGRect = .zero
    private var lastVoteGuideWidth: CGFloat = 0
    private var lastVoteGuideVisibility: Bool = false
    private var voteSheetPresentationContext: VoteSheetPresentationContext = .create
    private var voteSheetDismissalPolicy: VoteSheetDismissalPolicy = .clearSelection
    
    // MARK: Constraint
    
    private var relatedTagsViewBottomConstraint: Constraint?
    private var voteGuideBubbleCenterXConstraint: Constraint?
    private var voteGuideBubbleBottomConstraint: Constraint?
    private var voteGuideBubbleWidthConstraint: Constraint?
    
    
    // MARK: Override variables
    
    override var bottomToastMessageOffset: CGFloat {
        /// bottom safe layout guide + padding
        return 34 + 8
    }
    
    
    // MARK: Override func
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { }
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = self.reactor?.entranceType == .feed ? Text.navigationTitle : Text.commentNavigationTitle
        self.navigationBar.setRightButtons([self.writeButton])
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.selectOptionsView)
        self.selectOptionsView.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        self.view.addSubview(self.scrollContainer)
        self.scrollContainer.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(self.selectOptionsView.snp.top)
            $0.horizontalEdges.equalToSuperview()
        }
        
        self.scrollContainer.addSubview(self.contentStackView)
        self.contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        self.view.addSubview(self.relatedTagsView)
        self.relatedTagsView.snp.makeConstraints {
            self.relatedTagsViewBottomConstraint = $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).constraint
            $0.horizontalEdges.equalToSuperview()
        }
        
        self.view.insertSubview(self.voteGuideBubbleView, belowSubview: self.relatedTagsView)
        self.voteGuideBubbleView.snp.makeConstraints {
            self.voteGuideBubbleCenterXConstraint = $0.centerX.equalTo(self.view.snp.leading).offset(0).constraint
            self.voteGuideBubbleBottomConstraint = $0.bottom.equalTo(self.view.snp.top).offset(0).constraint
            self.voteGuideBubbleWidthConstraint = $0.width.equalTo(self.voteGuideBubbleWidth).constraint
        }

        self.view.insertSubview(self.selectOptionsView, belowSubview: self.relatedTagsView)
        
        guard let windowScene: UIWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window: UIWindow = windowScene.windows.first(where: { $0.isKeyWindow })
        else { return }
        
        window.addSubview(self.writeCardGuideView)
        self.writeCardGuideView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in }
        UserDefaults.hadShownWriteCardVoteGuideIfNeeded()
        self.makeVoteView.delegate = self
        self.bindSelectVoteView()
        self.renderSelectedVotes()
        
        // 카드 추가 첫 진입 시 가이드 뷰 표시
        self.writeCardGuideView.isHidden = UserDefaults.needsGuideMessageAndGuide == false
        if UserDefaults.shouldShowGuideView { UserDefaults.hadShownGuideView() }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard self.shouldShowVoteGuide else { return }
        self.layoutVoteGuideIfNeeded()
    }
    
    override func updatedKeyboard(withoutBottomSafeInset height: CGFloat) {
        super.updatedKeyboard(withoutBottomSafeInset: height)
        
        self.keyboardHeight = height
        self.relatedTagsViewBottomConstraint?.update(offset: -height)
    }
    
    override func bind() {
        
        self.navigationBar.backButton.rx.tap
            .subscribe(with: self) { object, _ in
                
                object.navigationPop {
                    
                    if case .feed = object.reactor?.entranceType {
                        GAHelper.shared.logEvent(
                            event: GAEvent.WriteCardView.goCreateFCard_cancelBtnClick
                        )
                    }
                    
                    if case .comment = object.reactor?.entranceType {
                        GAHelper.shared.logEvent(
                            event: GAEvent.WriteCardView.goCreateCCard_cancelBtnClick
                        )
                    }
                }
            }
            .disposed(by: self.disposeBag)
    }
    
    
    // MARK: ReactorKit - bind
    
    func bind(reactor: WriteCardViewReactor) {
        
        self.writeCardGuideView.closeButton.rx.tap
            .subscribe(with: self) { object, _ in
                object.writeCardGuideView.isHidden = true
            }
            .disposed(by: self.disposeBag)
        
        var options: [SelectOptionItem.OptionType] {
            if reactor.entranceType == .feed {
                return [.distanceShare, .story, .vote]
            } else {
                return [.distanceShare]
            }
        }
        self.selectOptionsView.items = options
        self.selectOptionsView.selectOptions = []
        self.selectOptionsView.setOptionEnabled(reactor.initialState.hasPermission, for: .distanceShare)
        self.refreshVoteGuideVisibility()

        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, _ in
                object.isVoteGuideTemporarilyHidden = false
                object.refreshVoteGuideVisibility()
            }
            .disposed(by: self.disposeBag)

        self.voteGuideBubbleView.deleteButtonDidTap
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, _ in
                object.isVoteGuideTemporarilyHidden = true
                object.refreshVoteGuideVisibility()
            }
            .disposed(by: self.disposeBag)
        
        self.writeCardView.textViewDidBeginEditing
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, _ in
                object.isScrollingByFirstResponder = true
                
                object.scrollContainer.setContentOffset(.zero, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak object] in
                    object?.isScrollingByFirstResponder = false
                }
            }
            .disposed(by: self.disposeBag)
        
        self.relatedTagsView.updatedContentHeight
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, updatedContentHeight in
                object.isScrollingByFirstResponder = true
                
                if let updatedContentHeight = updatedContentHeight {
                    
                    let cardViewMaxY: CGFloat = object.writeCardView.frame.maxY
                    let bottomHeight: CGFloat = object.keyboardHeight + updatedContentHeight
                    let visibleContentHeight: CGFloat = object.scrollContainer.bounds.height - bottomHeight
                    let visibleAreaBottomY: CGFloat = object.scrollContainer.contentOffset.y + visibleContentHeight
                    if cardViewMaxY > visibleAreaBottomY {
                        
                        let offset: CGFloat = cardViewMaxY - visibleAreaBottomY
                        let scrollTo: CGPoint = .init(x: 0, y: object.scrollContainer.contentOffset.y + offset)
                        object.scrollContainer.setContentOffset(scrollTo, animated: true)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak object] in
                        object?.isScrollingByFirstResponder = false
                    }
                } else {
                    
                    DispatchQueue.main.async { [weak object] in
                        object?.scrollContainer.setContentOffset(.zero, animated: true)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            object?.isScrollingByFirstResponder = false
                        }
                    }
                }
            }
            .disposed(by: self.disposeBag)
        
        let writeCardtext = self.writeCardView.writeCardTextView.rx.text.orEmpty.distinctUntilChanged().share()
        let selectedImageInfo = self.selectImageView.selectedImageInfo
            .observe(on: MainScheduler.asyncInstance)
            .share()
        writeCardtext
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false }
            .withLatestFrom(selectedImageInfo, resultSelector: { $0 && $1 != nil })
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: self.writeButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        self.writeCardView.writeCardTags.updateWrittenTags
            .distinctUntilChanged()
            .filterNil()
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: self.writeCardView.writeCardTags.rx.models())
            .disposed(by: self.disposeBag)
        
        let selectedRelatedTag = self.relatedTagsView.selectedRelatedTag.filterNil().share()
        selectedRelatedTag
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, _ in
                object.writeCardView.writeCardTags.updateFooterText = nil
            }
            .disposed(by: self.disposeBag)
        
        selectedRelatedTag
            .withUnretained(self)
            .map { object, selectedRelatedTag in
                var current = object.writeCardView.writeCardTags.models
                let new = WriteCardTagModel(
                    originalText: selectedRelatedTag.originalText,
                    typography: current.last?.typography ?? .som.v2.caption2
                )
                current.append(new)
                return current
            }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: self.writeCardView.writeCardTags.rx.models())
            .disposed(by: self.disposeBag)
        
        selectedImageInfo
            .filterNil()
            .filter { $0.info != .defaultValue }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self.writeCardView.writeCardTextView) { writeCardTextView, selectedImageInfo in
                writeCardTextView.imageInfo = selectedImageInfo.info
            }
            .disposed(by: self.disposeBag)
        
        self.selectImageView.selectedUseUserImageCell
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, _ in
                
                let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
                if status == .authorized || status == .limited {
                    
                    let actions: [SOMBottomFloatView.FloatAction] = [
                        .init(
                            title: Text.selectLibraryButtonTitle,
                            action: { [weak object] in
                                SwiftEntryKit.dismiss(.specific(entryName: Text.bottomFloatEntryName)) {
                                    object?.showPicker(for: .library)
                                }
                            }
                        ),
                        .init(
                            title: Text.takePictureButtonTitle,
                            action: { [weak object] in
                                SwiftEntryKit.dismiss(.specific(entryName: Text.bottomFloatEntryName)) {
                                    object?.showPicker(for: .photo)
                                }
                            }
                        )
                    ]
                    
                    let bottomFloatView = SOMBottomFloatView(actions: actions)
                    
                    var wrapper: SwiftEntryKitViewWrapper = bottomFloatView.sek
                    wrapper.entryName = Text.bottomFloatEntryName
                    wrapper.showBottomFloat(screenInteraction: .dismiss)
                } else {
                    
                    object.showLibraryPermissionDialog()
                }
            }
            .disposed(by: self.disposeBag)
        
        let selectedTypography = self.selectTypographyView.selectedTypography
            .distinctUntilChanged()
            .filterNil()
            .observe(on: MainScheduler.asyncInstance)
            .share(replay: 1)
        selectedTypography
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self.writeCardView) { writeCardView, selectedTypography in
                var typograhpyToTextView: Typography {
                    switch selectedTypography {
                    case .pretendard:   return .som.v2.body1
                    case .ridi:         return .som.v2.ridiCard
                    case .yoonwoo:      return .som.v2.yoonwooCard
                    case .kkookkkook:   return .som.v2.kkookkkookCard
                    }
                }
                var typograhpyToTags: Typography {
                    switch selectedTypography {
                    case .pretendard:   return .som.v2.caption2
                    case .ridi:         return .som.v2.ridiTag
                    case .yoonwoo:      return .som.v2.yoonwooTag
                    case .kkookkkook:   return .som.v2.kkookkkookTag
                    }
                }
                    
                writeCardView.writeCardTextView.typography = typograhpyToTextView
                writeCardView.writeCardTags.typography = typograhpyToTags
            }
            .disposed(by: self.disposeBag)
        
        let selectedOptions = self.selectOptionsView.selectedOptions
            .distinctUntilChanged()
            .filterNil()
            .observe(on: MainScheduler.asyncInstance)
            .share()
        
        let selectedCardType = self.selectCardTypeView.selectedCardType
            .filterNil()
            .observe(on: MainScheduler.asyncInstance)
            .share(replay: 1)
        selectedOptions
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, options in
                let hasVote = options.contains(.vote)
                object.selectOptionsView.setOptionEnabled(hasVote == false, for: .story)
            }
            .disposed(by: self.disposeBag)
        
        selectedOptions
            .filter { $0.contains(.vote) == false }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, _ in
                object.clearVotes()
                object.dismissMakeVoteBottomSheet(policy: .clearSelection)
            }
            .disposed(by: self.disposeBag)
        
        self.selectOptionsView.optionTapped
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, option in
                let options = object.selectOptionsView.selectOptions
                
                switch option {
                case .vote:
                    if options.contains(.story) {
                        object.selectOptionsView.selectOptions = options.filter { $0 != .story }
                        if object.selectedVotes.isEmpty {
                            object.showMakeVoteBottomSheetIfNeeded(context: .create)
                        } else {
                            object.showDeleteVoteDialog(flow: .recreate)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            object.showToast(
                                message: Text.voteStoryDeselectedToastMessage,
                                offset: 42,
                                in: object.makeVoteView
                            )
                        }
                        return
                    }
                    
                    if object.selectedVotes.isEmpty {
                        object.showMakeVoteBottomSheetIfNeeded(context: .create)
                    } else {
                        object.showDeleteVoteDialog(flow: .recreate)
                    }
                default:
                    return
                }
            }
            .disposed(by: self.disposeBag)
        
        self.selectOptionsView.disabledOptionTapped
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, option in
                switch option {
                case .distanceShare:
                    object.showLocationPermissionDialog()
                case .story:
                    object.showVoteStoryDisabledToast()
                default:
                    return
                }
            }
            .disposed(by: self.disposeBag)
        
        // Action
        let viewDidLoad = self.rx.viewDidLoad.share()
        viewDidLoad
            .map { _ in Reactor.Action.landing }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        viewDidLoad
            .map { _ in return [] }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: self.writeCardView.writeCardTags.rx.models())
            .disposed(by: self.disposeBag)
        
        let myRoleIsAdmin = reactor.state.map(\.myRole)
            .distinctUntilChanged()
            .filterNil()
            .observe(on: MainScheduler.asyncInstance)
            .map { $0 == .admin }
        Observable.combineLatest(viewDidLoad, myRoleIsAdmin, resultSelector: { _, isAdmin in isAdmin })
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self.selectOptionsView) { selectOptionsView, isAdmin in
                let initialOption = reactor.initialState.hasPermission && isAdmin == false
                selectOptionsView.selectOptions = initialOption ? [.distanceShare] : []
            }
            .disposed(by: self.disposeBag)
        
        let enteredTag = self.writeCardView.textDidChanged.share()
        enteredTag
            .distinctUntilChanged()
            .filterNil()
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .map(Reactor.Action.relatedTags)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        let combined = Observable.combineLatest(
            writeCardtext,
            selectedImageInfo.filterNil(),
            selectedTypography,
            selectedCardType,
            selectedOptions,
            enteredTag.startWith(nil)
        )
        self.writeButton.rx.throttleTap(.seconds(3))
            .withLatestFrom(combined)
            .withUnretained(self)
            .map { object, combined in
                let (content, imageInfo, typography, cardType, options, enteredTag) = combined
                
                GAHelper.shared.logEvent(event: GAEvent.WriteCardView.createFCard_btnClick)
                
                if options.contains(.distanceShare) == false {
                    GAHelper.shared.logEvent(
                        event: GAEvent.WriteCardView.createFCardWithoutDistanceOpt_btnClick
                    )
                }
                
                var enteredTagTexts = object.writeCardView.writeCardTags.models.map { $0.originalText }
                if let enteredTag = enteredTag, enteredTag.isEmpty == false {
                    enteredTagTexts.append(enteredTag)
                }
                
                return Reactor.Action.writeCard(
                    isDistanceShared: options.contains(.distanceShare),
                    content: content,
                    font: typography,
                    imageType: imageInfo.type,
                    imageName: imageInfo.info.imgName,
                    isStory: options.contains(.story),
                    tags: enteredTagTexts.reduce(into: []) { if !$0.contains($1) { $0.append($1) } },
                    isArticle: cardType == .article,
                    pollContents: object.selectedVotes
                )
            }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map(\.isProcessing)
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { object, isProcessing in
                object.view.endEditing(true)
                
                if isProcessing {
                    object.loadingIndicatorView.startAnimating()
                } else {
                    object.loadingIndicatorView.stopAnimating()
                }
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.writtenCardId)
            .distinctUntilChanged()
            .filterNil()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, writtenCardId in
                NotificationCenter.default.post(name: .reloadHomeData, object: nil, userInfo: nil)
                if reactor.entranceType == .comment {
                    NotificationCenter.default.post(name: .reloadDetailData, object: nil, userInfo: nil)
                }
                
                if let navigationController = object.navigationController {
                    
                    let detailViewController = DetailViewController()
                    detailViewController.reactor = reactor.reactorForDetail(with: writtenCardId)
                    
                    var viewControllers = navigationController.viewControllers
                    if (viewControllers.popLast() as? Self) != nil {
                        
                        GAHelper.shared.logEvent(
                            event: GAEvent.DetailView.cardDetail_tracePathClick(
                                previous_path: .writeCard
                            )
                        )
                        
                        viewControllers.append(detailViewController)
                        navigationController.setViewControllers(viewControllers, animated: true)
                    } else {
                        object.navigationPop()
                    }
                } else {
                    object.navigationPop()
                }
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.hasErrors)
            .distinctUntilChanged()
            .filterNil()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, hasErrors in
                if case 422 = hasErrors {
                    object.showInappositeDialog()
                    return
                }
                
                if case 410 = hasErrors {
                    object.showDeletedCardDialog()
                    return
                }
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.couldPosting)
            .filterNil()
            .filter { $0.isBaned }
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, postingPermission in
                
                let banEndGapToDays = postingPermission.expiredAt?.infoReadableTimeTakenFromThisForBanEndPosting(to: Date().toKorea())
                let banEndToString = postingPermission.expiredAt?.banEndDetailFormatted
                
                object.showWriteCardPermissionDialog(gapDays: banEndGapToDays ?? "", banEndFormatted: banEndToString ?? "")
            }
            .disposed(by: self.disposeBag)
        
        myRoleIsAdmin
            .map { !$0 }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: self.selectCardTypeView.rx.isHidden)
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.defaultImages)
            .distinctUntilChanged()
            .filterNil()
            .map { ($0, reactor.entranceType) }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: self.selectImageView.rx.setModels)
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.userImage)
            .distinctUntilChanged()
            .filterNil()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self.writeCardView.writeCardTextView) { writeCardTextView, userImage in
                writeCardTextView.image = userImage
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isDownloaded)
            .filter { $0 == true }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self.selectImageView) { selectImageView, _ in
                selectImageView.updatedByUser()
            }
            .disposed(by: self.disposeBag)
        
        let relatedTags = reactor.state.map(\.relatedTags).distinctUntilChanged().filterNil().share()
        relatedTags
            .map { $0.isEmpty }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: self.relatedTagsView.rx.isHidden)
            .disposed(by: self.disposeBag)
        
        relatedTags
            .map { $0.map { RelatedTagViewModel(originalText: $0.name, count: "\($0.usageCnt)") } }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: self.relatedTagsView.rx.models())
            .disposed(by: self.disposeBag)
    }
}


// MARK: Show dialog

extension WriteCardViewController {
    
    func showLocationPermissionDialog() {
        
        let cancelAction = SOMDialogAction(
            title: Text.cancelActionTitle,
            style: .gray,
            action: {
                SOMDialogViewController.dismiss()
            }
        )
        let settingAction = SOMDialogAction(
            title: Text.settingActionTitle,
            style: .primary,
            action: {
                SOMDialogViewController.dismiss {
                    
                    let application = UIApplication.shared
                    let openSettingsURLString: String = UIApplication.openSettingsURLString
                    if let settingsURL = URL(string: openSettingsURLString),
                       application.canOpenURL(settingsURL) {
                        application.open(settingsURL)
                    }
                }
            }
        )
        
        SOMDialogViewController.show(
            title: Text.locationDialogTitle,
            message: Text.locationDialogMessage,
            actions: [cancelAction, settingAction]
        )
    }
    
    func showLibraryPermissionDialog() {
        
        let cancelAction = SOMDialogAction(
            title: Text.cancelActionTitle,
            style: .gray,
            action: {
                SOMDialogViewController.dismiss()
            }
        )
        let settingAction = SOMDialogAction(
            title: Text.settingActionTitle,
            style: .primary,
            action: {
                SOMDialogViewController.dismiss {
                    
                    let application = UIApplication.shared
                    let openSettingsURLString: String = UIApplication.openSettingsURLString
                    if let settingsURL = URL(string: openSettingsURLString),
                       application.canOpenURL(settingsURL) {
                        application.open(settingsURL)
                    }
                }
            }
        )
        
        SOMDialogViewController.show(
            title: Text.libraryDialogTitle,
            message: Text.libraryDialogMessage,
            actions: [cancelAction, settingAction]
        )
    }
    
    func showInappositeDialog() {
        
        let actions: [SOMDialogAction] = [
            .init(
                title: Text.confirmActionTitle,
                style: .primary,
                action: {
                    SOMDialogViewController.dismiss()
                }
            )
        ]
        
        SOMDialogViewController.show(
            title: Text.inappositeDialogTitle,
            message: Text.inappositeDialogMessage,
            textAlignment: .left,
            actions: actions
        )
    }
    
    func showWriteCardPermissionDialog(gapDays: String, banEndFormatted: String) {
        
        let dialogFirstMessage = Text.banUserDialogFirstLeadingMessage +
            gapDays +
            Text.banUserDialogFirstTrailingMessage
        let dialogSecondMessage = Text.banUserDialogSecondLeadingMessage +
            banEndFormatted +
            Text.banUserDialogSecondTrailingMessage
        
        let confirmAction = SOMDialogAction(
            title: Text.confirmActionTitle,
            style: .primary,
            action: {
                SOMDialogViewController.dismiss {
                    self.navigationPop()
                }
            }
        )
        
        SOMDialogViewController.show(
            title: Text.banUserDialogTitle,
            message: dialogFirstMessage + dialogSecondMessage,
            textAlignment: .left,
            actions: [confirmAction]
        )
    }
    
    func showDeletedCardDialog() {
        
        let confirmAction = SOMDialogAction(
            title: Text.confirmActionTitle,
            style: .primary,
            action: {
                SOMDialogViewController.dismiss {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                        self?.navigationPopToRoot()
                    }
                }
            }
        )
        
        SOMDialogViewController.show(
            title: Text.deletedCardDialogTitle,
            messageView: nil,
            textAlignment: .left,
            actions: [confirmAction]
        )
    }
    
    func showDeleteVoteDialog(flow: DeleteVoteFlow = .deleteOnly) {
        
        let cancelAction = SOMDialogAction(
            title: Text.cancelActionTitle,
            style: .gray,
            action: {
                SOMDialogViewController.dismiss()
            }
        )
        let deleteAction = SOMDialogAction(
            title: Text.deleteActionTitle,
            style: .red,
            action: { [weak self] in
                SOMDialogViewController.dismiss {
                    guard let self else { return }
                    
                    self.clearVotes()
                    
                    switch flow {
                    case .deleteOnly:
                        self.removeVoteOptionSelection()
                    case .recreate:
                        self.showMakeVoteBottomSheetIfNeeded(context: .create)
                    }
                }
            }
        )
        
        SOMDialogViewController.show(
            title: Text.deleteVoteDialogTitle,
            messageView: nil,
            textAlignment: .left,
            actions: [cancelAction, deleteAction]
        )
    }
}


// MARK: Vote

extension WriteCardViewController {
    
    var voteGuideBubbleWidth: CGFloat {
        let messageWidth = (SelectOptionsView.Text.voteGuideMessage as NSString).size(
            withAttributes: [.font: Typography.som.v2.caption1.font]
        ).width
        
        return ceil(messageWidth)
            + Layout.voteGuideLabelLeadingInset
            + Layout.voteGuideDeleteSpacing
            + Layout.voteGuideDeleteButtonSize
            + Layout.voteGuideDeleteTrailingInset
    }
    
    func layoutVoteGuideIfNeeded() {
        guard self.view.window != nil else { return }
        
        guard self.shouldShowVoteGuide,
              let voteGuideAnchorFrame = self.selectOptionsView.voteGuideAnchorFrame(in: self.view)
        else {
            guard self.lastVoteGuideVisibility else { return }
            
            self.voteGuideBubbleView.isHidden = true
            self.lastVoteGuideVisibility = false
            return
        }
        
        let voteGuideBubbleWidth = self.voteGuideBubbleWidth
        let shouldUpdateLayout = self.lastVoteGuideVisibility == false
            || self.lastVoteGuideAnchorFrame != voteGuideAnchorFrame
            || self.lastVoteGuideWidth != voteGuideBubbleWidth
        
        guard shouldUpdateLayout else { return }
        
        self.voteGuideBubbleView.isHidden = false
        self.view.bringSubviewToFront(self.voteGuideBubbleView)
        if self.relatedTagsView.superview === self.view {
            self.view.bringSubviewToFront(self.relatedTagsView)
        }
        
        self.voteGuideBubbleCenterXConstraint?.update(offset: voteGuideAnchorFrame.midX)
        self.voteGuideBubbleBottomConstraint?.update(offset: voteGuideAnchorFrame.minY - Layout.voteGuideBottomSpacing)
        self.voteGuideBubbleWidthConstraint?.update(offset: voteGuideBubbleWidth)
        
        self.lastVoteGuideAnchorFrame = voteGuideAnchorFrame
        self.lastVoteGuideWidth = voteGuideBubbleWidth
        self.lastVoteGuideVisibility = true
    }
    
    func showVoteStoryDisabledToast() {
        self.showToast(
            message: Text.voteStoryDisabledToastMessage,
            offset: self.bottomToastMessageOffset + 8
        )
    }

    func presentMakeVoteViewAnimated() {
        guard let containerView = self.view.window ??
                self.navigationController?.view ??
                self.view
        else { return }

        if self.makeVoteView.superview !== containerView {
            self.makeVoteView.removeFromSuperview()
            containerView.addSubview(self.makeVoteView)
            self.makeVoteView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }

        containerView.layoutIfNeeded()
        self.makeVoteView.transform = .init(translationX: containerView.bounds.width, y: 0)

        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            options: [.curveEaseInOut]
        ) {
            self.makeVoteView.transform = .identity
        }
    }

    func dismissMakeVoteViewAnimated(completion: (() -> Void)? = nil) {
        guard let containerView = self.makeVoteView.superview else {
            completion?()
            return
        }

        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            options: [.curveEaseInOut]
        ) {
            self.makeVoteView.transform = .init(translationX: containerView.bounds.width, y: 0)
        } completion: { _ in
            self.makeVoteView.transform = .identity
            self.makeVoteView.removeFromSuperview()
            completion?()
        }
    }
    
    func showMakeVoteBottomSheetIfNeeded(context: VoteSheetPresentationContext) {
        guard self.isPresentingMakeVoteView == false else { return }
        self.isPresentingMakeVoteView = true
        self.isVoteGuideTemporarilyHidden = true
        self.refreshVoteGuideVisibility()
        self.voteSheetPresentationContext = context
        self.voteSheetDismissalPolicy = context == .edit ? .preserveSelection : .clearSelection
        
        self.makeVoteView.makedVotes = self.selectedVotes

        self.presentMakeVoteViewAnimated()
    }
    
    func dismissMakeVoteBottomSheet(policy: VoteSheetDismissalPolicy, completion: (() -> Void)? = nil) {
        self.voteSheetDismissalPolicy = policy
        
        guard self.isPresentingMakeVoteView else {
            self.voteSheetDismissalPolicy = .clearSelection
            completion?()
            return
        }

        self.dismissMakeVoteViewAnimated { [weak self] in
            guard let self else {
                completion?()
                return
            }

            self.isPresentingMakeVoteView = false
            let dismissalPolicy = self.voteSheetDismissalPolicy
            self.voteSheetDismissalPolicy = .clearSelection
            self.voteSheetPresentationContext = .create

            if dismissalPolicy == .clearSelection {
                self.clearVotes()
                self.removeVoteOptionSelection()
            }

            completion?()
        }
    }
    
    func removeVoteOptionSelection() {
        let updatedOptions = self.selectOptionsView.selectOptions.filter { $0 != .vote }
        
        guard updatedOptions.count != self.selectOptionsView.selectOptions.count else { return }
        self.selectOptionsView.selectOptions = updatedOptions
    }
    
    func clearVotes() {
        self.selectedVotes = []
        self.makeVoteView.makedVotes = []
        self.renderSelectedVotes()
    }

    func refreshVoteGuideVisibility() {
        self.shouldShowVoteGuide = UserDefaults.shouldShowWriteCardVoteGuide
            && self.isVoteGuideTemporarilyHidden == false
        self.voteGuideBubbleView.isHidden = self.shouldShowVoteGuide == false
    }
    
    func renderSelectedVotes() {
        let hasVotes = self.selectedVotes.isEmpty == false
        
        self.selectVoteView.items = self.selectedVotes
        self.selectVoteView.isHidden = hasVotes == false
    }
    
    func bindSelectVoteView() {
        self.selectVoteView.editButtonTap
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, _ in
                object.showMakeVoteBottomSheetIfNeeded(context: .edit)
            }
            .disposed(by: self.disposeBag)
        
        self.selectVoteView.deleteButtonTap
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { object, _ in
                object.showDeleteVoteDialog()
            }
            .disposed(by: self.disposeBag)
    }
}


// MARK: Show picker

extension WriteCardViewController {
    
    func showPicker(for screen: YPPickerScreen) {
        
        var config = YPImagePickerConfiguration()
        
        config.library.options = nil
        config.library.minWidthForItem = nil
        config.showsCrop = .rectangle(ratio: 1.0)
        config.showsPhotoFilters = false
        config.library.preselectedItems = nil
        config.screens = [screen]
        config.startOnScreen = screen
        config.shouldSaveNewPicturesToAlbum = false
        
        config.wordings.next = Text.selectPhotoFullScreenNextTitle
        config.wordings.cancel = Text.selectPhotoFullScreenCancelTitle
        config.wordings.save = Text.selectPhotoFullScreenSaveTitle
        config.wordings.albumsTitle = Text.selectPhotoFullScreenAlbumsTitle
        config.wordings.cameraTitle = Text.selectPhotoFullScreenCameraTitle
        config.wordings.libraryTitle = Text.selectPhotoFullScreenLibraryTitle
        config.wordings.crop = Text.selectPhotoFullScreenCropTitle
        
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [weak self, weak picker] items, cancelled in
            
            if cancelled {
                Log.debug("Picker was canceled")
                picker?.dismiss(animated: true, completion: nil)
                return
            }
            
            if let image = items.singlePhoto?.image {
                self?.reactor?.action.onNext(.updateUserImage(image, true))
            } else {
                self?.reactor?.action.onNext(.updateUserImage(nil, false))
                Log.error("Error occured while picking an image")
            }
            picker?.dismiss(animated: true) { ClaritySDK.resume() }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.present(picker, animated: true) { ClaritySDK.pause() }
        }
    }
}


// MARK: UIScrollViewDelegate

extension WriteCardViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard self.isScrollingByFirstResponder == false else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.reactor?.action.onNext(.updateRelatedTags)
        }
        self.view.endEditing(true)
    }
}

extension WriteCardViewController: MakeVoteViewDelegate {
    
    func makeVoteViewDidTapClose(_ makeVoteView: MakeVoteView) {
        let dismissalPolicy: VoteSheetDismissalPolicy =
        self.voteSheetPresentationContext == .edit ? .preserveSelection : .clearSelection
        
        self.dismissMakeVoteBottomSheet(policy: dismissalPolicy)
    }
    
    func makeVoteView(_ makeVoteView: MakeVoteView, didTapComplete votes: [String]) {
        self.selectedVotes = votes
        self.renderSelectedVotes()
        self.dismissMakeVoteBottomSheet(policy: .preserveSelection)
    }
}
