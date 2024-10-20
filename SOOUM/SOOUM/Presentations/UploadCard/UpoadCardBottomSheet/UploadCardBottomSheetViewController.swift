//
//  UploadCardBottomSheetViewController.swift
//  SOOUM
//
//  Created by JDeoks on 10/16/24.
//

import UIKit

import ReactorKit
import RxGesture
import RxSwift

import SnapKit
import Then

class UploadCardBottomSheetViewController: UIViewController {
    
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
    
    var segmentState = BottomSheetSegmentTableViewCell.ImageSegment.defaultImage
    
    lazy var tableView = UITableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .clear
        $0.indicatorStyle = .black
        $0.separatorStyle = .none
        
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
    
    func setupConstraints() {
//        self.view.addSubview(segmentView)
//        segmentView.snp.makeConstraints {
//            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
//            $0.leading.equalToSuperview().offset(8)
//            $0.trailing.equalToSuperview().offset(-14)
//            $0.height.equalTo(32)
//        }
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
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
            switch segmentState {
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
        cell.setData(segmentState: segmentState)
        cell.imageSegmentChanged
            .subscribe { segment in
                self.segmentState = segment
                self.tableView.reloadSections(IndexSet([1, 2, 3]), with: .automatic)
            }
            .disposed(by: cell.disposeBag)
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
        cell.setData()
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
        
        cell.setData(settingOption: Section.OtherSettings.allCases[indexPath.item], state: false)
        return cell
    }
}
