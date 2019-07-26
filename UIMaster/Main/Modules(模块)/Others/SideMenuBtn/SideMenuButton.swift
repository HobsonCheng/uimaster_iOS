//
//  SideMenuView.swift
//  UIMaster
//
//  Created by gongcz on 2018/5/12.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

//typealias SideMenuBlock = (_ item: SideMenuItemData, _ btn: UIButton)->()
class SideMenuButton: YJButton {
    var model: SideMenuBtnItemsData?

    init(parentWidth: CGFloat, parentHeight: CGFloat, model: SideMenuBtnItemsData?, target: AnyObject, action: Selector, hasNavBar: Bool) {
        self.model = model
        //计算frame
        let btnWidth: CGFloat = 60
        let btnHeight = parentHeight / 7
        let btnX = (Int(model?.fields?.name ?? "3") ?? 3) >= 7 ? parentWidth - btnWidth : 0
        var btnY = CGFloat((Int(model?.fields?.name ?? "3") ?? 3) % 7) * btnHeight
        if hasNavBar {
            btnY += kNavigationBarHeight
        }
        let frame = CGRect(x: btnX, y: btnY, width: btnWidth, height: btnWidth)
        super.init(frame: frame)
        self.imagePostion = .top
        if model?.styles?.showType == 3 {
            self.imageSize = CGSize(width: self.width - (model?.styles?.fontSize ?? 14), height: self.height - (model?.styles?.fontSize ?? 14))
        }
        self.setTitle(model?.fields?.title, for: .normal)
        self.margin = 5
        self.setTitleColor(.black, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: model?.styles?.fontSize ?? 14)
        self.kf.setImage(with: URL(string: model?.fields?.normalIcon ?? ""), for: .normal)
        self.kf.setImage(with: URL(string: model?.fields?.selectedIcon ?? ""), for: .selected)
        self.addTarget(target, action: action, for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//class SideMenuView: UIView {
//
//    final var style: SideMenuStyle = .left
//    fileprivate var smBlock: SideMenuBlock?
//    fileprivate var dataSource: [SideMenuItemData] = []
//    
//    init(menuStyle: SideMenuStyle, block: SideMenuBlock?) {
//        super.init(frame: .zero)
//        style = menuStyle
//        smBlock = block
//        configSubviews()
//        
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    fileprivate init() {
//        super.init(frame: .zero)
//    }
//    
//    fileprivate override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    
//    func configSubviews() {
//        /// 菜单宽度
//        let menuWidth: CGFloat = 60;
//        let menuHeight = kScreenH - kNavigationBarHeight
//        let menuY = kNavigationBarHeight
//        var menuX: CGFloat = 0
//        switch style {
//        case .left:
//            dPrint("left")
//            menuX = 0
//        case .right:
//            dPrint("right")
//            menuX = kScreenW - menuWidth
////        default:
//        }
//        frame = CGRect(x: menuX, y: menuY, width: menuWidth, height: menuHeight)
//    }
//    
//    
//    func insertItem(item: SideMenuItem) {
//        let idx = item.index
//        if let v = viewWithTag(idx+1) {
//            v.removeFromSuperview()
//        }
//        let cell = SideMenuCell() //SideMenuButton(type: .custom)
////        btn.sd_setBackgroundImage(with: URL(string: item.iconUrl), for: .normal, completed: nil)
//        cell.imgV.sd_setImage(with: URL(string: item.iconUrl), completed: nil)
//        cell.tag = idx + 1
//        cell.btn.tag = idx + 1
//        cell.item = item
//        let itemH = (kScreenH - kNavigationBarHeight) / 7
//        cell.frame = CGRect(x: 0, y: CGFloat(idx) * itemH, width: self.mj_w, height: itemH)
//        addSubview(cell)
//        cell.btn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
//    }
//    
//    @objc fileprivate func btnClick(_ sender: UIButton) {
//        if let block = smBlock {
//            if let cell = sender.superview as? SideMenuCell {
//                if let item = cell.item {
//                    block(item, sender)
//                }
//            }
//        }
//    }
//    
//    func randomMenuData() -> [SideMenuItem] {
//        var arr: [SideMenuItem] = []
//        for i in 0...7 {
//            var menuItem = SideMenuItem()
//            menuItem.index = i
//            if arc4random()%2 == 1 {
//                menuItem.iconUrl = "http://icons.iconarchive.com/icons/alex-t/minimal-fruit/128/apple-icon.png"
//                menuItem.event = "push"
//            }else{
//                menuItem.iconUrl = "http://icons.iconarchive.com/icons/alex-t/minimal-fruit/128/watermelon-icon.png"
//                menuItem.event = "popover"
//            }
//            arr.append(menuItem)
//        }
//        return arr
//    }
//    
//}
