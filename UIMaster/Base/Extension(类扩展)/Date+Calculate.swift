//
//  Date+gyh.swift
//  UIMaseter
//
//  Created by gongcz on 2018/4/18.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Foundation

extension Date {
    /**
     *  是否为今天
     */
    func isToday() -> Bool {
        let calendar = Calendar.current
        let unit: Set<Calendar.Component> = [.day, .month, .year]
        // 1.获得当前时间的年月日
        let nowCmps: DateComponents? = calendar.dateComponents(unit, from: Date())
        // 2.获得self的年月日
        let selfCmps: DateComponents? = calendar.dateComponents(unit, from: self)
        return (selfCmps?.year == nowCmps?.year) && (selfCmps?.month == nowCmps?.month) && (selfCmps?.day == nowCmps?.day)
    }

    /**
     *  返回当前时间
     */
    static func currentTime(_: TimeInterval) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM-dd HH:mm"
        let str = fmt.string(from: Date())
        return str
    }

    /**
     *  是否为昨天
     */
    func isYesterday() -> Bool {
        let nowDate = Date().dateWithYMD()
        let selfDate: Date? = dateWithYMD()
        let calendar = Calendar.current
        var cmps: DateComponents?
        if let aDate = selfDate, let aDate1 = nowDate {
            cmps = calendar.dateComponents([.day], from: aDate, to: aDate1)
        }
        return cmps?.day == 1
    }
    func dateWithYMD() -> Date? {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let str = fmt.string(from: self)
        return fmt.date(from: str)
    }
    /**
     *  是否为今年
     */
    func isThisYear() -> Bool {
        let calendar = Calendar.current
        let unit: Set<Calendar.Component> = [.year]
        // 1.获得当前时间的年月日
        let nowCmps: DateComponents? = calendar.dateComponents(unit, from: Date())
        // 2.获得self的年月日
        let selfCmps: DateComponents? = calendar.dateComponents(unit, from: self)
        return nowCmps?.year == selfCmps?.year
    }
    func deltaWithNow() -> DateComponents? {
        let calendar = Calendar.current
        let unit: Set<Calendar.Component> = [.hour, .minute, .second]
        return calendar.dateComponents(unit, from: self, to: Date())
    }

    /// 获取从1970年开始的时间间隔毫秒
    ///
    /// - Returns: 时间间隔毫秒
    func getTimeIntervalSince1970() -> Int64 {
        let interval = Int64(self.timeIntervalSince1970 * 1_000)
        return interval
    }
}
