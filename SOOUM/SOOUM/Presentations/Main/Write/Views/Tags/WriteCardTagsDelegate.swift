//
//  WriteCardTagsDelegate.swift
//  SOOUM
//
//  Created by 오현식 on 10/16/25.
//

import Foundation

protocol WriteCardTagsDelegate: AnyObject {
    
    func textFieldDidBeginEditing(_ textField: WriteCardTagFooter)
    func textDidChanged(_ text: String?)
}

extension WriteCardTagsDelegate {
    
    func textFieldDidBeginEditing(_ textField: WriteCardTagFooter) { }
    func textDidChanged(_ text: String?) { }
}
