//
//  Date.swift
//  SOOUM
//
//  Created by 오현식 on 9/27/24.
//

import Foundation


extension Date {
    
    func infoReadableTimeTakenFromThis(to: Date) -> String {

        let from: TimeInterval = self.timeIntervalSince1970
        let to: TimeInterval = to.timeIntervalSince1970
        let gap: TimeInterval = max(0, to - from)

        let time: Int = .init(gap)
        let days: Int = time / (24 * 60 * 60)
        let hours: Int = .init(time % (24 * 60 * 60)) / (60 * 60)
        let minutes: Int = .init(time % (60 * 60)) / 60
        /// 추후 초가 사용되면 주석 풀기
        // let seconds: Int = .init(time % 60)
        
        if days > 364 {
            return "\(days)년전".trimmingCharacters(in: .whitespaces)
        }
        
        if days > 0 && days < 365 {
            return "\(days)일전".trimmingCharacters(in: .whitespaces)
        }
        
        if hours > 0 && hours < 24 {
            return "\(hours)시간전".trimmingCharacters(in: .whitespaces)
        }
        
        if minutes > 9 && minutes < 60 {
            return "\(minutes % 100)0분전".trimmingCharacters(in: .whitespaces)
        }
        
        if minutes > 4 && minutes < 10 {
            return "10분전".trimmingCharacters(in: .whitespaces)
        }
        
        if minutes < 5 {
            return "조금전".trimmingCharacters(in: .whitespaces)
        }

        return ""
    }
}