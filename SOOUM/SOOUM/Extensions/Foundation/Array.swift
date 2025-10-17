//
//  Array.swift
//  SOOUM
//
//  Created by 오현식 on 10/14/25.
//

extension Array where Element: Hashable {
    
    func removeOlderfromDuplicated() -> [Element] {
        var seen = Set<Element>()
        let reversed = self.reversed().filter {
            seen.insert($0).inserted
        }
        return reversed.reversed()
    }
}
