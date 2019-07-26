//
//  LaunchPad.swift
//  UIDS
//
//  Created by one2much on 2018/1/11.
//  Copyright © 2018年 one2much. All rights reserved.
//

import HandyJSON
import UIKit

///图标方、圆
enum IconShape: Int {
    case square = 1
    case round
}

class LaunchPad: UIView, PageModuleAble {
    private var bgScroll: UIScrollView?
    private var pageControl: UIPageControl?
    private var itemData: [LaunchPadData]?

    //配置项
    private var row = 2 //行
    private var column = 4 //列
    private var marginGap: CGFloat = 16 //图文间距
    private var hasTitle = 1 //是否有文字
    private var isPageControlHidden = 0 //是否隐藏指示器
    private var pageControlColor = "204,204,204,1"//指示器默认颜色
    private var pageControlSelColor = "34,153,238,1"//指示器选中颜色
    private var bgColor = "255,255,255,1" //背景色
    private var shape = IconShape.square //图片形状
    private var radius: CGFloat = 0//模块圆角
    private var bgImage: String = ""//背景图

    weak var moduleDelegate: ModuleRefreshDelegate?
    var styleDic: [String: Any]? {
        didSet {
            guard let launchPadModel = LaunchPadModel.deserialize(from: styleDic) else {
                return
            }
            //背景色
            self.bgColor = launchPadModel.styles?.bgColor ?? self.bgColor
            //行列
            self.row = launchPadModel.styles?.showTypeColumn ?? self.row
            self.column = launchPadModel.styles?.showTypeRow ?? self.column
            //圆角
            self.radius = launchPadModel.styles?.radius ?? self.radius
            //指示器颜色
            self.pageControlColor = launchPadModel.styles?.bgColorIndicator ?? self.pageControlColor
            self.pageControlSelColor = launchPadModel.styles?.bgColorIndicatorSel ?? self.pageControlSelColor
            self.isPageControlHidden = launchPadModel.fields?.sliderTab ?? self.isPageControlHidden
            //背景图
            self.bgImage = launchPadModel.styles?.bgImg ?? self.bgImage
            //形状
            self.shape = IconShape(rawValue: launchPadModel.styles?.showTypeShape ?? 1) ?? self.shape
            //标题
            self.hasTitle = launchPadModel.fields?.sliderText ?? self.hasTitle
            //图文间距
            self.marginGap = launchPadModel.styles?.gap ?? self.marginGap
            //渲染UI
            renderBg()
            getCacheJson(key: LaunchPad.getClassName) { [weak self] json in
                //转成对应的数据模型
                self?.itemData = LaunchPadDataModel.deserialize(from: json)?.data ?? [LaunchPadData]()
                //生成item
                self?.renderItems()
            }
            //获取item数据
            getLaunchPadByModel()
        }
    }

    // MARK: 私有属性
    private var bgImageView: UIImageView?

    // MARK: 初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 网络请求
extension LaunchPad {
    func reloadViewData() {
        getLaunchPadByModel()
    }

    //获取M2数据信息
    private func getLaunchPadByModel() {
        NetworkUtil.request(
            target: .getInitiatorByModel(group_id: UserUtil.getGroupId(), page: self.pageKey ?? "", code: self.moduleCode ?? ""),
            success: { [weak self] jsonStr in
                self?.cacheJson(key: LaunchPad.getClassName, json: jsonStr)
                //转成对应的数据模型
                self?.itemData = LaunchPadDataModel.deserialize(from: jsonStr)?.data ?? [LaunchPadData]()
                //生成item
                self?.renderItems()
                //请求完成，回调告知AssembleVC停止刷新
                DispatchQueue.main.async {
                    self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
                }
            }
        ) { error in
            dPrint(error)
        }
    }
}

// MARK: - UI处理
extension LaunchPad {
    private func renderBg() {
        //背景图
        if !(self.bgImage.isEmpty) {
            bgImageView = UIImageView(frame: self.bounds)
            bgImageView?.kf.setImage(with: URL(string: self.bgImage))
            self.addSubview(bgImageView!)
        }
        self.backgroundColor = self.bgColor.toColor()
        //圆角
        self.layer.cornerRadius = self.radius
        self.layer.masksToBounds = true
        //添加scrollView
        bgScroll = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.width, height: 100))
        bgScroll?.delegate = self
        bgScroll?.showsVerticalScrollIndicator = false
        bgScroll?.showsHorizontalScrollIndicator = false
        bgScroll?.isPagingEnabled = true
        self.addSubview(bgScroll!)

        //添加pageControl
        if isPageControlHidden == 1 {
            pageControl = UIPageControl()
            pageControl?.frame = CGRect(x: 0, y: (bgScroll?.bottom)!, width: self.width, height: 20)
            pageControl?.currentPage = 0
            pageControl?.pageIndicatorTintColor = pageControlColor.toColor()
            pageControl?.currentPageIndicatorTintColor = pageControlSelColor.toColor()
            self.addSubview(pageControl!)
        }
    }

    private func renderItems() {
        //移除scrollView
        self.bgScroll?.removeAllSubviews()
        //单页item数量
        let onePageNum = self.row * self.column
        //保存单页的item
        var singleList = [LaunchPadData]()
        //保存singleList
        var groupList = [[LaunchPadData]]()
        //遍历itemData，将数据分组保存在groupList中
        for (index, item) in (self.itemData ?? []).enumerated() {
            singleList.append(item)
            if singleList.count == onePageNum {//如果单页满了，添加到组中，清空单页数组
                groupList.append(singleList)
                singleList = []
            } else if (index + 1) == self.itemData?.count {//如果是最后一页，添加到组中
                groupList.append(singleList)
            }
        }

        //每个按钮配置项
        var config = CustomButtonConfig()
        config.hasTitle = self.hasTitle
        config.margin = CGFloat(self.marginGap)
        config.imagePosition = .left
        config.imageWidth = 50
        config.imageHeight = 50
        config.titleHeight = 15
        config.shape = self.shape
        //每个按钮宽高
        let itemWidth = self.width / CGFloat(column)
        let itemHeight: CGFloat = config.imageHeight + 2 * config.margin + (hasTitle == 0 ? 0 : config.titleHeight)
        //总高度
        var totalHeight: CGFloat = 0
        //生成item
        for (groupIndex, groupItem) in groupList.enumerated() {
            for (index, item) in groupItem.enumerated() {
                let startX = self.width * CGFloat(groupIndex) + itemWidth * CGFloat(index % column)
                let startY = CGFloat(index / self.column) * itemHeight
                config.title = item.fields?.title ?? ""
                config.imageUrl = item.fields?.normalIcon ?? ""
                let btn = CustomButton(frame: CGRect(x: startX, y: startY, width: itemWidth, height: itemHeight), config: config)
                btn.event = item.events?["click"]
                btn.addTarget(self, action: #selector(handleEvent), for: .touchUpInside)
                bgScroll?.addSubview(btn)
                totalHeight = totalHeight > btn.bottom ? totalHeight : btn.bottom
            }
        }

        //设置页面指示器
        pageControl?.numberOfPages = groupList.count
        pageControl?.top = totalHeight
        pageControl?.isHidden = groupList.count == 1 ? true : false
        pageControl?.isEnabled = false
        //总高度是否添加指示器高度
        totalHeight = groupList.count == 1 || isPageControlHidden == 1 ? totalHeight + marginGap : totalHeight + 20 + marginGap
        //调整scroll
        bgScroll?.height = CGFloat(totalHeight)
        bgScroll?.contentSize = CGSize(width: Int(self.width) * groupList.count, height: 0)
        bgImageView?.height = bgScroll?.height ?? 0
        //设置总高度
        //self.height = self.itemData?.count ?? 1 < self.column ? totalHeight + self.marginGap : totalHeight
        //模块高度计算生成完成，回调重排父视图
        //guard let callBack = reloadMainScrollCB else {
        //      return
        //}
        //callBack()
    }

    // MARK: 事件处理
    @objc func handleEvent(btn: CustomButton) {
        let result = EventUtil.handleEvents(event: btn.event)
        EventUtil.eventTrigger(with: result, on: self, delegate: nil)
    }
}

// MARK: - UIScrollView 代理方法
extension LaunchPad: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = (self.bgScroll?.contentOffset.x ?? 0) / self.width
        pageControl?.currentPage = Int(page)
    }
}
