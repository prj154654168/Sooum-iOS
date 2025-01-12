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
                self.setConfiguration()
            }
        }
    }
    
    var image: UIImage? {
        didSet {
            if oldValue != self.image {
                self.setConfiguration()
            }
        }
    }
    
    var typography: Typography? {
        didSet {
            if oldValue != self.typography {
                self.setConfiguration()
            }
        }
    }
    
    var foregroundColor: UIColor? {
        didSet {
            if oldValue != self.foregroundColor {
                self.setConfiguration()
            }
        }
    }
    
    var hasUnderlined: Bool? {
        didSet {
            if oldValue != self.hasUnderlined {
                self.setConfiguration()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConfiguration() {
        
        var configuration = UIButton.Configuration.plain()
        
        // 이미지 설정
        if let image = self.image {
            configuration.image = image
            
            if let foregroundColor = self.foregroundColor {
                configuration.image?.withTintColor(foregroundColor)
                configuration.imageColorTransformer = UIConfigurationColorTransformer { _ in
                    foregroundColor
                }
            }
        }
        
        // 타이틀 설정
        if let title = self.title, let typography = self.typography {
            var attributes = typography.attributes
            attributes.updateValue(typography.font, forKey: .font)
            
            if let foregroundColor = self.foregroundColor {
                attributes.updateValue(foregroundColor, forKey: .foregroundColor)
            }
            
            if self.hasUnderlined == true {
                attributes.updateValue(NSUnderlineStyle.single.rawValue, forKey: .underlineStyle)
                attributes.updateValue(foregroundColor ?? UIColor.som.gray400, forKey: .underlineColor)
            }
            
            configuration.attributedTitle = .init(title, attributes: AttributeContainer(attributes))
            configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { _ in
                AttributeContainer(attributes)
            }
            
            if image == nil {
                configuration.titleAlignment = .center
            } else {
                configuration.imagePadding = 2
            }
        }
        
        if self.backgroundColor == nil {
            self.backgroundColor = .clear
            
            configuration.contentInsets = .zero
        }
        
        self.configuration = configuration
    }
}
