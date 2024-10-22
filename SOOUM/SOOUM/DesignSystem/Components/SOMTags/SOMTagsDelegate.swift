//
//  SOMTagsDelegate.swift
//  SOOUM
//
//  Created by 오현식 on 10/19/24.
//

import Foundation


protocol SOMTagsDelegate: AnyObject {
    
    func tags(_ tags: SOMTags, didTouch model: SOMTagModel)
    func tags(_ tags: SOMTags, didRemove model: SOMTagModel)
}

extension SOMTagsDelegate {
    
    func tags(_ tags: SOMTags, didTouch model: SOMTagModel) { }
    func tags(_ tags: SOMTags, didRemove model: SOMTagModel) { }
}
