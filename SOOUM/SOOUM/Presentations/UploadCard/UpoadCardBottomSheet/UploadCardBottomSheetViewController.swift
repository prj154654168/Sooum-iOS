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
    
    /// 기본 서버 이미지
    var defaultImages: [ImageURLWithName] = []
    /// 사용자가 선택한 사진, 모드
    var selectedImage: (image: UIImage, segment: BottomSheetSegmentTableViewCell.ImageSegment)?
    
    /// 선택된 기본 이미지
    var selectedDefaultImage = BehaviorRelay<(idx: Int, imageWithName: ImageURLWithName?)>(value: (idx: 0, imageWithName: nil))
    /// 선택한 폰트
    var selectedFont = BehaviorRelay<SelectFontTableViewCell.FontType>(value: .gothic)
    /// 이미지 피커 띄우기 이벤트
    var sholdShowImagePicker = PublishSubject<Void>()
    /// 기본이미지&내 이미지 토글
    var segmentState = BehaviorRelay<BottomSheetSegmentTableViewCell.ImageSegment>(value: .defaultImage)
   
    // 이전 뷰컨에 전달할 이벤트
    /// 선택된 이미지 url을 방출
    var imageSelected = PublishRelay<String>()
    /// 이미지 이름 방출
    var imageNameSeleted = PublishRelay<String>()
    /// 카드 옵션 변경 방출
    var cardOptionState = BehaviorRelay<[Section.OtherSettings: Bool]>(
        value: [
            .timeLimit: false,
            .distanceLimit: false,
            .privateCard: false
        ]
    )
    
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
        
        segmentState
            .subscribe { segment in
                self.tableView.reloadSections(IndexSet([1, 2, 3]), with: .automatic)
            }
            .disposed(by: self.disposeBag)
        
        selectedDefaultImage
            .compactMap {
                print("imageSelected 변경", $0.imageWithName?.urlString)
                return $0.imageWithName?.urlString
            }
            .bind(to: imageSelected)
            .disposed(by: self.disposeBag)
        
        selectedDefaultImage
            .compactMap {
                print("imageNameSeleted 변경", $0.imageWithName?.name)
                return $0.imageWithName?.name
            }
            .bind(to: imageNameSeleted)
            .disposed(by: self.disposeBag)
        
        imageReloadButtonTapped
            .filter { $0 == .defaultImage }
            .map { _ in Reactor.Action.fetchNewDefaultImage }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // TODO: 삭제
        selectedFont.subscribe { font in
            print("selectedFont 변경", font)
        }
        .disposed(by: self.disposeBag)
        
        cardOptionState.subscribe(with: self) { object, state in
            print("토글 바뀜", state)
        }
        .disposed(by: self.disposeBag)
        
        reactor.state.map(\.defaultImages)
            .subscribe(with: self) { object, imageWithNames in
                object.defaultImages = imageWithNames
                object.tableView.reloadSections(IndexSet([1]), with: .automatic)
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
            switch segmentState.value {
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
        cell.setData(segmentState: segmentState, imageReloadButtonTapped: imageReloadButtonTapped)
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
        cell.setData(image: self.selectedImage?.image, sholdShowImagePicker: sholdShowImagePicker)
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
        cell.setData(selectedFont: self.selectedFont)
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
        cell.setData(cellOption: Section.OtherSettings.allCases[indexPath.item], settingState: cardOptionState)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch Section.allCases[indexPath.section] {
        case .imageSegment:
            return UITableView.automaticDimension

        case .selectImage:
            switch self.segmentState.value {
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
            self.selectedImage = (image, self.segmentState.value)
            picker.dismiss(animated: true, completion: nil)
            self.tableView.reloadSections(IndexSet([1]), with: .automatic)
        }
        present(picker, animated: true, completion: nil)
    }
}
