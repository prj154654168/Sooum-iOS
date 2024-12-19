//
//  EmptyTagDetailTableViewCell.swift
//  SOOUM
//
//  Created by JDeoks on 12/19/24.
//

import UIKit

class EmptyTagDetailTableViewCell: UITableViewCell {
  
  enum Mode {
    case noCardsCanView
    case noCardsRegistered
    
    var title: String {
      switch self {
      case .noCardsCanView:
        "조회할 수 있는 카드가 없어요"
      case .noCardsRegistered:
        "등록된 카드가 없어요"
      }
    }
    
    var desc: String {
      switch self {
      case .noCardsCanView:
        "차단된 사용자의 카드는\n확인할 수 없어요"
      case .noCardsRegistered:
        "해당 태그를 사용한\n카드가 없어요"
      }
    }
  }
  
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
  
  func setData(mode: Mode) {
    titleLabel.text = mode.title
    descLabel.text = mode.desc
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
