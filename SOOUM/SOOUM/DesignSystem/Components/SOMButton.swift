//
//  SOMButton.swift
//  SOOUM
//
//  Created by 오현식 on 12/13/24.
//

import UIKit

class SOMButton: UIButton {
    
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SOMButton {
    
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
                if button.isEnabled == false { return .som.v2.gray200 }
                // 선택된 상태일 때, backgroundColor
                if button.isSelected { return .som.v2.pLight1 }
                // 하이라이트 상태일 때, backgroundColor
                if button.isHighlighted {
                    switch self.backgroundColor {
                    case .som.v2.black:     return .som.v2.gray600
                    case .som.v2.gray100:   return .som.v2.gray200
                    case .som.v2.white:     return .som.v2.gray100
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
                if button.isEnabled == false { return .som.v2.gray200 }
                // 선택된 상태일 때, backgroundColor
                if button.isSelected { return .som.v2.pMain }
                // 하이라이트 상태일 때, backgroundColor
                if button.isHighlighted {
                    switch self.backgroundColor {
                    case .som.v2.black:     return .som.v2.gray600
                    case .som.v2.gray100:   return .som.v2.gray200
                    case .som.v2.white:     return .som.v2.gray100
                    default:               return .clear
                    }
                }
                // 기본 상태일 때, backgroundColor
                return self.backgroundColor ?? .clear
            }
            
            updatedConfig?.background.cornerRadius = 10
            
            self.applyConfiguration(to: &updatedConfig)
            button.configuration = updatedConfig
        }
    }
    
    func applyConfiguration(to configuration: inout UIButton.Configuration?) {
        
        var foregroundColor: UIColor {
            return self.isEnabled ? (self.foregroundColor ?? .som.v2.white) : .som.v2.gray400
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
}
