//
//  UploadCardBottomSheetViewController.swift
//  SOOUM
//
//  Created by JDeoks on 10/16/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift

import SnapKit
import Then
import YPImagePicker

class UploadCardBottomSheetViewController: BaseViewController, View {    
    
    enum Section: CaseIterable {
        case imageSegment
        case selectImage
        case selectFont
        case otherSettings
        
        enum OtherSettings: CaseIterable {
            case timeLimit
            case distanceLimit
            case privateCard
            
            var title: String {
                switch self {
                case .timeLimit: return "시간 제한"
                case .distanceLimit: return "거리 공유 제한"
                case .privateCard: return "나만 보기"
                }
            }
            
            var description: String {
                switch self {
                case .timeLimit: return "태그를 사용할 수 없고, 24시간 뒤 모든 카드가 삭제돼요"
                case .distanceLimit: return "다른 사람이 거리 정보를 알 수 없어요"
                case .privateCard: return ""
                }
            }
        }
    }
    
    /// 기본 서버 이미지 배열
    var defaultImages: [ImageWithName] = []
    
    /// 선택된 사용자 이미지 ->  bottomSheetImageSelected 로 부모 뷰컨에 전달
    var selectedMyImage = BehaviorRelay<ImageWithName?>(value: nil)
    /// 선택된 기본 이미지 -> bottomSheetImageSelected 로 부모 뷰컨에 전달
    var selectedDefaultImage = BehaviorRelay<(idx: Int, imageWithName: ImageWithName?)>(value: (idx: 0, imageWithName: nil))
    /// 기본이미지&내 이미지 토글
    var imageModeSegmentState = BehaviorRelay<BottomSheetSegmentTableViewCell.ImageSegment>(value: .defaultImage)
   
    //  부모 뷰컨에 전달할 이벤트
    /// 선택한 폰트
    var bottomSheetFontState = BehaviorRelay<SelectFontTableViewCell.FontType>(value: .gothic)
    /// 선택된 이미지 방출
    var bottomSheetImageSelected = PublishRelay<UIImage>()
    /// 이미지 이름 방출
    var bottomSheetImageNameSeleted = PublishRelay<String>()
    /// 바텀싯 옵션 변경 방출
    var bottomSheetOptionState = BehaviorRelay<[Section.OtherSettings: Bool]>(
        value: [
            .timeLimit: false,
            .distanceLimit: false,
            .privateCard: false
        ]
    )
    
    /// 방출시 이미지 피커 띄움
    var sholdShowImagePicker = PublishSubject<Void>()
    /// 이미지 재설정 버튼 클릭 이벤트
    let imageReloadButtonTapped = PublishSubject<BottomSheetSegmentTableViewCell.ImageSegment>()
    
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .clear
        $0.indicatorStyle = .black
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.register(
            BottomSheetSegmentTableViewCell.self,
            forCellReuseIdentifier: String(describing: BottomSheetSegmentTableViewCell.self)
        )
        $0.register(
            SelectDefaultImageTableViewCell.self,
            forCellReuseIdentifier: String(describing: SelectDefaultImageTableViewCell.self)
        )
        $0.register(
            SelectMyImageTableViewCell.self,
            forCellReuseIdentifier: String(describing: SelectMyImageTableViewCell.self)
        )
        $0.register(
            SelectFontTableViewCell.self,
            forCellReuseIdentifier: String(describing: SelectFontTableViewCell.self)
        )
        $0.register(
            UploadCardSettingTableViewCell.self,
            forCellReuseIdentifier: String(describing: UploadCardSettingTableViewCell.self)
        )
        
        $0.dataSource = self
        $0.delegate = self
    }
    
    override func viewDidLoad() {
        print("\(type(of: self)) - \(#function)")

        setupConstraints()
    }
    
    override func setupConstraints() {
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind(reactor: UploadCardBottomSheetViewReactor) {
        self.rx.viewDidLoad
            .map({ _ in
                print(" Reactor.Action.fetchNewDefaultImage")
                return Reactor.Action.fetchNewDefaultImage
            })
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        sholdShowImagePicker
            .subscribe(with: self) { object, _ in
                object.presentPicker()
            }
            .disposed(by: self.disposeBag)
        
        imageModeSegmentState
            .subscribe { segment in
                self.tableView.reloadSections(IndexSet([1]), with: .automatic)
                switch segment {
                case .defaultImage:
                    self.bottomSheetImageNameSeleted.accept(self.selectedDefaultImage.value.imageWithName?.name ?? "")
                    self.bottomSheetImageSelected.accept(self.selectedDefaultImage.value.imageWithName?.image ?? .init())
                case .myImage:
                    if let selectedMyImage = self.selectedMyImage.value {
                        self.bottomSheetImageNameSeleted.accept(selectedMyImage.name)
                        self.bottomSheetImageSelected.accept(selectedMyImage.image)
                    }
                }
            }
            .disposed(by: self.disposeBag)
        
        selectedDefaultImage
            .compactMap {
//                print("selectedDefaultImage 변경")
                return $0.imageWithName?.image
            }
            .bind(to: bottomSheetImageSelected)
            .disposed(by: self.disposeBag)
        
        selectedDefaultImage
            .compactMap {
//                print("imageNameSeleted 변경", $0.imageWithName?.name)
                return $0.imageWithName?.name
            }
            .bind(to: bottomSheetImageNameSeleted)
            .disposed(by: self.disposeBag)
        
        imageReloadButtonTapped
            .filter { $0 == .defaultImage }
            .map { _ in Reactor.Action.fetchNewDefaultImage }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        selectedMyImage
            .subscribe(with: self, onNext: { object, imageWithName in
                if let name = imageWithName?.name {
                    object.bottomSheetImageNameSeleted.accept(name)
                }
            })
            .disposed(by: self.disposeBag)
        
        // TODO: 삭제
        bottomSheetImageSelected.subscribe { font in
            print("⭕️ 바텀시트 이미지 변경", font)
        }
        .disposed(by: self.disposeBag)
        
        // TODO: 삭제
        bottomSheetImageNameSeleted.subscribe { font in
            print("⭕️ 바텀시트 이미지 이름 변경", font)
        }
        .disposed(by: self.disposeBag)
        
        // TODO: 삭제
        bottomSheetFontState.subscribe { font in
            print("⭕️ 바텀시트 폰트 변경", font)
        }
        .disposed(by: self.disposeBag)
        
        // TODO: 삭제
        bottomSheetOptionState.subscribe(with: self) { object, state in
            print("⭕️ 바텀시트 옵션 변경")
        }
        .disposed(by: self.disposeBag)
        
        // MARK: - state
        reactor.state.map(\.defaultImages)
            .subscribe(with: self) { object, imageWithNames in
                let idx = object.selectedDefaultImage.value.idx
                if imageWithNames.indices.contains(idx) {
                    object.selectedDefaultImage.accept((idx: idx, imageWithName: imageWithNames[idx]))
                }
                object.defaultImages = imageWithNames
                object.tableView.reloadSections(IndexSet([1]), with: .automatic)
            }
            .disposed(by: self.disposeBag)

        reactor.state.map(\.myImageName)
            .subscribe(with: self) { object, imageName in
                if let imageName = imageName, !imageName.isEmpty {
                    if let image = object.selectedMyImage.value?.image {
                        object.selectedMyImage.accept(.init(name: imageName, image: image))
                    }
                } else {
                    return
                }
            }
            .disposed(by: self.disposeBag)
    }
}

// MARK: - UITableVie
extension UploadCardBottomSheetViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section.allCases[section] {
        case .imageSegment, .selectImage, .selectFont:
            1
            
        case .otherSettings:
            Section.OtherSettings.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section.allCases[indexPath.section] {
        case .imageSegment:
            return createBottomSheetSegmentTableViewCell(indexPath: indexPath)
            
        case .selectImage:
            switch imageModeSegmentState.value {
            case .defaultImage:
                return createSelectDefaultImageTableViewCell(indexPath: indexPath)
            case .myImage:
                return createSelectMyImageTableViewCell(indexPath: indexPath)
            }
            
        case .selectFont:
            return createSelectFontTableViewCell(indexPath: indexPath)
            
        case .otherSettings:
            return createUploadCardSettingTableViewCell(indexPath: indexPath)
        }
    }
    
    private func createBottomSheetSegmentTableViewCell(indexPath: IndexPath) -> BottomSheetSegmentTableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier:
                String(
                    describing: BottomSheetSegmentTableViewCell.self
                ),
            for: indexPath
        ) as! BottomSheetSegmentTableViewCell
        cell.setData(imageModeSegmentState: imageModeSegmentState, imageReloadButtonTapped: imageReloadButtonTapped)
        return cell
    }
    
    private func createSelectDefaultImageTableViewCell(indexPath: IndexPath) -> SelectDefaultImageTableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier:
                String(
                    describing: SelectDefaultImageTableViewCell.self
                ),
            for: indexPath
        ) as! SelectDefaultImageTableViewCell
        cell.setData(imageWithNames: defaultImages, selectedDefaultImage: selectedDefaultImage)
        return cell
    }
    
    private func createSelectMyImageTableViewCell(indexPath: IndexPath) -> SelectMyImageTableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier:
                String(
                    describing: SelectMyImageTableViewCell.self
                ),
            for: indexPath
        ) as! SelectMyImageTableViewCell
        cell.setData(image: self.selectedMyImage.value?.image, sholdShowImagePicker: sholdShowImagePicker)
        return cell
    }
    
    private func createSelectFontTableViewCell(indexPath: IndexPath) -> SelectFontTableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier:
                String(
                    describing: SelectFontTableViewCell.self
                ),
            for: indexPath
        ) as! SelectFontTableViewCell
        cell.setData(selectedFont: self.bottomSheetFontState)
        return cell
    }
    
    private func createUploadCardSettingTableViewCell(indexPath: IndexPath) -> UploadCardSettingTableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier:
                String(
                    describing: UploadCardSettingTableViewCell.self
                ),
            for: indexPath
        ) as! UploadCardSettingTableViewCell
        cell.setData(cellOption: Section.OtherSettings.allCases[indexPath.item], globalCardOptionState: bottomSheetOptionState)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch Section.allCases[indexPath.section] {
        case .imageSegment:
            return UITableView.automaticDimension

        case .selectImage:
            switch self.imageModeSegmentState.value {
            case .defaultImage:
                return ((UIScreen.main.bounds.width - 40) / 2) + 28
            case .myImage:
                return UITableView.automaticDimension
            }

        case .selectFont:
            return UITableView.automaticDimension

        case .otherSettings:
            return 56
        }
    }
}

// MARK: - YPImagePicker
extension UploadCardBottomSheetViewController {
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
        config.showsCrop = .rectangle(ratio: 10 / 9)
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
        picker.didFinishPicking { [unowned picker] items, _ in
            guard let image = items.singlePhoto?.image  else {
                picker.dismiss(animated: true, completion: nil)
                return
            }
            self.selectedMyImage.accept(.init(name: "", image: image))
            picker.dismiss(animated: true, completion: nil)
            // 이미지 업로드
            if let reactor = self.reactor {
                reactor.action.onNext(.seleteMyImage(image))
            }
            self.tableView.reloadSections(IndexSet([1]), with: .automatic)
        }
        present(picker, animated: true, completion: nil)
    }
}
