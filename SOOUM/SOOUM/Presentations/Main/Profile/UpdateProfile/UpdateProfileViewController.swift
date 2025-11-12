//
//  UpdateProfileViewController.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import UIKit

import SnapKit
import Then

import Photos
import SwiftEntryKit
import YPImagePicker

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift


class UpdateProfileViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let navigationTitle: String = "프로필 편집"
        static let guideMessage: String = "최대 8자까지 입력할 수 있어요"
        static let saveButtonTitle: String = "저장"
        
        static let cancelActionTitle: String = "취소"
        static let settingActionTitle: String = "설정"
        static let completeButtonTitle: String = "완료"
        static let passButtonTitle: String = "건너뛰기"
        
        static let libraryDialogTitle: String = "앱 접근 권한 안내"
        static let libraryDialogMessage: String = "사진첨부를 위해 접근 권한이 필요해요. [설정 > 앱 > 숨 > 사진]에서 사진 보관함 접근 권한을 허용해 주세요."
        
        static let inappositeDialogTitle: String = "부적절한 사진으로 보여져요"
        static let inappositeDialogMessage: String = "다른 사진으로 변경하거나 기본 이미지를 사용해 주세요."
        static let inappositeDialogConfirmButtonTitle: String = "확인"
        
        static let selectProfileEntryName: String = "SOMBottomFloatView"
        
        static let selectProfileFirstButtonTitle: String = "앨범에서 사진 선택"
        static let selectProfileSecondButtonTitle: String = "사진 찍기"
        static let selectProfileThirdButtonTitle: String = "기본 이미지 적용"
        
        static let selectPhotoFullScreenNextTitle: String = "다음"
        static let selectPhotoFullScreenCancelTitle: String = "취소"
        static let selectPhotoFullScreenSaveTitle: String = "저장"
        static let selectPhotoFullScreenAlbumsTitle: String = "앨범"
        static let selectPhotoFullScreenCameraTitle: String = "카메라"
        static let selectPhotoFullScreenLibraryTitle: String = "갤러리"
        static let selectPhotoFullScreenCropTitle: String = "자르기"
    }
    
    
    // MARK: Views
    
    private let profileImageView = UIImageView().then {
        $0.image = .init(.image(.v2(.profile_large)))
        $0.backgroundColor = .som.v2.gray300
        $0.layer.cornerRadius = 120 * 0.5
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.som.v2.gray300.cgColor
        $0.clipsToBounds = true
    }
    private let cameraButton = SOMButton().then {
        $0.image = .init(.icon(.v2(.filled(.camera))))
        $0.foregroundColor = .som.v2.gray400
        
        $0.backgroundColor = .som.v2.white
        $0.layer.borderColor = UIColor.som.v2.gray200.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 32 * 0.5
    }
    
    private let nicknameTextField = SOMNicknameTextField().then {
        $0.guideMessage = Text.guideMessage
    }
    
    private let saveButton = SOMButton().then {
        $0.title = Text.saveButtonTitle
        $0.typography = .som.v2.title1
        $0.foregroundColor = .som.v2.white
        
        $0.backgroundColor = .som.v2.black
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    
    // MARK: Variables
    
    private var actions: [SOMBottomFloatView.FloatAction] = []
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.profileImageView)
        self.profileImageView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(24)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(120)
        }
        self.view.addSubview(self.cameraButton)
        self.cameraButton.snp.makeConstraints {
            $0.bottom.equalTo(self.profileImageView.snp.bottom)
            $0.trailing.equalTo(self.profileImageView.snp.trailing)
            $0.size.equalTo(32)
        }
        
        self.view.addSubview(self.nicknameTextField)
        self.nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(self.profileImageView.snp.bottom).offset(40)
            $0.horizontalEdges.equalToSuperview()
        }
        
        self.view.addSubview(self.saveButton)
        self.saveButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(48)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in }
    }
    
    override func updatedKeyboard(withoutBottomSafeInset height: CGFloat) {
        super.updatedKeyboard(withoutBottomSafeInset: height)
        
        let margin: CGFloat = height + 12
        self.saveButton.snp.updateConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-margin)
        }
    }
    
    
    // MARK: ReactorKit bind
    
    func bind(reactor: UpdateProfileViewReactor) {
        
        self.rx.viewDidLoad
            .subscribe(with: self) { object, _ in
                
                var actions: [SOMBottomFloatView.FloatAction] = [
                    .init(
                        title: Text.selectProfileFirstButtonTitle,
                        action: { [weak object] in
                            SwiftEntryKit.dismiss(.specific(entryName: Text.selectProfileEntryName)) {
                                object?.showPicker(for: .library)
                            }
                        }
                    ),
                    .init(
                        title: Text.selectProfileSecondButtonTitle,
                        action: { [weak object] in
                            SwiftEntryKit.dismiss(.specific(entryName: Text.selectProfileEntryName)) {
                                object?.showPicker(for: .photo)
                            }
                        }
                    )
                ]
                
                if let imageUrl = reactor.profileInfo.profileImageUrl,
                   let imageName = reactor.profileInfo.profileImgName {
                    
                    object.profileImageView.setImage(strUrl: imageUrl, with: imageName)
                    
                    actions.append(.init(
                        title: Text.selectProfileThirdButtonTitle,
                        action: {
                            SwiftEntryKit.dismiss(.specific(entryName: Text.selectProfileEntryName)) {
                                reactor.action.onNext(.setDefaultImage)
                            }
                        }
                    ))
                }
                object.nicknameTextField.text = reactor.profileInfo.nickname
            }
            .disposed(by: self.disposeBag)
        
        // Action
        Observable.merge(
            self.profileImageView.rx.tapGesture().when(.ended).map { _ in },
            self.cameraButton.rx.tap.asObservable()
        )
        .subscribe(with: self) { object, _ in
            
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            if status == .authorized || status == .limited {
                
                let selectProfileBottomFloatView = SOMBottomFloatView(actions: object.actions)
                
                var wrapper: SwiftEntryKitViewWrapper = selectProfileBottomFloatView.sek
                wrapper.entryName = Text.selectProfileEntryName
                wrapper.showBottomFloat(screenInteraction: .dismiss)
            } else {
                
                object.showLibraryPermissionDialog()
            }
        }
        .disposed(by: self.disposeBag)
        
        let nickname = self.nicknameTextField.textField.rx.text.orEmpty.distinctUntilChanged().share()
        nickname
            .skip(1)
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .map(Reactor.Action.checkValidate)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.saveButton.rx.tap
            .withLatestFrom(nickname)
            .map(Reactor.Action.updateProfile)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        // State
        reactor.state.map(\.hasErrors)
            .filterNil()
            .filter { $0 }
            .subscribe(onNext: { _ in
                
                let actions: [SOMDialogAction] = [
                    .init(
                        title: Text.inappositeDialogConfirmButtonTitle,
                        style: .primary,
                        action: {
                            UIApplication.topViewController?.dismiss(animated: true)
                        }
                    )
                ]
                
                SOMDialogViewController.show(
                    title: Text.inappositeDialogTitle,
                    message: Text.inappositeDialogMessage,
                    textAlignment: .left,
                    actions: actions
                )
            })
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.profileImage)
            .distinctUntilChanged()
            .subscribe(with: self) { object, profileImage in
                object.profileImageView.image = profileImage ?? .init(.image(.v2(.profile_large)))
                
                var actions: [SOMBottomFloatView.FloatAction] = [
                    .init(
                        title: Text.selectProfileFirstButtonTitle,
                        action: { [weak object] in
                            SwiftEntryKit.dismiss(.specific(entryName: Text.selectProfileEntryName)) {
                                object?.showPicker(for: .library)
                            }
                        }
                    ),
                    .init(
                        title: Text.selectProfileSecondButtonTitle,
                        action: { [weak object] in
                            SwiftEntryKit.dismiss(.specific(entryName: Text.selectProfileEntryName)) {
                                object?.showPicker(for: .photo)
                            }
                        }
                    )
                ]
                
                if profileImage != nil {
                    actions.append(.init(
                        title: Text.selectProfileThirdButtonTitle,
                        action: {
                            SwiftEntryKit.dismiss(.specific(entryName: Text.selectProfileEntryName)) {
                                reactor.action.onNext(.setDefaultImage)
                            }
                        }
                    ))
                }
                
                object.actions = actions
            }
            .disposed(by: self.disposeBag)

        // State
        reactor.state.map(\.isUpdatedSuccess)
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(with: self) { object, _ in
                object.navigationPop(bottomBarHidden: false) {
                    NotificationCenter.default.post(name: .reloadProfileData, object: nil, userInfo: nil)
                }
            }
            .disposed(by: self.disposeBag)
        
        Observable.combineLatest(
            reactor.state.map(\.isValid)
                .distinctUntilChanged(),
            reactor.state.map(\.profileImage)
                .distinctUntilChanged(),
            resultSelector: { $0 || $1 != nil }
        )
            .bind(to: self.saveButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.hasErrors)
            .filterNil()
            .filter { $0 }
            .subscribe(onNext: { _ in
                
                let actions: [SOMDialogAction] = [
                    .init(
                        title: Text.inappositeDialogConfirmButtonTitle,
                        style: .primary,
                        action: {
                            UIApplication.topViewController?.dismiss(animated: true)
                        }
                    )
                ]
                
                SOMDialogViewController.show(
                    title: Text.inappositeDialogTitle,
                    message: Text.inappositeDialogMessage,
                    textAlignment: .left,
                    actions: actions
                )
            })
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.errorMessage)
            .distinctUntilChanged()
            .subscribe(with: self) { object, errorMessage in
                object.nicknameTextField.guideMessage = errorMessage == nil ? Text.guideMessage : errorMessage
                object.nicknameTextField.hasError = errorMessage != nil
            }
            .disposed(by: self.disposeBag)
    }
}

private extension UpdateProfileViewController {
    
    func showLibraryPermissionDialog() {
        
        let cancelAction = SOMDialogAction(
            title: Text.cancelActionTitle,
            style: .gray,
            action: {
                UIApplication.topViewController?.dismiss(animated: true)
            }
        )
        let settingAction = SOMDialogAction(
            title: Text.settingActionTitle,
            style: .primary,
            action: {
                let application = UIApplication.shared
                let openSettingsURLString: String = UIApplication.openSettingsURLString
                if let settingsURL = URL(string: openSettingsURLString),
                   application.canOpenURL(settingsURL) {
                    application.open(settingsURL)
                }
                
                UIApplication.topViewController?.dismiss(animated: true)
            }
        )
        
        SOMDialogViewController.show(
            title: Text.libraryDialogTitle,
            message: Text.libraryDialogMessage,
            actions: [cancelAction, settingAction]
        )
    }
    
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
            
            if let image = items.singlePhoto?.image, let reactor = self?.reactor {
                reactor.action.onNext(.uploadImage(image))
            } else {
                Log.error("Error occured while picking an image")
            }
            picker?.dismiss(animated: true, completion: nil)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.present(picker, animated: true, completion: nil)
        }
    }
}
