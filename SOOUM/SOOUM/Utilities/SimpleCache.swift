//
//  SimpleCache.swift
//  SOOUM
//
//  Created by 오현식 on 12/17/24.
//

import Foundation


class SimpleCache {
    
    enum CardType: String {
        case latest
        case popular
        case distance
    }
    
    static let shared = SimpleCache()
    
    private let cache = NSCache<NSString, NSArray>()
    
    
    // MARK: Main home
    
    private let mainHomeKey: String = "com.sooum.main.home"
    
    func loadMainHomeCards(type cardType: CardType) -> [Card]? {
        let key: String = "\(self.mainHomeKey).\(cardType.rawValue)"
        return self.cache.object(forKey: key as NSString) as? [Card]
    }
    
    func saveMainHomeCards(type cardType: CardType, datas cards: [Card]) {
        let key: String = "\(self.mainHomeKey).\(cardType.rawValue)"
        self.cache.setObject(cards as NSArray, forKey: key as NSString)
    }
    
    func isEmpty(type cardType: CardType) -> Bool {
        return self.loadMainHomeCards(type: cardType) == nil
    }
    
    func clear(type cardType: CardType) {
        self.cache.removeAllObjects()
    }
}
