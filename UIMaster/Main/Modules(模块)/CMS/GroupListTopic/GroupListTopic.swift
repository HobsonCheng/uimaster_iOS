//
//  GroupListTopic.swift
//  UIDS
//
//  Created by bai on 2018/1/20.
//  Copyright © 2018年 one2much. All rights reserved.
//

import RxSwift
import UIKit

enum GroupListFunType: String {
    case getGroupByModel = "getGroupByModel"
    case getMyGroupList = "getMyGroupList"
}

class GroupListTopic: BaseTableView, PageModuleAble {
    // MARK: 模块相关的配置属性
    private var maxCount = 3//显示条数
    private var bgColor = "255,255,255,1.0"//背景  颜色
    private var bgColorTitle = "222,222,222,1.0"//标题栏背景 背景颜色
    private var bgImg = ""//背景 图片
    private var bgImgMode = 0//背景 平铺
    private var bgImgModeTitle = 0//标题栏背景 平铺
    private var bgImgTitle = ""//标题栏背景 图片
    private var colorDetail = "42,42,42,1"//群组简介 颜色
    private var colorName = "42,42,42,1"//群组名称 颜色
    private var colorRightTitle = "42,42,42,1"//标题栏右侧文字 颜色
    private var colorTitle = "42,42,42,1"//标题文字 颜色
    private var fontSizeDetail: CGFloat = 16//群组简介 大小
    private var fontSizeName: CGFloat = 16//群组名称 大小
    private var fontSizeRightTitle: CGFloat = 16//标题栏右侧文字 大小
    private var fontSizeTitle: CGFloat = 16//标题文字 大小
    private var heightTitle: CGFloat = 40//标题栏 高度
    private var iconContent = ""//内容 内容区右侧图标
    private var iconTitle = ""//内容 标题 图标
    private var showTypeInfinite = 1//设置样式
    private var splitterColor = "232,232,232,1"//分割线 颜色
    private var splitterWidth: CGFloat = 1//分割线 宽度
    private var text = "222"//内容 标题 群组名称
    private var titleContent = "更多"//内容 内容区右侧图标
    private var titleTitle = "群组列表"//内容 标题 标题······
    private var radius: CGFloat = 0//圆角半径
    private var getFunction = "getGroupByModel"
    private var events: [String: EventsData]?
    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let groupListTopicModel = GroupListTopicModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.maxCount = groupListTopicModel.styles?.maxCount ?? self.maxCount
                self.bgColor = groupListTopicModel.styles?.bgColor ?? self.bgColor
                self.bgColorTitle = groupListTopicModel.styles?.bgColorTitle ?? self.bgColorTitle
                self.bgImg = groupListTopicModel.styles?.bgImg ?? self.bgImg
                self.bgImgMode = groupListTopicModel.styles?.bgImgMode ?? self.bgImgMode
                self.colorDetail = groupListTopicModel.styles?.colorDetail ?? self.colorDetail
                self.colorName = groupListTopicModel.styles?.colorName ?? self.colorName
                self.colorRightTitle = groupListTopicModel.styles?.colorRightTitle ?? self.colorRightTitle
                self.bgImgModeTitle = groupListTopicModel.styles?.bgImgModeTitle ?? self.bgImgModeTitle
                self.bgImgTitle = groupListTopicModel.styles?.bgImgTitle ?? self.bgImgTitle
                self.colorTitle = groupListTopicModel.styles?.colorTitle ?? self.colorTitle
                self.fontSizeDetail = groupListTopicModel.styles?.fontSizeDetail ?? self.fontSizeDetail
                self.fontSizeName = groupListTopicModel.styles?.fontSizeName ?? self.fontSizeName
                self.fontSizeRightTitle = groupListTopicModel.styles?.fontSizeRightTitle ?? self.fontSizeRightTitle
                self.fontSizeTitle = groupListTopicModel.styles?.fontSizeTitle ?? self.fontSizeTitle
                self.heightTitle = groupListTopicModel.styles?.heightTitle ?? self.heightTitle
                self.iconContent = groupListTopicModel.styles?.iconContent ?? self.iconContent
                self.iconTitle = groupListTopicModel.styles?.iconTitle ?? self.iconTitle
                self.showTypeInfinite = groupListTopicModel.fields?.showTypeInfinite ?? self.showTypeInfinite
                self.splitterColor = groupListTopicModel.styles?.splitterColor ?? self.splitterColor
                self.splitterWidth = groupListTopicModel.styles?.splitterWidth ?? self.splitterWidth
                self.text = groupListTopicModel.fields?.text ?? self.text
                self.getFunction = groupListTopicModel.fields?.getFunction ?? self.getFunction
                self.titleContent = groupListTopicModel.styles?.titleContent ?? self.titleContent
                self.titleTitle = groupListTopicModel.styles?.titleTitle ?? self.titleTitle
                self.radius = groupListTopicModel.styles?.radius ?? self.radius
                self.events = groupListTopicModel.events
                //渲染UI
                renderUI()
            }
        }
    }

    weak var moduleDelegate: ModuleRefreshDelegate?
    //模块特有属性
    private var pageNum: Int = 1
    private var itemList: [GroupData]?
    private var userId: Int64?
    private var userPID: Int64?
    var moduleParams: [String: Any]? {
        didSet {
            if let pageKey = moduleParams?["pageKey"] as? String {
                self.pageKey = pageKey
            }
            if let moduleCode = moduleParams?["moduleCode"] as? String {
                self.moduleCode = moduleCode
            }
            userId = moduleParams?["UserID"] as? Int64
            userPID = moduleParams?["UserPID"] as? Int64
            getCacheJson(key: GroupListTopic.getClassName + (self.pageKey ?? "")) { [weak self] json in
                let tmpList = GroupModel.deserialize(from: json)?.data
                self?.itemList = tmpList
                self?.reloadData()
                DispatchQueue.main.async {
                    if self?.showTypeInfinite == 1 {
                        self?.height = CGFloat((self?.maxCount ?? 0) * 100) + (self?.heightTitle ?? 0)
                        //模块高度计算生成完成，回调重排父视图
                        self?.moduleDelegate?.moduleLayoutDidRefresh()
                    }
                }
            }
            //获取数据
            reloadViewData()
        }
    }
    private var isReload = false
    // MARK: - init初始化
    init(frame: CGRect) {
        super.init(frame: frame, style: .plain)
        self.dataSource = self
        self.delegate = self
        self.register(UINib(nibName: "GroupCell", bundle: nil), forCellReuseIdentifier: "GroupTopicCell")
        self.separatorStyle = .none
        NotificationCenter.default.rx.notification(Notification.Name(kReloadGroupNotification)).takeUntil(self.rx.deallocated).subscribe(onNext: {
            [weak self] ntf in
            if let groupData = ntf.object as? GroupData {
                self?.itemList?.insert(groupData, at: 0)
                self?.reloadData()
            } else {
                self?.reload()
            }
        }).disposed(by: rx.disposeBag)
        NotificationCenter.default.rx.notification(Notification.Name(kGroupInfoChangeNotification)).takeUntil(self.rx.deallocated).subscribe(onNext: {
            [weak self] ntf in
            if let groupData = ntf.object as? GroupData {
                self?.itemList = self?.itemList?.map({ data -> GroupData in
                    if groupData.id == data.id {
                        return groupData
                    } else {
                        return data
                    }
                })
                self?.reloadData()
            }
        }).disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
// MARK: - UI布局
extension GroupListTopic {
    //渲染UI
    private func renderUI() {
//        self.config()
        //        activityView.startAnimating()
        self.rowHeight = 100
        self.tableFooterView = UIView()
        self.backgroundColor = self.bgColor.toColor()
        self.separatorColor = self.splitterColor.toColor()
        //模块背景图
        if self.bgImg != ""{
            let imgView = UIImageView(frame: self.bounds)
            imgView.kf.setImage(with: URL(string: self.bgImg))
            self.backgroundView = imgView
        }
        //模块圆角
        self.layer.cornerRadius = self.radius

        if showTypeInfinite == 1 {
            self.isScrollEnabled = false
            //table 的 header
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.heightTitle))
            headerView.backgroundColor = self.bgColorTitle.toColor()
            headerView.bottomLine(style: .full, color: .lightGray)
            //标题
            let titleLabel = UILabel()
            titleLabel.text = self.text
            titleLabel.textColor = self.colorTitle.toColor()
            headerView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.centerY.equalTo(headerView)
                make.left.equalTo(10)
            }
            //更多
            let moreBtn = YJButton()
            headerView.addSubview(moreBtn)
            moreBtn.setTitle(self.titleTitle, for: .normal)
            moreBtn.kf.setImage(with: URL(string: self.iconTitle), for: .normal)
            moreBtn.imagePostion = .right
            moreBtn.imageSize = CGSize(width: self.heightTitle - 20, height: self.heightTitle - 20)
            moreBtn.setTitleColor(self.colorRightTitle.toColor(), for: .normal)
            let moreEvent = self.events?[kMoreEvent]
            moreEvent?.attachment = ["pageKey": self.pageKey ?? "", "moduleCode": self.moduleCode ?? ""]
            moreBtn.event = moreEvent
            moreBtn.addTarget(self, action: #selector(handleMoreEvent(btn:)), for: .touchUpInside)
            moreBtn.snp.makeConstraints { make in
                make.right.equalTo(-17)
                make.centerY.equalTo(headerView)
                make.width.equalTo(150)
            }
            self.tableHeaderView = headerView
        } else {
            self.moduleDelegate?.setfullPageTableModule(table: self)
            self.configRefresh()
        }
    }
    // MARK: 事件处理
    @objc func handleMoreEvent(btn: UIButton) {
        let event = btn.event
        let result = EventUtil.handleEvents(event: event)
        EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
    }
}
// MARK: - 网络请求
extension GroupListTopic {
    //页面刷新时会调用该方法
    func reloadViewData() {
        //加载更多时，分页数加1，不需要分页可以去掉下面这行
        self.pageNum = 1
        //请求M2数据信息
        switch GroupListFunType(rawValue: self.getFunction) ?? .getGroupByModel {
        case .getGroupByModel:
            self.requestGroupListTopicData()
        case .getMyGroupList:
            self.userId == nil ? self.getMyGroupList() : self.getOtherGroupList()
        }
    }

    func loadMoreData() {
        self.pageNum += 1
        //请求M2数据信息
        switch GroupListFunType(rawValue: self.getFunction) ?? .getGroupByModel {
        case .getGroupByModel:
            self.requestGroupListTopicData()
        case .getMyGroupList:
            self.userId == nil ? self.getMyGroupList() : self.getOtherGroupList()
        }
    }

    //重新加载当前数据
    func reload() {
        self.isReload = true
        switch GroupListFunType(rawValue: self.getFunction) ?? .getGroupByModel {
        case .getGroupByModel:
            self.requestGroupListTopicData()
        case .getMyGroupList:
            self.userId == nil ? self.getMyGroupList() : self.getOtherGroupList()
        }
    }
    //获取GroupListTopic数据
    private func requestGroupListTopicData() {
        var page = self.pageNum
        var pageNum = 20
        if isReload {
            page = 1
            pageNum = 20 * self.pageNum
            self.itemList = []
            isReload = false
        }
        NetworkUtil.request(target: .getGroupByModel(group_id: UserUtil.getGroupId(), page_index: page, page_context: pageNum, code: self.moduleCode ?? "", page: self.pageKey ?? ""), success: { [weak self] json in
            if self?.pageNum == 1 {
                self?.cacheJson(key: GroupListTopic.getClassName + (self?.pageKey ?? ""), json: json)
            }
            //请求成功
            //如果数据需要分页，使用下面的代码
            let tmpList = GroupModel.deserialize(from: json)?.data
            guard let safeTmpList = tmpList else {
                return
            }
            if self?.pageNum == 1 {
                self?.itemList = safeTmpList
            } else if let safeList = self?.itemList {
                self?.itemList = safeList + safeTmpList
            }
            if (tmpList?.isEmpty ?? true) && self?.showTypeInfinite == 0 {
                self?.moduleDelegate?.moduleDataDidRefresh(noMore: true)
            } else {
                self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
            }

            self?.reloadData()
            DispatchQueue.main.async {
                if self?.showTypeInfinite == 1 {
                    self?.height = CGFloat((self?.maxCount ?? 0) * 100) + (self?.heightTitle ?? 0)
                    //模块高度计算生成完成，回调重排父视图
                    self?.moduleDelegate?.moduleLayoutDidRefresh()
                }
            }
        }) { error in
            HUDUtil.msg(msg: error, type: .error)
            dPrint(error)
        }
    }
    //获取自己的群组列表
    private func getMyGroupList() {
        var page = self.pageNum
        var pageNum = 20
        if isReload {
            page = 1
            pageNum = 20 * self.pageNum
            self.itemList = []
            isReload = false
        }
        NetworkUtil.request(target: .getMyGroupList(page_index: page, page_context: pageNum), success: { [weak self] json in
            //如果数据需要分页，使用下面的代码
            let tmpList = GroupModel.deserialize(from: json)?.data
            guard let safeTmpList = tmpList else {
                return
            }
            if self?.pageNum == 1 {
                self?.itemList = safeTmpList
            } else if let safeList = self?.itemList {
                self?.itemList = safeList + safeTmpList
            }
            let flag = tmpList?.isEmpty ?? true
            self?.moduleDelegate?.moduleDataDidRefresh(noMore: flag)
            self?.reloadData()
            if self?.showTypeInfinite == 1 {
                self?.height = CGFloat((self?.maxCount ?? 0) * 100) + (self?.heightTitle ?? 0)
            }
            //模块高度计算生成完成，回调重排父视图
            self?.moduleDelegate?.moduleLayoutDidRefresh()
        }) { [weak self] error in
            self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
            HUDUtil.msg(msg: error, type: .error)
            dPrint(error)
        }
    }
    //获取别人的群组列表
    private func getOtherGroupList() {
        var page = self.pageNum
        var pageNum = 20
        if isReload {
            page = 1
            pageNum = 20 * self.pageNum
            self.itemList = []
            isReload = false
        }
        NetworkUtil.request(target: .getOtherGroupList(page_index: page, page_context: pageNum, user_id: self.userId ?? 0, user_pid: self.userPID ?? 0), success: { [weak self] json in
            //如果数据需要分页，使用下面的代码
            let tmpList = GroupModel.deserialize(from: json)?.data
            guard let safeTmpList = tmpList else {
                return
            }
            if self?.pageNum == 1 {
                self?.itemList = safeTmpList
            } else if let safeList = self?.itemList {
                self?.itemList = safeList + safeTmpList
            }
            if (tmpList?.isEmpty ?? true) {
                self?.moduleDelegate?.moduleDataDidRefresh(noMore: true)
            } else {
                self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
            }
            self?.reloadData()
            if self?.showTypeInfinite == 1 {
                self?.height = CGFloat((self?.maxCount ?? 0) * 100) + (self?.heightTitle ?? 0)
            }
            //模块高度计算生成完成，回调重排父视图
            self?.moduleDelegate?.moduleLayoutDidRefresh()
        }) { [weak self] error in
            self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
            HUDUtil.msg(msg: error, type: .error)
            dPrint(error)
        }
    }
}
// MARK: - 代理方法
extension GroupListTopic: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.showTypeInfinite == 1 ? maxCount : (self.itemList?.count ?? 0)
        let trueCount = count > (self.itemList?.count ?? 0) ? (self.itemList?.count ?? 0) : count
        if let footer = self.mj_footer {
            if trueCount <= 4 {
                footer.isHidden = true
            } else {
                footer.isHidden = false
            }
        }
        return trueCount
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let singleEvent = self.events?[kSingleEvent]
        guard let model = self.itemList?[indexPath.row] else {
            return
        }
        singleEvent?.attachment = [GroupData.getClassName: model]
        let result = EventUtil.handleEvents(event: singleEvent)
        EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupTopicCell")
        if let safeCell = cell as? GroupCell {
            safeCell.groupName.textColor = self.colorName.toColor()
            safeCell.groupInfo.textColor = self.colorDetail.toColor()
            safeCell.groupName.font = UIFont.systemFont(ofSize: self.fontSizeName)
            safeCell.groupInfo.font = UIFont.systemFont(ofSize: self.fontSizeDetail)
            safeCell.cellObj = self.itemList?[indexPath.row]
            safeCell.selectionStyle = .none
            safeCell.line.backgroundColor = self.splitterColor.toColor()
            safeCell.line.height = self.splitterWidth
//            safeCell.smallIcon.kf.setBackgroundImage(with: URL.init(string: self.iconContent), for: .normal, placeholder: UIImage.init(named: "cell_arrow"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        return cell!
    }
}
