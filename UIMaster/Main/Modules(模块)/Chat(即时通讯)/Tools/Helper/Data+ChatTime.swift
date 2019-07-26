//
//  Data+ChatTime.swift
//  UIMaster
//
//  Created by hobson on 2018/9/29.
//  Copyright © 2018 one2much. All rights reserved.
//

import Foundation

// MARK: - 聊天时间的 格式化字符串
extension Date {
    var chatTimeString: String {
        get {
            // 是否是12小时制
            let is12Hour = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)?.contains("a") ?? false
            // 分解日期
            let calendarComponents = Calendar.current.dateComponents([.year, .month, .hour, .day, .minute], from: self)
            let year = calendarComponents.year ?? 0
            let month = calendarComponents.month ?? 0
            let day = calendarComponents.day ?? 0
            var hour = calendarComponents.hour ?? 0
            let minute = calendarComponents.minute ?? 0
            // 时间间隔
            let currentComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            let currentYear = currentComponents.year ?? 0
            let yearGap = currentYear - year
            // 天的间隔
            let comp = Calendar.current.dateComponents([.year, .month, .hour, .day, .minute], from: self, to: Date())
            let dayGap = comp.day ?? 0

            var timeTip = ""
            if is12Hour {
                if hour < 12 {
                    timeTip = "上午"
                } else if hour == 12 {
                    timeTip = "下午"
                } else if hour > 12 {
                    hour -= 12
                    timeTip = "下午"
                }
            }

            if yearGap != 0 {
                return String(format: "%zd年%zd月%zd日 \(timeTip)%02d:%02d", year, month, day, hour, minute)
            } else {
                if (dayGap > 1) {
                    return String(format: "%zd月%zd日 \(timeTip)%02d:%02d", month, day, hour, minute)
                } else if (dayGap == 1) {
                    return String(format: "昨天 \(timeTip)%02d:%02d", hour, minute)
                } else if (dayGap == 0) {
                    return String(format: "\(timeTip)%02d:%02d", hour, minute)
                } else {
                    return ""
                }
            }
        }
    }
}
