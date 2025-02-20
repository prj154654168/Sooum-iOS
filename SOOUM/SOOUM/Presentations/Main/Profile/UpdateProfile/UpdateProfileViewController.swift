//
//  UpdateProfileViewController.swift
//  SOOUM
//
//  Created by 오현식 on 12/4/24.
//

import UIKit

import Kingfisher
import SnapKit
import Then
import YPImagePicker

import ReactorKit
import RxCocoa
import RxSwift


class UpdateProfileViewController: BaseNavigationViewController, View {
    
    enum Text {
        static let navigationTitle: String = "프로필 수정"
        static let textFieldPlaceholder: String = "8글자 이내 닉네임을 입력해주세요"
        static let completeButtonTitle: String = "완료"
    }
    
    private let updateProfileView = UpdateProfileView().then {
        $0.placeholder = Text.textFieldPlaceholder
    }
    
    private let completeButton = SOMButton().then {
        $0.title = Text.completeButtonTitle
        $0.typography = .som.body2WithBold
        $0.foregroundColor = .som.white
        
        $0.backgroundColor = .som.p300
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        
        $0.isEnabled = false
    }
    
    override var navigationBarHeight: CGFloat {
        46
    }
    
    
    // MARK: Override func
    
    override func setupNaviBar() {
        super.setupNaviBar()
        
        self.navigationBar.title = Text.navigationTitle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateProfileView.becomeFirstResponder()
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(self.updateProfileView)
        self.updateProfileView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
        }
        
        self.view.addSubview(self.completeButton)
        self.completeButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(48)
        }
    }
    
    override func updatedKeyboard(withoutBottomSafeInset height: CGFloat) {
        super.updatedKeyboard(withoutBottomSafeInset: height)
        
        let margin: CGFloat = height + 24
        self.completeButton.snp.updateConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-margin)
        }
    }
    
    
    // MARK: ReactorKit bind
    
    func bind(reactor: UpdateProfileViewReactor) {
        
        KingfisherManager.shared.download(strUrl: reactor.profile.profileImg?.url) { [weak self] image in
            self?.updateProfileView.image = image ?? .init(.image(.sooumLogo))
        }
        self.updateProfileView.text = reactor.profile.nickname
        
        // Action
        self.updateProfileView.changeProfileButton.rx.throttleTap(.seconds(3))
            .subscribe(with: self) { object, _ in
                object.showPicker(reactor)
            }
            .disposed(by: self.disposeBag)
        
        let nickname = self.updateProfileView.textField.rx.text.orEmpty.distinctUntilChanged()
        nickname
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .map(Reactor.Action.checkValidate)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.completeButton.rx.throttleTap(.seconds(3))
            .withLatestFrom(nickname)
            .map(Reactor.Action.updateProfile)
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        reactor.state.map(\.errorMessage)
            .distinctUntilChanged()
            .bind(to: self.updateProfileView.rx.errorMessage)
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isValid)
            .distinctUntilChanged()
            .subscribe(with: self) { object, isValid in
                object.completeButton.foregroundColor = isValid ? .som.white : .som.gray600
                object.completeButton.backgroundColor = isValid ? .som.p300 : .som.gray300
                object.completeButton.isEnabled = isValid
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isSuccess)
            .distinctUntilChanged()
            .subscribe(with: self) { object, _ in
                object.navigationPop()
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map(\.isProcessing)
            .distinctUntilChanged()
            .bind(to: self.activityIndicatorView.rx.isAnimating)
            .disposed(by: self.disposeBag)
    }
}

extension UpdateProfileViewController {
    
    private func showPicker(_ reactor: UpdateProfileViewReactor) {
        
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
                self.updateProfileView.image = image
                reactor.action.onNext(.updateImage(image))
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        self.present(picker, animated: true, completion: nil)
    }
}
