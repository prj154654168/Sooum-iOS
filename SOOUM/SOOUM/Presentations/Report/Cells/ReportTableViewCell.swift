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
        print("\(type(of: self)) - \(#function)")
        updateIsSelected(isSelected: selected, animated: true)
    }
    
    // MARK: - setData
    func setData(reason: ReportViewController.ReportType, isSelected: Bool) {
        reasonView.titleLabel.text = reason.title
        reasonView.descLabel.text = reason.description
        updateIsSelected(isSelected: isSelected, animated: false)
    }
    
    func updateIsSelected(isSelected: Bool, animated: Bool) {
        
        if animated {
            UIView.transition(with: reasonView.toggleView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.reasonView.toggleView.image = isSelected ? .radioFilled : .radioOutlined
            }, completion: nil)

            UIView.animate(withDuration: 0.3) {
                self.reasonView.rootContainerView.layer.borderColor = isSelected ? UIColor.som.blue600.cgColor : UIColor.som.gray04.cgColor
            }
        } else {
            reasonView.toggleView.image = isSelected ? .radioFilled : .radioOutlined
            reasonView.rootContainerView.layer.borderColor = isSelected ? UIColor.som.blue600.cgColor : UIColor.som.gray04.cgColor
        }
    }
    
    // MARK: - initUI
    private func initUI() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.clipsToBounds = true
        addSubviews()
        setupConstraints()
    }
    
    // MARK: - addSubviews
    private func addSubviews() {
        self.contentView.addSubview(reasonView)
    }
    
    // MARK: - setupConstraints
    private func setupConstraints() {
        reasonView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.bottom.equalToSuperview().offset(-6)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
}
