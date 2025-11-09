//
//  Date.swift
//  SOOUM
//
//  Created by 오현식 on 9/27/24.
//

import Foundation


extension Date {
    
    init?(from string: String, format: String = "yyyy-MM-dd") {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        guard let toDate = formatter.date(from: string) else { return nil }
        self = toDate
    }
    
    func toKorea() -> Date {
        let secondsFromGMT = TimeZone.Korea.secondsFromGMT(for: self)
        let toKorea = self.addingTimeInterval(TimeInterval(secondsFromGMT))
        return toKorea
    }
    
    func toString(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = .Korea
        formatter.timeZone = .Korea
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func infoReadableTimeTakenFromThis(to: Date) -> String {

        let from: TimeInterval = self.timeIntervalSince1970
        let to: TimeInterval = to.timeIntervalSince1970
        let gap: TimeInterval = max(0, to - from)

        let time: Int = .init(gap)
        let days: Int = time / (24 * 60 * 60)
        let hours: Int = .init(time % (24 * 60 * 60)) / (60 * 60)
        let minutes: Int = .init(time % (60 * 60)) / 60
        
        if days > 368 {
            return "\(days / 368)년전".trimmingCharacters(in: .whitespaces)
        }
        
        if days > 29 && days < 369 {
            return "\(days / 30)개월 전".trimmingCharacters(in: .whitespaces)
        }
        
        if days > 6 && days < 30 {
            return "\(days / 7)주 전".trimmingCharacters(in: .whitespaces)
        }
        
        if days > 0 && days < 6 {
            return "\(days)일 전".trimmingCharacters(in: .whitespaces)
        }
        
        if hours > 0 && hours < 24 {
            return "\(hours)시간 전".trimmingCharacters(in: .whitespaces)
        }
        
        if minutes > 10 && minutes < 60 {
            return "\(minutes / 10)0분 전".trimmingCharacters(in: .whitespaces)
        }
        
        if minutes > 0 && minutes < 11 {
            return "\(minutes)분 전".trimmingCharacters(in: .whitespaces)
        }
        
        if minutes < 1 {
            return "방금 전".trimmingCharacters(in: .whitespaces)
        }

        return ""
    }
    
    func infoReadableTimeTakenFromThisForPung(to: Date) -> String {
        
        let from: TimeInterval = self.timeIntervalSince1970
        let to: TimeInterval = to.timeIntervalSince1970
        let gap: TimeInterval = max(0, to - from)

        let time: Int = .init(gap)
        let hours: Int = .init(time) / (60 * 60)
        let minutes: Int = .init(time % (60 * 60)) / 60
        let seconds: Int = .init(time % 60)
        
        if hours <= 0 && minutes <= 0 && seconds <= 0 {
            return "00 : 00 : 00"
        }
        return String(format: "%02d : %02d : %02d", hours, minutes, seconds)
    }
    
    func infoReadableTimeTakenFromThisForPungToHoursAndMinutes(to: Date) -> String {
        
        let from: TimeInterval = self.timeIntervalSince1970
        let to: TimeInterval = to.timeIntervalSince1970
        let gap: TimeInterval = max(0, to - from)

        let time: Int = .init(gap)
        let minutes: Int = .init(time % (60 * 60)) / 60
        let seconds: Int = .init(time % 60)
        
        if minutes <= 0 && seconds <= 0 {
            return "00:00"
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func infoReadableTimeTakenFromThisForBanEndPosting(to: Date) -> String {
        
        let from: TimeInterval = self.timeIntervalSince1970
        let to: TimeInterval = to.timeIntervalSince1970
        let gap: TimeInterval = max(0, to - from)

        let time: Int = .init(gap)
        let days: Int = time / (24 * 60 * 60)
        
        return "\(days)일간"
    }
    
    var banEndFormatted: String {
        return self.toString("yyyy년 MM월 dd일")
    }
    
    var banEndDetailFormatted: String {
        return self.toString("yyyy년 MM월 dd일 HH시 mm분")
    }
    
    var announcementFormatted: String {
        return self.toString("yyyy.MM.dd")
    }
    
    var noticeFormatted: String {
        return self.toString("M월 d일")
    }
}

extension Locale {

    static let Korea = Locale(identifier: "ko_KR")
}

extension TimeZone {

    static let Korea = TimeZone(identifier: "Asia/Seoul")!
}
