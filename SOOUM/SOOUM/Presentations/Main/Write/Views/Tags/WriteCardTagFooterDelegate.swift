//
//  WriteCardFooterDelegate.swift
//  SOOUM
//
//  Created by 오현식 on 10/8/25.
//

import Foundation

protocol WriteCardTagFooterDelegate: AnyObject {

    func textFieldDidBeginEditing(_ textField: WriteCardTagFooter)
    func textFieldDidEndEditing(_ textField: WriteCardTagFooter)
    func textFieldReturnKeyClicked(_ textField: WriteCardTagFooter) -> Bool
}

extension WriteCardTagFooterDelegate {

    func textFieldDidBeginEditing(_ textField: WriteCardTagFooter) { }
    func textFieldDidEndEditing(_ textField: WriteCardTagFooter) { }
    func textFieldReturnKeyClicked(_ textField: WriteCardTagFooter) -> Bool { true }
}
