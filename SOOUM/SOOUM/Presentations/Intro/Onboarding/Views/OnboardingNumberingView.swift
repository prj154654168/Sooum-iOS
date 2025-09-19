//
//  OnboardingNumberingView.swift
//  SOOUM
//
//  Created by 오현식 on 9/11/25.
//

import UIKit

import SnapKit
import Then

class OnboardingNumberingView: UIView {
    
    enum Color {
        static let selectedBackgroundColor: UIColor = .som.v2.pMain
        static let selectedBorderColor: UIColor = .som.v2.pLight2
        static let defaultBackgroundColor: UIColor = .som.v2.gray300
        static let defaultBorderColor: UIColor = .som.v2.gray200
    }
    
    
    // MARK: Views
    
    private let container = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
    }
    
    
    // MARK: Variables
    
    var currentNumber: Int? {
        willSet {
            self.container.subviews.forEach { view in
                if view.tag <= newValue ?? 1 {
                    view.backgroundColor = Color.selectedBackgroundColor
                    view.layer.borderColor = Color.selectedBorderColor.cgColor
                }
            }
        }
    }
    
    
    // MARK: Initalization
    
    convenience init(numbers: [Int]) {
        self.init(frame: .zero)
        
        self.setupNumberView(numbers: numbers)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension OnboardingNumberingView {
    
    func setupConstraints() {
        
        self.addSubview(self.container)
        self.container.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setupNumberView(numbers: [Int]) {
        
        numbers.forEach { number in
            
            let backgroundView = UIView().then {
                $0.backgroundColor = Color.defaultBackgroundColor
                $0.layer.borderColor = Color.defaultBorderColor.cgColor
                $0.layer.borderWidth = 1
                $0.layer.cornerRadius = 32 * 0.5
                $0.tag = number
            }
            
            let label = UILabel().then {
                $0.text = "\(number)"
                $0.textColor = .white
                $0.typography = .som.v2.subtitle2
            }
            
            backgroundView.addSubview(label)
            label.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
            
            backgroundView.snp.makeConstraints {
                $0.size.equalTo(32)
            }
            
            self.container.addArrangedSubview(backgroundView)
        }
    }
}
