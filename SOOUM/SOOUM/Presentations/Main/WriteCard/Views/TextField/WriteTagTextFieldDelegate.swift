//
//  WriteTagTextFieldDelegate.swift
//  SOOUM
//
//  Created by 오현식 on 10/19/24.
//

import Foundation

protocol WriteTagTextFieldDelegate: AnyObject {
    
    func textFieldShouldBeginEditing(_ textField: WriteTagTextField) -> Bool
    func textFieldDidBeginEditing(_ textField: WriteTagTextField)

    func textFieldShouldEndEditing(_ textField: WriteTagTextField) -> Bool
    func textFieldDidEndEditing(_ textField: WriteTagTextField)

    func textField(_ textField: WriteTagTextField, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool

    func textFieldReturnKeyClicked(_ textField: WriteTagTextField) -> Bool
}

extension WriteTagTextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: WriteTagTextField) -> Bool { true }
    func textFieldDidBeginEditing(_ textField: WriteTagTextField) { }

    func textFieldShouldEndEditing(_ textField: WriteTagTextField) -> Bool { true }
    func textFieldDidEndEditing(_ textField: WriteTagTextField) { }

    func textField(_ textField: WriteTagTextField, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool { true }

    func textFieldReturnKeyClicked(_ textField: WriteTagTextField) -> Bool { true }
}
