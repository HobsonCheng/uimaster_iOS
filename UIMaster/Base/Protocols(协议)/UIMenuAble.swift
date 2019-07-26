//
//  UIMenuAble.swift
//  UIMaster
//
//  Created by hobson on 2018/11/15.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit

struct MenuItemConfig {
    var title: String
    var action: Selector
}
/// 长按弹出菜单的功能
/// 需要重写 canBecomeFirstResponder 为 true
/// 需要重写 canPerformAction方法 哪些菜单要展示
protocol UIMenuAble {}
extension UIMenuAble where Self: UIResponder {
    func setupMenuController(configs: [MenuItemConfig], targetFrame: CGRect, in view: UIView) {
        self.becomeFirstResponder()
        let menu = UIMenuController.shared
        var itemArr = [UIMenuItem]()
        //循环创建item，添加到数组
        for itemConfig in configs {
            let item = UIMenuItem(title: itemConfig.title, action: itemConfig.action)
            itemArr.append(item)
        }
        menu.menuItems = itemArr
        //设置menu的显示位置
        menu.setTargetRect(targetFrame, in: view)
        //让menu显示
        menu.setMenuVisible(true, animated: true)
    }
}
