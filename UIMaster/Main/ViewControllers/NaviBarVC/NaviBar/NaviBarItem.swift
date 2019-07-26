//
//  NaviBarItem.swift
//  UIMaseter
//
//  Created by one2much on 2018/4/17.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Then
import UIKit
enum NaviBarItemState {
    /// 普通状态
    case normal
    /// 高亮状态
    case highlighted
    /// 禁用状态
    case disable
}

//fileprivate enum NaviBarItemType{
//    case image
//    case text
//    case close
//    case back
//    case empty
//}

// MARK: -

class NaviBarItem: UIButton {
    //item的样式
//    var navibarItemStyle: NaviBarStyleData?{
//        didSet{
//            switch type {
//            case .text:
//                self.titleLabel?.font = UIFont.init(name: navibarItemStyle?.font ?? "", size: CGFloat(navibarItemStyle?.fontSize ?? 14))
//            case .back,.close:
//                self.setYJTitleColor(color: .white)
//                self.titleLabel?.font = UIFont.init(name: "iconfont", size: 16)
//            default:
//                break
//            }
//        }
//    }
    /// 设置frame时，会自动修改self的frame
//    override var frame: CGRect{
////        willSet {
////            if newValue.origin.x != 0 || newValue.origin.y != 0 {
////                let newframe = CGRect(x: 0, y: 0, width: newValue.size.width, height: newValue.size.height)
////                newValue = newframe
////            }
////        }
////        set {
//////            if frame.origin.x != 0 || frame.origin.y != 0 {
////                self.frame = CGRect(x: 0, y: 0, width: newValue.size.width, height: newValue.size.height)
//////            } else {
//////                self.frame = newValue
//////            }
////        }
////        get {
////            return self.frame
////        }
//        didSet{
//            let newframe = CGRect.init(x: 0, y: 0, width: oldValue.size.width, height: oldValue.size.height)
//            super.frame = newframe
//        }
//    }

    /// 设置Item是否为Disabled
    var isItemEnable: Bool = true {
        didSet {
            self.isEnabled = isItemEnable
        }
    }

    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        return contentRect.insetBy(dx: 7, dy: 7)
    }

    fileprivate var itemHeight: CGFloat = 44
    fileprivate let itemWidth: CGFloat = 43
    fileprivate let hMargin = 6

    convenience init(withItemData item: NavibarItemsModel, target: AnyObject, selector: Selector) {
        switch item.fields?.type ?? 0 {
        case 0:
            self.init(withText: item.fields?.title ?? "", target: target, action: selector, fontSize: item.styles?.fontSize ?? 14, color: item.styles?.color?.toColor() ?? .white, itemHeight: item.styles?.itemHeight ?? 44)
        case 1:
            let size = CGSize(width: item.styles?.imgWidth ?? 43, height: item.styles?.imgHeight ?? 44)
            self.init(withImgUrl: item.fields?.normalIcon ?? "", target: target, action: selector, imgSize: size)
        case 2:
            self.init(withCode: item.fields?.fonticon ?? "", target: target, action: selector, fontSize: item.styles?.fontSize ?? 14, color: item.styles?.color?.toColor() ?? .white)
        default:
            self.init(withText: item.fields?.title ?? "", target: target, action: selector, fontSize: item.styles?.fontSize ?? 14, color: item.styles?.color?.toColor() ?? .white, itemHeight: item.styles?.itemHeight ?? 44)
        }
    }

    /// 根据url创建图片item 设置背景图 或 icon图
    init(withImgUrl imageUrl: String, target: AnyObject, action: Selector, imgSize: CGSize) {
        super.init(frame: .zero)
        self.frame = CGRect(origin: CGPoint(x: 0, y: hMargin), size: imgSize)
        self.setIconImageUrl(with: imageUrl, for: .normal)

        self.addTarget(target, action: action, for: .touchUpInside)
        self.isExclusiveTouch = true
    }
    /// 根据图片 创建图片item
    init(withImg image: UIImage, target: AnyObject, action: Selector, imgSize: CGSize) {
        super.init(frame: .zero)
        self.frame = CGRect(origin: CGPoint(x: 0, y: hMargin), size: imgSize)
        setIconImage(with: image, for: .normal)
        self.height = itemHeight
        self.addTarget(target, action: action, for: .touchUpInside)
        self.isExclusiveTouch = true
    }
    /// 创建文字BarItem
    init(withText title: String, target: AnyObject, action: Selector, fontSize: CGFloat, color: UIColor, itemHeight: CGFloat) {
        super.init(frame: .zero)
        //计算设置尺寸
        let titleSize = title.getSize(fontSize: fontSize)
        let width = titleSize.width + CGFloat(2 * hMargin)
        let height = itemHeight
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.frame = frame
        self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        self.setTitle(title, for: .normal)
        self.setTitleColor(color, for: .normal)
        self.addTarget(target, action: action, for: .touchUpInside)
        self.isExclusiveTouch = true
    }

    init(withCode iconCode: String, target: AnyObject, action: Selector, fontSize: CGFloat, color: UIColor) {
        super.init(frame: .zero)
        let width = fontSize + CGFloat(2 * hMargin)
        let height = itemHeight
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.frame = frame
        self.setYJIcon(iconCode: iconCode, iconSize: fontSize, forState: .normal)
        self.setYJTitleColor(color: color)
        self.addTarget(target, action: action, for: .touchUpInside)
        self.isExclusiveTouch = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 创建返回BarItem
//    convenience init(backTarget target:AnyObject,action: Selector) {
//        self.init(target: target, action: action)
//        self.setYJIcon(icon: YJType.back, iconSize:  16, forState: .normal)
//        type = .back
//    }
//
//    /// 创建关闭BarItem
//    convenience init(closeTarget target:AnyObject,action: Selector) {
//        self.init(target: target, action: action)
//        self.setYJIcon(icon: YJType.back, iconSize:  16, forState: .normal)
//        type = .close
//    }
//

    /// 设置title文字
//    func setTitle(title:String) {
//        if type == .text{
//            let titleSize = title.getSize(fontSize: 14)
//            let width = titleSize.width  + CGFloat(2 * hMargin)
//            let height = itemHeight
//            self.frame = CGRect.init(x: 0, y: 0, width: Int(width), height: height)
//            self.frame = CGRect.init(x: 0, y: 0, width: Int(width), height: height)
//            self.setTitle(title, for: .normal)
//        }
//    }
    // 设置背景图
    func setBackgroundImage(with image: UIImage, for state: NaviBarItemState) {
        switch state {
        case .normal:
            self.setBackgroundImage(image, for: .normal)
        case .disable:
            self.setBackgroundImage(image, for: .disabled)
        case .highlighted:
            self.setBackgroundImage(image, for: .highlighted)
        }
    }
    // 设置图片按钮
    func setIconImage(with image: UIImage, for state: NaviBarItemState) {
        switch state {
        case .normal:
            self.setImage(image, for: .normal)
        case .disable:
            self.setImage(image, for: .disabled)
        case .highlighted:
            self.setImage(image, for: .highlighted)
        }
    }
    //网络图片
    func setIconImageUrl(with imageUrl: String, for state: NaviBarItemState) {
        switch state {
        case .normal:
            self.kf.setImage(with: URL(string: imageUrl), for: .normal)
        case .disable:
            self.kf.setImage(with: URL(string: imageUrl), for: .disabled)
        case .highlighted:
            self.kf.setImage(with: URL(string: imageUrl), for: .highlighted)
        }
//        self.imageView?.contentMode = .scaleAspectFit
    }
}
