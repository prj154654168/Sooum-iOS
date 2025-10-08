//
//  SOMPageViewsDelegate.swift
//  SOOUM
//
//  Created by 오현식 on 10/2/25.
//

import Foundation

protocol SOMPageViewsDelegate: AnyObject {
    
    func pages(_ tags: SOMPageViews, didTouch model: SOMPageModel)
}

extension SOMPageViewsDelegate {
    
    func pages(_ tags: SOMPageViews, didTouch model: SOMPageModel) { }
}
