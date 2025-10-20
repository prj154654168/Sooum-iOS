//
//  WritrCardTextViewDelegate.swift
//  SOOUM
//
//  Created by 오현식 on 10/16/25.
//

import Foundation

protocol WritrCardTextViewDelegate: AnyObject {
    
    func textViewDidBeginEditing(_ textView: WriteCardTextView)
}

extension WritrCardTextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: WriteCardTextView) { }
}
