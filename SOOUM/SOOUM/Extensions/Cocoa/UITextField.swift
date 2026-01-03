//
//  UITextField.swift
//  SOOUM
//
//  Created by 오현식 on 10/9/25.
//

import UIKit

extension UITextField {

    func shouldChangeCharactersIn(
        in range: NSRange,
        replacementString string: String,
        maxCharacters limit: Int,
        // 공백 제거 여부
        hasSpaces: Bool = true
    ) -> Bool {
        guard let text = self.text else {
            return true
        }
        if string.isEmpty {
            return true
        }
        
        let removedString: String = hasSpaces ? string : string.replacingOccurrences(of: " ", with: "")
        let nsString: NSString? = text as NSString?
        let newString: String = nsString?.replacingCharacters(in: range, with: string) ?? ""

        let isTyped: Bool = (range.length == 0)
        let aleadyFull: Bool = (text.count >= limit)
        let newFull: Bool = newString.count > limit

        if newFull {
            // 최종 텍스트가 제한을 벗어남
            if aleadyFull {
                // 텍스트 입력 전에 제한을 벗어남
                if isTyped {
                    // 영어 입력 시 더 이상 입력되지 않음
                    guard string.isEnglish == false else { return false }
                    let lastCharacter = String(text[text.index(before: text.endIndex)])
                    let separatedCharacters = lastCharacter.decomposedStringWithCanonicalMapping.unicodeScalars.map { String($0) }
                    let separatedCharactersCount = separatedCharacters.count
                    // 마지막 문자를 자음 + 모음으로 나누어 갯수에 따라 판단,
                    // 갯수가 1일 때, 모음이면 입력 가능
                    if separatedCharactersCount == 1 && lastCharacter.isConsonant && removedString.isConsonant == false { return true }
                    // 갯수가 2일 때, 자음이면 입력 가능
                    if separatedCharactersCount == 2 && removedString.isConsonant { return true }
                    // TODO: 겹받침일 때는 고려 X
                    
                    return false
                } else {
                    // 텍스트 범위가 선택됨
                    // 추가되는 문자열에서 선택된 범위의 길이만큼만 교체
                    let to: Int = range.length
                    let validText: String = String(removedString.prefix(max(0, to)))
                    self.text = nsString?.replacingCharacters(in: range, with: validText)

                    if let position = self.position(from: self.beginningOfDocument, offset: range.location + to) {
                        DispatchQueue.main.async { [weak self] in
                            self?.selectedTextRange = self?.textRange(from: position, to: position)
                        }
                    }
                    self.sendActions(for: .editingChanged)
                }
            } else {
                // 텍스트 입력 후에 제한을 벗어남
                // 추가되는 문자열에서 제한을 넘지 않는 길이만큼만 추가
                let to: Int = limit - text.count
                let validText: String = String(removedString.prefix(max(0, to)))
                self.text = nsString?.replacingCharacters(in: range, with: validText)

                if let position = self.position(from: self.beginningOfDocument, offset: range.location + to) {
                    DispatchQueue.main.async { [weak self] in
                        self?.selectedTextRange = self?.textRange(from: position, to: position)
                    }
                }
                self.sendActions(for: .editingChanged)
            }
            return false
        } else {
            if hasSpaces {
                return true
            } else {
                // 공백이 없는 입력일 경우, 입력됨
                if isTyped && string == removedString {
                    return true
                } else {
                    // 텍스트 입력에 공백이 포함됨
                    // 추가되는 문자열에서 제한을 넘지 않는 길이만큼만 추가
                    let to: Int = limit - text.count
                    let validText: String = String(removedString.prefix(max(0, to)))
                    self.text = nsString?.replacingCharacters(in: range, with: validText)
                    
                    if let position = self.position(from: self.beginningOfDocument, offset: range.location + to) {
                        DispatchQueue.main.async { [weak self] in
                            self?.selectedTextRange = self?.textRange(from: position, to: position)
                        }
                    }
                    self.sendActions(for: .editingChanged)
                }
                // 공백 타이핑일 경우도 입력 제한
                return false
            }
        }
    }
}
