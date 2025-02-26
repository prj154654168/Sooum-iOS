//
//  SOMLocationFilter.swift
//  SOOUM
//
//  Created by JDeoks on 9/19/24.
//

import UIKit

import SnapKit
import Then

protocol SOMLocationFilterDelegate: AnyObject {
    
    func filter(
        _ filter: SOMLocationFilter,
        didSelectDistanceAt distance: SOMLocationFilter.Distance
    )
}

class SOMLocationFilter: UIView {
    
    enum Distance: String {
        case under1Km = "UNDER_1"
        case under5Km = "UNDER_5"
        case under10Km = "UNDER_10"
        case under20Km = "UNDER_20"
        case under50Km = "UNDER_50"
        
        var text: String {
            switch self {
            case .under1Km:
                "~ 1km"
            case .under5Km:
                "1km ~ 5km"
            case .under10Km:
                "5km ~ 10km"
            case .under20Km:
                "10km ~ 20km"
            case .under50Km:
                "20km ~ 50km"
            }
        }
    }
    
    static let height: CGFloat = 54
    
    ///  델리게이트
    weak var delegate: SOMLocationFilterDelegate?
    
    /// 거리 이넘 정보 들어있는 배열
    let distances: [Distance] = [.under1Km, .under5Km, .under10Km, .under20Km, .under50Km]
    
    /// 이전에 선택된 필터
    var prevDistance: Distance = .under1Km
    /// 현재 선택된 필터
    var selectedDistance: Distance = .under1Km
    
    /// 로케이션 필터 버튼 컬렉션 뷰
    let locationFilterCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.scrollDirection = .horizontal // 스크롤 방향을 가로로 설정
        }
    ).then {
        $0.backgroundColor = .clear
        $0.register(
            SOMLocationFilterCollectionViewCell.self,
            forCellWithReuseIdentifier: String(describing: SOMLocationFilterCollectionViewCell.self)
        )
    }
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - initUI
    private func initUI() {
        self.backgroundColor = .clear
        locationFilterCollectionView.showsHorizontalScrollIndicator = false
        addSubviews()
        initDelegate()
        initConstraint()
    }
    
    private func addSubviews() {
        self.addSubview(locationFilterCollectionView)
    }
    
    // MARK: - initDelegate
    private func initDelegate() {
        locationFilterCollectionView.dataSource = self
        locationFilterCollectionView.delegate = self
    }
    
    // MARK: - initConstraint
    private func initConstraint() {
        locationFilterCollectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}

// MARK: - UICollectionView
extension SOMLocationFilter: 
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout {
    
    // MARK: - DataSource
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return distances.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier:
                String(describing: SOMLocationFilterCollectionViewCell.self), 
            for: indexPath
        ) as! SOMLocationFilterCollectionViewCell
        
        let distance = distances[indexPath.item]
        let isSelected = distance == selectedDistance
        cell.setData(distance: distance, isSelected: isSelected)
        return cell
    }
    
    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /// 새로 선택된 거리 필터
        let newDistance = distances[indexPath.item]
        self.prevDistance = self.selectedDistance
        self.selectedDistance = newDistance
        self.locationFilterCollectionView.reloadData()
        self.delegate?.filter(self, didSelectDistanceAt: newDistance)
    }
    
    // MARK: - FlowLayout
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let label = UILabel().then {
            let distance = distances[indexPath.item]
            $0.typography = .som.body3WithRegular
            $0.text = distance.text
        }
        label.sizeToFit()
        return CGSize(width: label.bounds.width + 32, height: label.bounds.height + 24)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 8
    }
}
