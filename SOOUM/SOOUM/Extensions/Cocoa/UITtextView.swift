//
//  UITtextView.swift
//  SOOUM
//
//  Created by 오현식 on 10/16/25.
//

import UIKit

extension UITextView {

    func shouldChangeText(in range: NSRange, replacementText text: String, maxCharacters limit: Int) -> Bool {
        if text.isEmpty {
            return true
        }

        let nsString = self.text as NSString?
        let newString: String = nsString?.replacingCharacters(in: range, with: text) ?? ""

        let isTyped: Bool = (range.length == 0)
        let aleadyFull: Bool = (self.text.count >= limit)
        let newFull: Bool = newString.count > limit

        if newFull {
            // 최종 텍스트가 제한을 벗어남
            if aleadyFull {
                // 텍스트 입력 전에 제한을 벗어남
                if isTyped {
                    // 입력 시 더 이상 입력되지 않음
                    return false
                } else {
                    // 텍스트 범위가 선택됨
                    // 추가되는 문자열에서 선택된 범위의 길이만큼만 교체
                    let to: Int = range.length
                    let validText: String = String(text.prefix(max(0, to)))
                    self.text = nsString?.replacingCharacters(in: range, with: validText)

                    if let position = self.position(from: self.beginningOfDocument, offset: range.location + to) {
                        DispatchQueue.main.async { [weak self] in
                            self?.selectedTextRange = self?.textRange(from: position, to: position)
                        }
                    }
                }
            } else {
                // 텍스트 입력 후에 제한을 벗어남
                // 추가되는 문자열에서 제한을 넘지 않는 길이만큼만 추가
                let to: Int = limit - self.text.count
                let validText: String = String(text.prefix(max(0, to)))
                self.text = nsString?.replacingCharacters(in: range, with: validText)

                if let position = self.position(from: self.beginningOfDocument, offset: range.location + to) {
                    DispatchQueue.main.async { [weak self] in
                        self?.selectedTextRange = self?.textRange(from: position, to: position)
                    }
                }
            }
            return false
        } else {
            return true
        }
    }
}
