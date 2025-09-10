//
//  ProfileImageSettingViewController.swift
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
import Then
import YPImagePicker

class ProfileImageSettingViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let title: String = "당신을 표현하는 사진을\n프로필로 등록해볼까요?"
        static let message: String = "프로필 사진은 추후 변경이 가능해요"
        
        static let confirmButtonTitle: String = "확인"
        static let passButtonTitle: String = "다음에 변경하기"
    }
    
    
    // MARK: Views
    
    private let guideMessageView = OnboardingGuideMessageView(title: Text.title, message: Text.message)
    
    private let profileImageView = UIImageView().then {
        $0.image = .init(.image(.defaultStyle(.sooumLogo)))
        $0.layer.cornerRadius = 128 * 0.5
        $0.clipsToBounds = true
    }
    private let cameraButton = SOMButton().then {
        $0.image = .init(.icon(.outlined(.camera)))
        $0.foregroundColor = .som.white
        
        $0.backgroundColor = .som.gray400
        $0.layer.cornerRadius = 32 * 0.5
        $0.clipsToBounds = true
    }
        
    private let confirmButton = SOMButton().then {
        $0.title = Text.confirmButtonTitle
        $0.typography = .som.body1WithBold
        $0.foregroundColor = .som.gray600
        
        $0.backgroundColor = .som.gray300
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    private let passButton = SOMButton().then {
        $0.title = Text.passButtonTitle
        $0.typography = .som.body3WithBold
        $0.foregroundColor = .som.p300
        $0.hasUnderlined = true
    }
    
    
    // MARK: Override func
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.guideMessageView)
        self.guideMessageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(28)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        self.view.addSubview(self.profileImageView)
        self.profileImageView.snp.makeConstraints {
            $0.top.equalTo(self.guideMessageView.snp.bottom).offset(94)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(128)
        }
        self.view.addSubview(self.cameraButton)
        self.cameraButton.snp.makeConstraints {
            $0.bottom.equalTo(self.profileImageView.snp.bottom).offset(-4)
            $0.trailing.equalTo(self.profileImageView.snp.trailing).offset(-4)
            $0.size.equalTo(32)
        }
                
        self.view.addSubviews(self.passButton)
        self.passButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-12)
            $0.centerX.equalToSuperview()
        }
        
        self.view.addSubview(self.confirmButton)
        self.confirmButton.snp.makeConstraints {
            $0.bottom.equalTo(passButton.snp.top).offset(-20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(48)
        }
    }
    
    
    // MARK: ReactorKit - bind
     
    func bind(reactor: ProfileImageSettingViewReactor) {
        
        // Action
        self.cameraButton.rx.tap
            .subscribe(with: self) { object, _ in
                object.showPicker()
            }
            .disposed(by: self.disposeBag)

        self.confirmButton.rx.tap
            .map { _ in Reactor.Action.updateProfile }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        self.passButton.rx.tap
            .map { _ in Reactor.Action.updateProfile }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // State
        reactor.state.map(\.isSuccess)
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(with: self) { object, _ in
                let viewController = MainTabBarController()
                viewController.reactor = reactor.reactorForMainTabBar()
                let navigationController = UINavigationController(
                    rootViewController: viewController
                )
                object.view.window?.rootViewController = navigationController
            }
            .disposed(by: disposeBag)
        
        reactor.state.map(\.profileImage)
            .map { $0 != nil }
            .distinctUntilChanged()
            .subscribe(with: self) { object, isUpdated in
                object.confirmButton.isEnabled = isUpdated
                object.confirmButton.foregroundColor = isUpdated ? .som.white : .som.gray600
                object.confirmButton.backgroundColor = isUpdated ? .som.p300 : .som.gray300
            }
            .disposed(by: disposeBag)
    }
 }

extension ProfileImageSettingViewController {
    func showPicker() {
        var config = YPImagePickerConfiguration()
        
        config.library.options = nil
        config.library.onlySquare = false
        config.library.isSquareByDefault = true
        config.library.minWidthForItem = nil
        config.library.mediaType = YPlibraryMediaType.photo
        config.library.defaultMultipleSelection = false
        config.library.maxNumberOfItems = 1
        config.library.minNumberOfItems = 1
        config.library.numberOfItemsInRow = 4
        config.library.spacingBetweenItems = 1.0
        config.showsCrop = .rectangle(ratio: 1)
        config.showsPhotoFilters = false
        config.library.skipSelectionsGallery = false
        config.library.preselectedItems = nil
        config.library.preSelectItemOnMultipleSelection = true
        config.startOnScreen = .library
        config.shouldSaveNewPicturesToAlbum = false
        
        config.wordings.next = "다음"
        config.wordings.cancel = "취소"
        config.wordings.save = "저장"
        config.wordings.albumsTitle = "앨범"
        config.wordings.cameraTitle = "카메라"
        config.wordings.libraryTitle = "갤러리"
        config.wordings.crop = "자르기"
        
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [weak self] items, cancelled in
            
            guard let self = self, let reactor = self.reactor else { return }
            
            if cancelled {
                Log.error("Picker was canceled")
                picker.dismiss(animated: true, completion: nil)
                return
            }
            
            if let image = items.singlePhoto?.image {
                self.profileImageView.image = image
                reactor.action.onNext(.updateImage(image))
            }
            picker.dismiss(animated: true, completion: nil)
        }
        self.present(picker, animated: true, completion: nil)
    }
}
