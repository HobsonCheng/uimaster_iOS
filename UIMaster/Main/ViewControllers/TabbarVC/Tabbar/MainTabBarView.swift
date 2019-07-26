//
//  MainTabBarView.swift
//  UIDS
//
//  Created by one2much on 2018/2/11.
//  Copyright © 2018年 one2much. All rights reserved.
//

import SwiftyJSON
import UIKit

//自定义标签栏代理协议
protocol MainTabBarDelegate: AnyObject {
    func didChooseItem(itemIndex: Int)
}

class MainTabBarView: UIView {
    weak var delegate: MainTabBarDelegate? //代理,点击item
    fileprivate let tabBarConfig: TabbarConfigModel? //样式
    var imageView: UIImageView?
    var itemArray: [MainTabBarItem] = [] //标签Item数组

    init(frame: CGRect, tabBarConfig: TabbarConfigModel?) {
        self.tabBarConfig = tabBarConfig
        super.init(frame: frame)
        // 设置tabBar栏的背景
        self.backgroundColor = tabBarConfig?.styles?.bgColor?.toColor() ?? kThemeColor
        self.imageView = UIImageView().then({
            $0.frame = CGRect(origin: .zero, size: self.frame.size)
            $0.kf.setImage(with: URL(string: tabBarConfig?.styles?.bgImg ?? ""))
        })
        self.addSubview(imageView!)
        //设置line
//        if tabbarConfig?.styles?.borderShow == 1{
//            let lineView = UIView().then {
//                $0.backgroundColor = tabbarConfig?.styles?.borderColor?.toColor()
//                $0.frame = CGRect.init(x: 0, y: -1, width: Int(kScreenW), height: tabbarConfig?.styles?.borderWidth ?? 1)
//            }
//            self.addSubview(lineView)
//        }
        let lineView = UIView().then {
            $0.backgroundColor = UIColor(hexString: "#cccccc")
            $0.frame = CGRect(x: 0, y: -1, width: Int(kScreenW), height: 1)
        }
        self.addSubview(lineView)
        //items数据
        let items = GlobalConfigTool.shared.tabbarItemsData
        let itemWidth = kScreenW / CGFloat(items.count)
        //遍历items数组，创建TabbarItem
        for (index, item) in items.enumerated() {
            //创建tabbarItem
            let itemFrame = CGRect(x: itemWidth * CGFloat(index), y: 0, width: itemWidth, height: 49)
            let itemView = MainTabBarItem(frame: itemFrame, itemData: item, itemIndex: index)
            self.addSubview(itemView)
            self.itemArray.append(itemView)
            //绑定事件
            itemView.addTarget(self, action: #selector(self.didItemClick(item:)), for: .touchUpInside)
            //默认点击第一个
            if index == 0 {
                self.didItemClick(item: itemView)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    ///点击单个标签视图，通过currentSelectState的属性观察器更新标签的显示
    ///并且通过代理方法切换标签控制器的当前视图控制器
    @objc func didItemClick(item: MainTabBarItem) {
        guard let events = item.itemData.events else {
            return
        }
        guard let clickEvent = events["click"] else {
            return
        }
        if clickEvent.type == 0 && clickEvent.pageMode == 0 {
            for index in 0..<itemArray.count {
                let tempItem = itemArray[index]
                if tempItem.index == item.index {
                    tempItem.currentSelectState = true
                } else {
                    tempItem.currentSelectState = false
                }
            }
        }
        //执行代理方法
        self.delegate?.didChooseItem(itemIndex: item.index ?? 0)
    }
}
