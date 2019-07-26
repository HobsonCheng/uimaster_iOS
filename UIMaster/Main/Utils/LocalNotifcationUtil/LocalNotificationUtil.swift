//
//  LocalNotifcationUtil.swift
//  UIMaster
//
//  Created by hobson on 2019/1/23.
//  Copyright © 2019 one2much. All rights reserved.
//

import UIKit
import UserNotifications
class LocalNotificationUtil {
    static let shared = LocalNotificationUtil()
    let unCenter = UNUserNotificationCenter.current()
    let pushContent = UNMutableNotificationContent()

    func push(title: String, sound: UNNotificationSound? = .default(), content: String, timeInterval: TimeInterval, repeats: Bool) {
        pushContent.title = title
        pushContent.sound = sound
        pushContent.body = content

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: repeats)

        let request = UNNotificationRequest(identifier: "YJNotifaction", content: pushContent, trigger: trigger)

        unCenter.add(request, withCompletionHandler: nil)
    }
}
