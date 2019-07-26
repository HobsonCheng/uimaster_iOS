//
//  NaviBar.swift
//  UIMaseter
//
//  Created by one2much on 2018/4/16.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Then
import UIKit

/// 导航栏样式
enum NaviBarMetric {
    //高度间距
    static let navibarHeight: CGFloat = 42
    static let itemWidth: CGFloat = 20
    static let itemHeight: CGFloat = 16
    static let itemMargin: CGFloat = 5
}

class NaviBar: UIControl {
    ///设置背景图
    var bgImg: UIImage? {
        didSet {
            bgImgView?.image = bgImg
        }
    }
    ///设置背景图Str
    var bgImgStr: String? {
        didSet {
            bgImgView?.kf.setImage(with: URL(string: bgImgStr ?? ""))
        }
    }
    /// 是否可点击
    var isClickEnable: Bool = false {
        didSet {
            self.reLayout()
        }
    }

    /// 获取和设置标题View
    var titleView: UIView? {
        didSet {
            viewTitle?.removeFromSuperview()
            if let titleView = titleView {
                viewTitle = titleView
                self.addSubview(titleView)
            }
            self.reLayout()
        }
    }

    /// 设置导航标题文字
    var title: String? {
        didSet {
            if let safeLabel = self.titleLabel {
                safeLabel.text = title
                self.reLayout()
            }
        }
    }
    /// 设置获取标题颜色
    var titleColor: UIColor? {
        didSet {
            if let safeLabel = self.titleLabel {
                safeLabel.textColor = titleColor
                self.reLayout()
            }
        }
    }

    /// 是否隐藏左边视图
    var isHiddenLeftView: Bool = false {
        didSet {
            if !(leftBarItems.isEmpty) {
                for item in leftBarItems {
                    item.isHidden = isHiddenLeftView
                }
                self.reLayout()
            }
        }
    }
    /// 设置导航标题字体
    var font: String? {
        didSet {
            if let safeLabel = self.titleLabel {
                safeLabel.font = UIFont(name: font ?? "", size: fontSize ?? 18)
                self.reLayout()
            }
        }
    }
    /// 设置导航标题字号
    var fontSize: CGFloat? {
        didSet {
            if let safeLabel = self.titleLabel {
                safeLabel.font = UIFont(name: font ?? "", size: fontSize ?? 18)
                self.reLayout()
            }
        }
    }
    /// 是否隐藏标题
    var isHiddenTitleView: Bool = false {
        didSet {
            if viewTitle != nil {
                viewTitle?.isHidden = isHiddenTitleView
                self.reLayout()
            }
        }
    }
    /// 是否隐藏右边视图
    var isHiddenRightView: Bool = false {
        didSet {
            if !(rightBarItems.isEmpty) {
                for item in rightBarItems {
                    item.isHidden = isHiddenLeftView
                }
                self.reLayout()
            }
        }
    }

    //私有属性
    fileprivate var viewTitle: UIView?
    fileprivate var titleLabel: UILabel?
    fileprivate var titleArrow: UIImageView?//标题列表箭头
    fileprivate var rightBarItems: [NaviBarItem] = []
    fileprivate var bgImgView: UIImageView?//背景图

    /// 左边item按钮
    fileprivate var leftBarItems: [NaviBarItem] = []
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        //初始化视图
        renderUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - render UI
extension NaviBar {
    /// 初始化UI
    func renderUI() {
        //背景图
        let imageView = UIImageView()
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        self.bgImgView = imageView

        self.backgroundColor = kNaviBarBackGroundColor
        if let imgUrl = self.bgImgStr {
            imageView.kf.setImage(with: URL(string: imgUrl), placeholder: R.image.placeholder(), options: nil, progressBlock: nil, completionHandler: nil)
            self.addSubview(imageView)
        }
        //初始化title
        self.viewTitle = LightControl().then({
            $0.isUserInteractionEnabled = false
        })
        self.titleLabel = UILabel().then {
            $0.backgroundColor = .clear
            $0.textColor = self.titleColor
            $0.lineBreakMode = .byTruncatingMiddle
            $0.textAlignment = .center
//            $0.adjustsFontSizeToFitWidth = true
            $0.text = self.title
            $0.font = UIFont.systemFont(ofSize: 18)
            $0.numberOfLines = 1
        }
        viewTitle?.addSubview(titleLabel!)
        //设置title下拉箭头
        self.titleArrow = UIImageView().then {
            $0.setViewSize(CGSize(width: NaviBarMetric.itemWidth, height: NaviBarMetric.itemHeight))
            $0.setYJIconWithName(icon: .downArrow, textColor: .white)

            $0.isHidden = !self.isClickEnable
        }
        viewTitle?.addSubview(titleArrow!)
        if let viewTitle = viewTitle as? LightControl {
            viewTitle.addTarget(self, action: #selector(titleTouchDown), for: .touchDown)
            viewTitle.addTarget(self, action: #selector(titleTouchupInside), for: .touchUpInside)
            viewTitle.addTarget(self, action: #selector(titleTouchupOutside), for: .touchUpOutside)
        }
        self.addSubview(viewTitle!)
    }
}

// MARK: - layout & config
extension NaviBar {
    /// 重新布局
    func reLayout() {
        let superFrame = self.frame
        //水平起止坐标
        var startX: CGFloat = NaviBarMetric.itemMargin
        var endX = superFrame.size.width - NaviBarMetric.itemMargin
        //纵向起止坐标
        var startY: CGFloat = 0.0
        let endY = superFrame.size.height

        startY += superFrame.size.height - CGFloat(NaviBarMetric.navibarHeight)
        //重设left item frame
        if !(leftBarItems.isEmpty) && !isHiddenLeftView {
            for item in leftBarItems {
                let size = item.frame.size
                item.setViewOrigin(CGPoint(x: startX, y: startY + (endY - startY - size.height) / 2))
                startX += size.width + NaviBarMetric.itemMargin
            }
        }
        //重设right item frame
        if !(rightBarItems.isEmpty) && !isHiddenRightView {
            for item in rightBarItems {
                let size = item.frame.size
                item.setViewOrigin(CGPoint(x: endX - size.width, y: startY + (endY - startY - size.height) / 2))
                endX -= item.frame.size.width + NaviBarMetric.itemMargin
            }
        }
        //重设titleView frame
        if viewTitle != nil && !isHiddenTitleView {
            startX += CGFloat(NaviBarMetric.itemMargin)
            endX -= CGFloat(NaviBarMetric.itemMargin)
            //取距离中心较短的为宽度的一半
            let mid = superFrame.size.width / 2
            let halfWidth = mid - startX > endX - mid ? endX - mid : mid - startX
            guard halfWidth > 0 else {
                return
            }
            let titleWidth = halfWidth * 2
            var titleLableWidth: CGFloat = 0
            if isClickEnable {
                titleLableWidth = titleWidth - 2 * CGFloat(NaviBarMetric.itemWidth)
            } else {
                titleLableWidth = titleWidth
            }

//            if (viewTitle as? LightControl) != nil {
                let font = self.titleLabel?.font
                let size = self.title?.getSize(font: font!, viewWidth: titleLableWidth)
                self.titleLabel?.setViewSize(size ?? .zero)
                    if isClickEnable {
                        viewTitle?.isUserInteractionEnabled = true
                        self.titleLabel?.textColor = .white
                        self.titleLabel?.frame = CGRect(x: NaviBarMetric.itemMargin, y: 0, width: titleLableWidth, height: endY - startY)
                        self.titleArrow?.setViewOrigin(CGPoint(x: (self.titleLabel?.frame.origin.x ?? 0) + (self.titleLabel?.frame.size.width ?? 0) + CGFloat(NaviBarMetric.itemMargin), y: (endY - startY - CGFloat(NaviBarMetric.itemHeight)) / 2))
                    } else {
                        viewTitle?.isUserInteractionEnabled = false
                        self.titleLabel?.frame = CGRect(x: 0, y: 0, width: titleLableWidth, height: endY - startY)
                    }

                self.titleArrow?.isHidden = !isClickEnable
//            }

            //重设frame
            viewTitle?.frame = CGRect(x: (superFrame.size.width - titleWidth) / 2, y: startY, width: titleWidth, height: endY - startY)
        }
    }

    /// 设置标题
    ///
    /// - Parameter title: 标题
    func setTitle(title: String) {
        self.title = title
        if let safeLabel = self.titleLabel {
            safeLabel.text = title
        } else if let btn = self.titleView as? UIButton {
            btn.setTitle(title, for: .normal)
        }
        self.reLayout()
    }

    /// 设置标题颜色
    ///
    /// - Parameter color: 标题颜色
    func setTitleColor(color: UIColor) {
        if let safeLabel = self.titleLabel {
            safeLabel.textColor = color
        } else if let btn = self.titleView as? UIButton {
            btn.setTitleColor(color, for: .normal)
        }
        self.reLayout()
    }
    /// 通过items数组，设置左边的items
    ///
    /// - Parameter barItems: 左边的items数组
    func setLeftBarItems(with barItems: [NaviBarItem]?) {
        guard let items = barItems else {//传过来nil 直接移除
            for item in leftBarItems {
                item.removeFromSuperview()
            }
            leftBarItems = []
            self.reLayout()
            return
        }
        //移除之前的item
        for item in leftBarItems {
            item.removeFromSuperview()
        }
        //遍历新的添加
        for item in items {
            self.addSubview(item)
        }
        leftBarItems = items
        self.reLayout()
    }

    /// 通过items数组，设置右边的items
    ///
    /// - Parameter barItems: 右边的items数组
    func setRightBarItems(with barItems: [NaviBarItem]?) {
        guard let items = barItems else {//传过来nil 直接移除
            for item in rightBarItems {
                item.removeFromSuperview()
            }
            leftBarItems = []
            self.reLayout()
            return
        }
        //移除之前的item
        for item in rightBarItems {
            item.removeFromSuperview()
        }
        //遍历新的添加
        for item in items {
            self.addSubview(item)
        }
        rightBarItems = items
        self.reLayout()
    }
    func getRightBarItems() -> [NaviBarItem]? {
        return rightBarItems
    }
    func getLeftBarItems() -> [NaviBarItem]? {
        return leftBarItems
    }
    /// 设置左边的item
    ///
    /// - Parameter itemNew: 新的item
    func setLeftBarItem(with itemNew: NaviBarItem) {
        for item in leftBarItems {
            item.removeFromSuperview()
        }
        if !(leftBarItems.isEmpty) {
            leftBarItems[0] = itemNew
            self.addSubview(itemNew)
        } else {
            leftBarItems.append(itemNew)
            self.addSubview(itemNew)
        }
        //刷新布局
        self.reLayout()
    }
    /// 设置右边的item
    ///
    /// - Parameter itemNew: 新的item
    func setRightBarItems(with itemNew: NaviBarItem) {
        for item in rightBarItems {
            item.removeFromSuperview()
        }
        if !rightBarItems.isEmpty {
            rightBarItems[0] = itemNew
            self.addSubview(itemNew)
        } else {
            rightBarItems.append(itemNew)
            self.addSubview(itemNew)
        }
        //刷新布局
        self.reLayout()
    }
}

// MARK: - target selectors
extension NaviBar {
    @objc func titleTouchDown() {
        if (viewTitle is LightControl) && self.isClickEnable {
            self.sendActions(for: .touchDown)
        }
    }
    @objc func titleTouchupInside() {
        if (viewTitle is LightControl) && self.isClickEnable {
            self.sendActions(for: .touchUpInside)
        }
    }
    @objc func titleTouchupOutside() {
        if (viewTitle is LightControl) && self.isClickEnable {
            self.sendActions(for: .touchUpOutside)
        }
    }
}
