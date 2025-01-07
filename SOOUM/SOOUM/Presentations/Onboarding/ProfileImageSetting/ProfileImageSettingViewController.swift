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
    
    let guideLabelView = OnboardingGuideLabelView().then {
        $0.titleLabel.text = "당신을 표현하는 사진을\n프로필로 등록해볼까요?"
        $0.descLabel.text = "프로필 사진은 추후 변경이 가능해요"
    }
    
    let profileImageSettingView = OnboardingProfileImageSettingView()
        
    let okButton = PrimaryButtonView().then {
        $0.updateState(state: false)
        $0.label.text = "확인"
    }
    
    let passButton = SOMButton().then {
        $0.title = "다음에 변경하기"
        $0.typography = .som.body3WithBold
        $0.foregroundColor = .som.p300
        $0.hasUnderlined = true
    }
     
    func bind(reactor: ProfileImageSettingViewReactor) {
        profileImageSettingView.rx.tapGesture()
            .when(.recognized)
            .subscribe(with: self) { object, _ in
                object.presentPicker()
            }
            .disposed(by: disposeBag)

        okButton.rx.tapGesture()
            .when(.recognized)
            .withUnretained(self)
            .compactMap { object, _ in
                object.okButton.isEnabled ? Reactor.Action.registerUser : nil
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        passButton.rx.tapGesture()
            .when(.recognized)
            .asObservable()
            .map { _ in
                Reactor.Action.registerUser
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state.map(\.shouldNavigate)
            .distinctUntilChanged()
            .subscribe(with: self) { object, shouldNavigate in
                let viewController = MainTabBarController()
                viewController.reactor = MainTabBarReactor(pushInfo: nil)
                let navigationController = UINavigationController(
                    rootViewController: viewController
                )
                object.view.window?.rootViewController = navigationController
            }
            .disposed(by: disposeBag)
        
        reactor.state.map(\.imageUploaded)
            .distinctUntilChanged()
            .subscribe(with: self) { object, imageUploaded in
                object.okButton.updateState(state: imageUploaded)
            }
            .disposed(by: disposeBag)
    }
    
    override func setupConstraints() {
        view.addSubview(guideLabelView)
        guideLabelView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(28)
        }
        
        view.addSubview(profileImageSettingView)
        profileImageSettingView.snp.makeConstraints {
            $0.top.equalTo(guideLabelView.snp.bottom).offset(94)
            $0.centerX.equalToSuperview()
        }
                
        view.addSubviews(passButton)
        passButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-24)
            $0.height.equalTo(17)
        }
        
        view.addSubview(okButton)
        okButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(passButton.snp.top).offset(-20)
        }
    }
 }

extension ProfileImageSettingViewController {
    func presentPicker() {
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
        picker.didFinishPicking { [weak self] items, _ in
            guard let self = self, let image = items.singlePhoto?.image  else {
                picker.dismiss(animated: true, completion: nil)
                return
            }
            self.profileImageSettingView.imageView.image = image
            if let reactor = self.reactor {
                reactor.action.onNext(.imageChanged(image: image))
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
}
