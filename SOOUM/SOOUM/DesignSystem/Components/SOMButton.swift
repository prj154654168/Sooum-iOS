//
//  SOMButton.swift
//  SOOUM
//
//  Created by 오현식 on 12/13/24.
//

import UIKit

class SOMButton: UIButton {
    
    var isDashedBorderEnabled: Bool = false {
        didSet {
            guard oldValue != self.isDashedBorderEnabled else { return }
            self.setNeedsLayout()
            self.setNeedsUpdateConfiguration()
        }
    }
    
    var title: String? {
        didSet {
            if oldValue != self.title {
                self.setNeedsUpdateConfiguration()
            }
        }
    }
    
    var typography: Typography? {
        didSet {
            if oldValue != self.typography {
                self.setNeedsUpdateConfiguration()
            }
        }
    }
    
    var hasUnderlined: Bool? {
        didSet {
            if oldValue != self.hasUnderlined {
                self.setNeedsUpdateConfiguration()
            }
        }
    }
    
    var inset: UIEdgeInsets? {
        didSet {
            if oldValue != self.inset {
                self.setNeedsUpdateConfiguration()
            }
        }
    }
    
    var image: UIImage? {
        didSet {
            if oldValue != self.image {
                self.setNeedsUpdateConfiguration()
            }
        }
    }
    
    var imagePlacement: NSDirectionalRectEdge? {
        didSet {
            if oldValue != self.imagePlacement {
                self.setNeedsUpdateConfiguration()
            }
        }
    }
    
    var foregroundColor: UIColor? {
        didSet {
            if oldValue != self.foregroundColor {
                self.setNeedsUpdateConfiguration()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setupConfiguration()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateDashedBorderIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SOMButton {
    
    var dashedBorderLayerName: String { "SOMButtonDashedBorderLayer" }
    
    func setupConfiguration() {
        
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = .zero
        
        self.configuration = configuration
        self.backgroundColor = .clear
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        self.configurationUpdateHandler = { [weak self] button in
            guard let self = self else { return }
            
            var updatedConfig = button.configuration
            
            updatedConfig?.background.backgroundColor = self.backgroundColor
            updatedConfig?.background.backgroundColorTransformer = UIConfigurationColorTransformer { _ in
                // 비활성화 상태일 때, backgroundColor
                if button.isEnabled == false {
                    switch self.backgroundColor {
                    case .som.v2.black:     return .som.v2.gray200
                    case .som.v2.gray100:   return .som.v2.gray200
                    case .som.v2.white:     return .som.v2.white
                    default:               return .clear
                    }
                }
                // 선택된 상태일 때, backgroundColor
                if button.isSelected { return .som.v2.pLight1 }
                // 하이라이트 상태일 때, backgroundColor
                if button.isHighlighted {
                    switch self.backgroundColor {
                    case .som.v2.black:     return .som.v2.gray600
                    case .som.v2.gray100:   return .som.v2.gray200
                    case .som.v2.white:     return .som.v2.gray100
                    case .som.v2.rMain:     return .som.v2.rDark
                    default:               return .clear
                    }
                }
                // 기본 상태일 때, backgroundColor
                return self.backgroundColor ?? .clear
            }
            
            updatedConfig?.background.strokeWidth = 1
            updatedConfig?.background.strokeColor = self.backgroundColor ?? .clear
            updatedConfig?.background.strokeColorTransformer = UIConfigurationColorTransformer { _ in
                // 비활성화 상태일 때, backgroundColor
                if button.isEnabled == false {
                    switch self.backgroundColor {
                    case .som.v2.black:     return .som.v2.gray200
                    case .som.v2.gray100:   return .som.v2.gray200
                    case .som.v2.white:     return .som.v2.white
                    default:               return .clear
                    }
                }
                // 선택된 상태일 때, backgroundColor
                if button.isSelected { return .som.v2.pMain }
                // 하이라이트 상태일 때, backgroundColor
                if button.isHighlighted {
                    switch self.backgroundColor {
                    case .som.v2.black:     return .som.v2.gray600
                    case .som.v2.gray100:   return .som.v2.gray200
                    case .som.v2.white:     return .som.v2.gray100
                    case .som.v2.rMain:     return .som.v2.rDark
                    default:               return .clear
                    }
                }
                // 기본 상태일 때, backgroundColor
                return self.backgroundColor ?? .clear
            }
            
            updatedConfig?.background.cornerRadius = 10
            updatedConfig?.background.strokeWidth = self.isDashedBorderEnabled ? 0 : 1
            
            self.applyConfiguration(to: &updatedConfig)
            button.configuration = updatedConfig
            self.updateDashedBorderIfNeeded()
        }
    }
    
    func applyConfiguration(to configuration: inout UIButton.Configuration?) {
        
        var foregroundColor: UIColor {
            if self.isEnabled == false {
                switch self.foregroundColor {
                case .som.v2.white:     return .som.v2.gray400
                case .som.v2.gray600:   return .som.v2.gray400
                case .som.v2.gray500:   return .som.v2.gray300
                default:               return .som.v2.gray300
                }
            }
            
            return self.foregroundColor ?? .som.v2.white
        }
        
        if let image = self.image {
            configuration?.image = image
            configuration?.imageColorTransformer = UIConfigurationColorTransformer { _ in foregroundColor }
            configuration?.imagePadding = 8
            configuration?.imagePlacement = self.imagePlacement ?? .leading
        }
        
        if let title = self.title, let typography = self.typography {
            var attributes = typography.attributes
            attributes.updateValue(typography.font, forKey: .font)
            attributes.updateValue(foregroundColor, forKey: .foregroundColor)
            
            if self.hasUnderlined == true {
                attributes.updateValue(NSUnderlineStyle.single.rawValue, forKey: .underlineStyle)
                attributes.updateValue(foregroundColor, forKey: .underlineColor)
            }
            
            if let inset = self.inset {
                configuration?.contentInsets = .init(
                    top: inset.top,
                    leading: inset.left,
                    bottom: inset.bottom,
                    trailing: inset.right
                )
            }
            
            configuration?.attributedTitle = .init(title, attributes: AttributeContainer(attributes))
            configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { _ in
                AttributeContainer(attributes)
            }
        }
    }
    
    func updateDashedBorderIfNeeded() {
        self.removeDashedBorderLayerIfNeeded()
        
        guard self.isDashedBorderEnabled, self.bounds.isEmpty == false else { return }
        
        let borderLayer = CAShapeLayer()
        borderLayer.name = self.dashedBorderLayerName
        borderLayer.frame = self.bounds
        borderLayer.path = UIBezierPath(
            roundedRect: self.bounds,
            cornerRadius: self.layer.cornerRadius
        ).cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.som.v2.gray300.cgColor
        borderLayer.lineWidth = 1
        borderLayer.lineDashPattern = [3, 3]
        
        self.layer.addSublayer(borderLayer)
    }
    
    func removeDashedBorderLayerIfNeeded() {
        self.layer.sublayers?
            .filter { $0.name == self.dashedBorderLayerName }
            .forEach { $0.removeFromSuperlayer() }
    }
}
