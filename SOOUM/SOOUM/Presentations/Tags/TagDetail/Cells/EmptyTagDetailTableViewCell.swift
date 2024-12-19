//
//  EmptyTagDetailTableViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 12/19/24.
//

import UIKit

class EmptyTagDetailTableViewCell: UITableViewCell {
  
  let stackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 12
  }
  
  let titleLabel = UILabel().then {
    $0.typography = .som.body1WithBold
    $0.textColor = .som.black
    $0.textAlignment = .center
  }
  
  let descLabel = UILabel().then {
    $0.typography = .som.body2WithBold
    $0.textColor = .som.gray500
    $0.textAlignment = .center
  }
  
  // MARK: - init
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none
    setupConstraint()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - setupConstraint
  private func setupConstraint() {
    contentView.addSubview(stackView)
    stackView.addArrangedSubviews(titleLabel, descLabel)
    stackView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
}
