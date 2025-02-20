//
//  ReportTableViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 10/14/24.
//

import UIKit

import RxSwift
import SnapKit
import Then

class ReportTableViewCell: UITableViewCell {
    
    let reasonView = ReportReasonView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        updateIsSelected(isSelected: selected, animated: true)
    }
    
    // MARK: - setData
    func setData(reason: ReportViewReactor.ReportType, isSelected: Bool) {
        reasonView.titleLabel.text = reason.title
        reasonView.descLabel.text = reason.description
        updateIsSelected(isSelected: isSelected, animated: false)
    }
    
    func updateIsSelected(isSelected: Bool, animated: Bool) {
        let color: UIColor = isSelected ? .som.p300 : .som.gray300
        let toggleImage: UIImage? = isSelected ? .init(.icon(.filled(.radio))) : .init(.icon(.outlined(.radio)))
        let durationTime: TimeInterval = 0.3
        if animated {
            UIView.transition(
                with: reasonView.toggleView,
                duration: durationTime,
                options: .transitionCrossDissolve,
                animations: { [weak self] in
                    self?.reasonView.toggleView.image = toggleImage
                    self?.reasonView.toggleView.tintColor = color
                },
                completion: nil
            )
            
            UIView.animate(withDuration: durationTime) { [weak self] in
                self?.reasonView.rootContainerView.layer.borderColor = color.cgColor
            }
        } else {
            reasonView.toggleView.image = toggleImage
            reasonView.toggleView.tintColor = color
            reasonView.rootContainerView.layer.borderColor = color.cgColor
        }
    }
    
    // MARK: - initUI
    private func initUI() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.clipsToBounds = true
        setupConstraints()
    }
    
    // MARK: - setupConstraints
    private func setupConstraints() {
        self.contentView.addSubview(reasonView)
        reasonView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.bottom.equalToSuperview().offset(-6)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
}
