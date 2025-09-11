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
    
    var image: UIImage? {
        didSet {
            if oldValue != self.image {
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
    
    var foregroundColor: UIColor? {
        didSet {
            if oldValue != self.foregroundColor {
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
            
            updatedConfig?.background.backgroundColor = button.isHighlighted ? .som.v2.gray600 : (self.backgroundColor ?? .clear)
            updatedConfig?.background.backgroundColorTransformer = UIConfigurationColorTransformer { _ in
                // 비활성화 상태일 때, backgroundColor
                if button.isEnabled == false {
                    return .som.v2.gray200
                }
                // 하이라이트 상태일 때, backgroundColor
                if button.isHighlighted {
                    return self.hasUnderlined == true ? .som.v2.gray100 : .som.v2.gray600
                }
                // 기본 상태일 때, backgroundColor
                return self.backgroundColor ?? .clear
            }
            
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
        }
        
        if let title = self.title, let typography = self.typography {
            var attributes = typography.attributes
            attributes.updateValue(typography.font, forKey: .font)
            attributes.updateValue(foregroundColor, forKey: .foregroundColor)
            
            if self.hasUnderlined == true {
                attributes.updateValue(NSUnderlineStyle.single.rawValue, forKey: .underlineStyle)
                attributes.updateValue(foregroundColor, forKey: .underlineColor)
                
                configuration?.contentInsets = .init(top: 6, leading: 16, bottom: 6, trailing: 16)
            }
            
            configuration?.attributedTitle = .init(title, attributes: AttributeContainer(attributes))
            configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { _ in
                AttributeContainer(attributes)
            }
        }
        
        if image == nil {
            configuration?.titleAlignment = .center
        } else {
            configuration?.imagePadding = 8
        }
    }
}
