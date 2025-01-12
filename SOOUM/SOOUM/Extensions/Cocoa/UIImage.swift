//
//  UIImage.swift
//  SOOUM
//
//  Created by 오현식 on 12/12/24.
//

import UIKit


extension UIImage {
    
    func resized(_ size: CGSize, color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: CGRect(origin: .zero, size: size))
        
        color.setFill()
        UIRectFillUsingBlendMode(CGRect(origin: .zero, size: size), .sourceIn)

        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
