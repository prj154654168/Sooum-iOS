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
        
        // 오늘인 경우에만 시분초 계산
        let timeInterval = max(0, to.timeIntervalSince(self))
        let hours = Int(timeInterval) / (60 * 60)
        
        if hours < 24 {
            let minutes = (Int(timeInterval) % (60 * 60)) / 60
            switch (hours, minutes) {
            case (1...23, _):   return "\(hours)시간 전"
            case (0, 11...59):  return "\(minutes / 10)0분 전"
            case (0, 1...10):   return "\(minutes)분 전"
            default:            return "방금 전"
            }
        }
        
        let calendar = Calendar.current
        // 시작 날짜와 끝 날짜의 시분초를 00:00:00으로 초기화하여 날짜 차이만 계산합니다.
        let startOfFrom = calendar.startOfDay(for: self)
        let startOfTo = calendar.startOfDay(for: to)
        
        // 두 날짜 사이의 일수(day) 차이를 구합니다.
        let components = calendar.dateComponents([.day], from: startOfFrom, to: startOfTo)
        let days = components.day ?? 0
        
        // 날짜 차이가 1일 이상인 경우 (시분초 무시)
        switch days {
        case 365...:    return "\(days / 365)년 전"
        case 30...:     return "\(days / 30)개월 전"
        case 7...:      return "\(days / 7)주 전"
        default:        return "\(days)일 전"
        }
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
            return "00:00:00"
        }
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
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
        return self.addingTimeInterval(24 * 60 * 60).toString("yyyy년 MM월 dd일")
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
