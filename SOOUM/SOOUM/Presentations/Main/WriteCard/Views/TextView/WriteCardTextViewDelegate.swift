//
//  WriteCardTextViewDelegate.swift
//  SOOUM
//
//  Created by 오현식 on 10/18/24.
//

import Foundation


/// 각 메서드의 동작은 `UIKit/UITextView/UITextViewDelegate` 를 참고하십시오.
protocol WriteCardTextViewDelegate: AnyObject {
    
    func textViewShouldBeginEditing(_ textView: WriteCardTextView) -> Bool
    func textViewDidBeginEditing(_ textView: WriteCardTextView)

    func textViewShouldEndEditing(_ textView: WriteCardTextView) -> Bool
    func textViewDidEndEditing(_ textView: WriteCardTextView)

    func textViewDidChange(_ textView: WriteCardTextView)
    func textView(_ textView: WriteCardTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool

    func textViewReturnKeyClicked(_ textView: WriteCardTextView)
}

extension WriteCardTextViewDelegate {

    func textViewShouldBeginEditing(_ textView: WriteCardTextView) -> Bool { true }
    func textViewDidBeginEditing(_ textView: WriteCardTextView) { }

    func textViewShouldEndEditing(_ textView: WriteCardTextView) -> Bool { true }
    func textViewDidEndEditing(_ textView: WriteCardTextView) { }

    func textViewDidChange(_ textView: WriteCardTextView) { }
    func textView(_ textView: WriteCardTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool { true }

    func textViewReturnKeyClicked(_ textView: WriteCardTextView) { }
}
