//
//  OnboardingProfileImageSettingViewController.swift
//  SOOUM
//
//  Created by JDeoks on 11/6/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift

import SnapKit
import SwiftEntryKit
import Then
import YPImagePicker


class OnboardingProfileImageSettingViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let navigationTitle: String = "회원가입"
        
        static let title: String = "숨에서 사용할 프로필 사진을\n등록해주세요"
        
        static let completeButtonTitle: String = "완료"
        static let passButtonTitle: String = "건너뛰기"
        
        static let inappositeDialogTitle: String = "부적절한 사진으로 보여져요"
        static let inappositeDialogMessage: String = "다른 사진으로 변경하거나 기본 이미지를 사용해 주세요."
        static let inappositeDialogConfirmButtonTitle: String = "확인"
        
        static let selectProfileEntryName: String = "selectProfile"
        
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
    
    private let guideMessageView = OnboardingGuideMessageView(title: Text.title, currentNumber: 3)
    
    private let profileImageView = UIImageView().then {
        $0.image = .init(.image(.v2(.profile_large)))
        // TODO: 임시, backgroundColor 넣어서 이미지 빈 곳 채움
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
        
    private let completeButton = SOMButton().then {
        $0.title = Text.completeButtonTitle
        $0.typography = .som.v2.title1
        $0.foregroundColor = .som.v2.white
        $0.backgroundColor = .som.v2.black
    }
    
    private let passButton = SOMButton().then {
        $0.title = Text.passButtonTitle
        $0.typography = .som.v2.title1
        $0.foregroundColor = .som.v2.gray600
        $0.backgroundColor = .som.v2.gray100
    }
    
    
    // MARK: Variables
    
    private var actions: [SelectProfileBottomFloatView.FloatAction] = []
    
    
    // MARK: Override func
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.guideMessageView)
        self.guideMessageView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        self.view.addSubview(self.profileImageView)
        self.profileImageView.snp.makeConstraints {
            $0.top.equalTo(self.guideMessageView.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(120)
        }
        self.view.addSubview(self.cameraButton)
        self.cameraButton.snp.makeConstraints {
            $0.bottom.equalTo(self.profileImageView.snp.bottom)
            $0.trailing.equalTo(self.profileImageView.snp.trailing)
            $0.size.equalTo(32)
        }
        
        let container = UIStackView(arrangedSubviews: [self.passButton, self.completeButton]).then {
            $0.axis = .horizontal
            $0.spacing = 10
        }
        self.view.addSubview(container)
        container.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-6)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(56)
        }
    }
    
    
    // MARK: ReactorKit - bind
     
    func bind(reactor: OnboardingProfileImageSettingViewReactor) {
        
        // Action
        Observable.merge(
            self.profileImageView.rx.tapGesture().when(.ended).map { _ in },
            self.cameraButton.rx.tap.asObservable()
        )
        .subscribe(with: self) { object, _ in
            let selectProfileBottomFloatView = SelectProfileBottomFloatView(actions: object.actions)
            
            var wrapper: SwiftEntryKitViewWrapper = selectProfileBottomFloatView.sek
            wrapper.entryName = Text.selectProfileEntryName
            wrapper.showBottomFloat(screenInteraction: .dismiss)
        }
        .disposed(by: self.disposeBag)

        self.completeButton.rx.tap
            .map { _ in Reactor.Action.signUp }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        self.passButton.rx.tap
            .map { _ in Reactor.Action.signUp }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        // State
        reactor.state.map(\.isSignUp)
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(with: self) { object, _ in
                let viewController = OnboardingCompletedViewController()
                viewController.reactor = reactor.reactorForCompleted()
                object.navigationPush(viewController, animated: true)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isLoading)
            .distinctUntilChanged()
            .subscribe(with: self.loadingIndicatorView) { loadingIndicatorView, isLoading in
                if isLoading {
                    loadingIndicatorView.startAnimating()
                } else {
                    loadingIndicatorView.stopAnimating()
                }
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.hasErrors)
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
                
                var actions: [SelectProfileBottomFloatView.FloatAction] = [
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
    }
 }

extension OnboardingProfileImageSettingViewController {
    
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
