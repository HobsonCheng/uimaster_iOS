import NVActivityIndicatorView
import RxSwift
import UIKit

enum PostListFuncType: String {
    case article = "getArticleByModel"
    case invitationList = "getInvitationList"
    case topInvitation = "getInvitationTopListByGroup"
    case getCreatedInvitationListByUser = "getCreatedInvitationListByUser"
}

class PostList: BaseNameVC, PageModuleAble {
    // MARK: 模块相关的配置属性
    private var listStyle = 0//列表布局
    private var abstract = 1//摘要
    private var admin = 0//布局 用户信息
    private var bgColor = "255,255,255,1"//项背景 颜色
    private var bgColorSys = "255,255,255,1"//整体背景 颜色
    private var bgImg = ""//项背景 图片
    private var bgImgMode = 0//项背景 平铺
    private var bgImgModeSys = 0//整体背景 平铺
    private var bgImgSys = ""//整体背景 图片
    private var branchesNumber = 3//展示条数
    private var buttonImage = ""//标题栏 更多 图标
    private var buttonStyle = 1//标题栏 显示按钮
    private var buttonTitle = "更多"//标题栏 更多 显示文字
    private var classify = 1//分类
    private var collectButton = 1//收藏
    private var commentButton = 1//评论
    private var editButton = 1//布局 编辑按钮
    private var head = 1//用户头像
    private var icon = ""//标题栏 图标
    private var likeButton = 1//点赞
    private var limit = 0//限制条数
    private var lineHeight = 0//行高
    private var more = 1//更多
    private var nickName = 1//用户昵称
    private var otherWords = 1//其他文字
    private var pageViewButton = 1//浏览量
    private var radius: CGFloat = 0//圆角
    private var spacing: CGFloat = 5//项间距
    private var time = 1//时间
    private var titleContent = "话题列表"//标题栏 文字
    private var transmitButton = 1//转发
    private var heightTitle: CGFloat = 40
    private var bgColorTitle = "255,255,255,1.0"
    private var colorTitle = "44,44,44,1.0"
    private var fontSizeRightTitle: CGFloat = 16
    private var colorRightTitle = "156,156,156,1.0"
    private var functype: PostListFuncType = .article
    private var moreEvent: EventsData?
    private var singEvent: EventsData?
    private var headEvent: EventsData?

    weak var moduleDelegate: ModuleRefreshDelegate?
    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            guard let postListModel = PostListModel.deserialize(from: styleDic) else {
                return
            }
            //由数据模型给模块配置项赋值
            self.listStyle = postListModel.styles?.listStyle ?? self.listStyle
            self.abstract = postListModel.fields?.abstract ?? self.abstract
            self.admin = postListModel.fields?.admin ?? self.admin
            self.bgColor = postListModel.styles?.bgColor ?? self.bgColor
            self.bgColorSys = postListModel.styles?.bgColorSys ?? self.bgColorSys
            self.bgImg = postListModel.styles?.bgImg ?? self.bgImg
            self.bgImgMode = postListModel.styles?.bgImgMode ?? self.bgImgMode
            self.bgImgModeSys = postListModel.styles?.bgImgModeSys ?? self.bgImgModeSys
            self.bgImgSys = postListModel.styles?.bgImgSys ?? self.bgImgSys
            self.branchesNumber = postListModel.styles?.branchesNumber ?? self.branchesNumber
            self.buttonImage = postListModel.fields?.buttonImage ?? self.buttonImage
            self.buttonStyle = postListModel.fields?.buttonStyle ?? self.buttonStyle
            self.buttonTitle = postListModel.fields?.buttonTitle ?? self.buttonTitle
            self.classify = postListModel.fields?.classify ?? self.classify
            self.collectButton = postListModel.fields?.collectButton ?? self.collectButton
            self.commentButton = postListModel.fields?.commentButton ?? self.commentButton
            self.editButton = postListModel.fields?.editButton ?? self.editButton
            self.head = postListModel.fields?.head ?? self.head
            self.icon = postListModel.styles?.icon ?? self.icon
            self.likeButton = postListModel.fields?.likeButton ?? self.likeButton
            self.limit = postListModel.fields?.limit ?? self.limit
            self.lineHeight = postListModel.styles?.lineHeight ?? self.lineHeight
            self.more = postListModel.fields?.more ?? self.more
            self.nickName = postListModel.fields?.nickName ?? self.nickName
            self.otherWords = postListModel.fields?.otherWords ?? self.otherWords
            self.pageViewButton = postListModel.fields?.pageViewButton ?? self.pageViewButton
            self.radius = postListModel.styles?.radius ?? self.radius
            self.spacing = postListModel.styles?.spacing ?? self.spacing
            self.time = postListModel.fields?.time ?? self.time
            self.titleContent = postListModel.styles?.title ?? self.titleContent
            self.transmitButton = postListModel.fields?.transmitButton ?? self.transmitButton
            self.functype = PostListFuncType(rawValue: (postListModel.fields?.getFunction ?? "getArticelByModel")) ?? .article
            self.moreEvent = postListModel.moreEvent
            self.singEvent = postListModel.events?[kSingleEvent]
            self.headEvent = postListModel.events?[kHeadEvent]

             if limit == 0 {
                self.moduleDelegate?.setfullPageTableModule(table: self.listTableView)
            }
            self.renderUI()
        }
    }

    var moduleParams: [String: Any]? {
        didSet {
            if let groupData = moduleParams?[GroupData.getClassName] as? GroupData {
                self.groupData = groupData
            }
            if let pageKey = moduleParams?["pageKey"] as? String {
                self.pageKey = pageKey
            }
            if let moduleCode = moduleParams?["moduleCode"] as? String {
                self.moduleCode = moduleCode
            }
            //取缓存
            self.getCacheJson(key: self.functype.rawValue + "\(groupData?.id ?? -1)" + "\(self.pageKey ?? "")" + "\(self.moduleCode ?? "")") { json in
                self.itemList = TopicModel.deserialize(from: json)?.data
                self.listTableView.reloadData()
                self.moduleDelegate?.moduleLayoutDidRefresh()
            }
            //拉数据
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reloadViewData()
            }
        }
    }
    //tableView
    lazy var listTableView: BaseTableView = {
        let listTableView = BaseTableView(frame: CGRect.zero, style: .plain)
        listTableView.configRefresh()
        listTableView.parentVC = self
        listTableView.mj_footer.isHidden = true
        listTableView.dataSource = self
        listTableView.delegate = self
        listTableView.backgroundColor = UIColor.clear
        listTableView.separatorStyle = .none
        self.view.addSubview(listTableView)
        listTableView.snp.makeConstraints({ make in
            make.left.right.top.bottom.equalToSuperview()
        })
        return listTableView
    }()
    ///加载中遮罩
    lazy var activityView = { () -> NVActivityIndicatorView in
        let padding = kScreenW - 170
        let activityView = NVActivityIndicatorView(frame: self.view.bounds, type: NVActivityIndicatorType.circleStrokeSpin, color: UIColor(red: 82, green: 82, blue: 82), padding: padding)
        activityView.backgroundColor = .white
        self.view.addSubview(activityView)
        activityView.snp.makeConstraints({ make in
            make.left.top.right.bottom.equalToSuperview()
        })
        return activityView
    }()
    //模块特有属性
    private var itemList: [TopicData]?//保存M2请求回来的数据
    private var pageNum: Int = 1//如果涉及到数据分页，需要此变量
    private var rowHeightDic = [Int: CGFloat]()
    private var isReload = false//重新加载一遍数据，不发送网络请求

    var groupData: GroupData?//所在的群组
    var doPid: Int?//获取我的发帖列表时的参数
    /// 是否为分页列表 true是 false不是 默认false
    var isPageList: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        //渲染UI

//        self.activityView.startAnimating()
        //监听文章发表
        NotificationCenter.default.rx.notification(Notification.Name(kPostListRefreshNotification)).takeUntil(self.rx.deallocated).subscribe(onNext: {
            [weak self] ntf in
            if let groupData = ntf.object as? GroupData {
                if self?.groupData?.id != groupData.id {
                    return
                }
            }
            self?.reload()
        }).disposed(by: rx.disposeBag)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        dPrint("\(self.functype.rawValue) die")
    }
}

// MARK: - 网络请求
extension PostList {
    //页面刷新时会调用该方法
    func reloadViewData() {
         self.pageNum = 1
        chooseFun()
    }
    //加载更多
    func loadMoreData() {
        self.pageNum += 1
        chooseFun()
    }
    //重新加载当前数据
    func reload() {
        self.isReload = true
        chooseFun()
    }
    func chooseFun() {
        switch self.functype {
        case .article:
            self.requestArticleListData()
        case .invitationList:
            self.requestTopicListData()
        case .topInvitation:
            self.requestInvitationTopListByGroup()
        case .getCreatedInvitationListByUser:
            self.getCreatedInvitationListByUser()
        }
    }
    //获取ArticleList列表
    private func requestArticleListData() {
        var pageIndex = self.pageNum
        var pageCon = 20
        let code = self.moduleCode ?? ""
        let pageKey = self.pageKey ?? ""
        if isReload {
            pageIndex = 1
            pageCon = 20 * self.pageNum
            self.itemList = []
            self.rowHeightDic.removeAll()
            isReload = false
        }
        NetworkUtil.request(target: .getArticleByModel(group_id: UserUtil.getGroupId(), page: pageKey, code: code, page_index: pageIndex, page_context: pageCon), success: { [weak self] json in
            if pageIndex == 1 {
                self?.cacheJson(key: (self?.functype.rawValue ?? "") + "\(self?.groupData?.id ?? -1)" + "\(self?.pageKey ?? "")" + "\(self?.moduleCode ?? "")", json: json)
            }
            //请求成功
            let tmpList = TopicModel.deserialize(from: json)?.data
            if let safeTmpList = tmpList {
                if self?.pageNum == 1 {
                    self?.itemList = safeTmpList
                } else if let safeList = self?.itemList {
                    self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
                    self?.itemList = safeList + safeTmpList
                }
            } else {
                self?.itemList = []
            }
            if (tmpList?.isEmpty ?? true) && self?.limit == 0 {
                self?.moduleDelegate?.moduleDataDidRefresh(noMore: true)
            } else {
                self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
            }
            self?.listTableView.reloadData()
            self?.activityView.stopAnimating()
        }) { [weak self] error in
            self?.activityView.stopAnimating()
            self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
            HUDUtil.msg(msg: error, type: .error)
            dPrint(error)
        }
    }
    //获取帖子列表
    private func requestTopicListData() {
        var pageIndex = self.pageNum
        var pageCon = 20
        let groupID = self.groupData?.id ?? 0
        let groupPid = self.groupData?.pid ?? 0
        if isReload {
            pageIndex = 1
            pageCon = 20 * self.pageNum
            self.itemList = []
            self.rowHeightDic.removeAll()
            isReload = false
        }
        NetworkUtil.request(target: .getInvitationList(group_id: groupID, group_pid: groupPid, page_index: pageIndex, page_context: pageCon), success: { [weak self] json in
            if pageIndex == 1 {
                self?.cacheJson(key: (self?.functype.rawValue ?? "") + "\(self?.groupData?.id ?? -1)" + "\(self?.pageKey ?? "")" + "\(self?.moduleCode ?? "")", json: json)
            }
            let tmpList = TopicModel.deserialize(from: json)?.data
            if let safeTmpList = tmpList {
                if self?.pageNum == 1 {
                    self?.itemList = safeTmpList
                } else if let safeList = self?.itemList {
                    self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
                    self?.itemList = safeList + safeTmpList
                }
            } else {
                self?.itemList = []
            }
            if (tmpList?.isEmpty ?? true) && self?.limit == 0 {
                self?.moduleDelegate?.moduleDataDidRefresh(noMore: true)
            } else {
                self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
            }
            self?.listTableView.reloadData()
            self?.activityView.stopAnimating()
        }) { [weak self] error in
            self?.activityView.stopAnimating()
            self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
            HUDUtil.msg(msg: error, type: .error)
            dPrint(error)
        }
    }

    //获取置顶帖子列表
    private func requestInvitationTopListByGroup() {
        let id = self.groupData?.id ?? 0
        let pid = self.groupData?.pid ?? 0
        var pageIndex = self.pageNum
        var pageCon = 20
        if isReload {
            pageIndex = 1
            pageCon = 20 * self.pageNum
            self.itemList = []
            self.rowHeightDic.removeAll()
            isReload = false
        }
        NetworkUtil.request(target: .getInvitationTopListByGroup(page_context: pageCon, page_index: pageIndex, group_pid: pid, cms_group_id: id), success: { [weak self] json in
            self?.activityView.stopAnimating()
            if pageIndex == 1 {
                self?.cacheJson(key: (self?.functype.rawValue ?? "") + "\(self?.groupData?.id ?? -1)" + "\(self?.pageKey ?? "")" + "\(self?.moduleCode ?? "")", json: json)
            }
            let tmpList = TopicModel.deserialize(from: json)?.data
            if let safeTmpList = tmpList {
                if self?.pageNum == 1 {
                    self?.itemList = safeTmpList
                } else if let safeList = self?.itemList {
                    self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
                    self?.itemList = safeList + safeTmpList
                }
            } else {
                self?.itemList = []
            }
            if (tmpList?.isEmpty ?? true) && self?.limit == 0 {
                self?.view.height = 0
                self?.moduleDelegate?.moduleDataDidRefresh(noMore: true)
            } else {
                self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
            }
            if (self?.itemList?.isEmpty ?? true) {
                self?.view.height = 0
                self?.moduleDelegate?.moduleLayoutDidRefresh()
                return
            }
            self?.listTableView.reloadData()
        }) { [weak self] error in
            self?.activityView.stopAnimating()
            self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
            HUDUtil.msg(msg: error, type: .error)
            dPrint(error)
        }
    }

    //获取我的帖子列表
    private func getCreatedInvitationListByUser() {
        var pageIndex = self.pageNum
        var pageCon = 20
        if isReload {
            pageIndex = 1
            pageCon = 20 * self.pageNum
            self.itemList = []
            self.rowHeightDic.removeAll()
            isReload = false
        }
        NetworkUtil.request(target: .getCreatedInvitationListByUser(page_index: pageIndex, page_context: pageCon), success: { [weak self] json in
            if pageIndex == 1 {
                self?.cacheJson(key: (self?.functype.rawValue ?? "") + "\(self?.groupData?.id ?? -1)" + "\(self?.pageKey ?? "")" + "\(self?.moduleCode ?? "")", json: json)
            }
            let tmpList = TopicModel.deserialize(from: json)?.data
            if let safeTmpList = tmpList {
                if self?.pageNum == 1 {
                    self?.itemList = safeTmpList
                } else if let safeList = self?.itemList {
                    self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
                    self?.itemList = safeList + safeTmpList
                }
            } else {
                self?.itemList = []
            }
            if (tmpList?.isEmpty ?? true) && self?.limit == 0 {
                self?.moduleDelegate?.moduleDataDidRefresh(noMore: true)
                self?.listTableView.mj_footer.endRefreshingWithNoMoreData()
            } else {
                self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
            }
            self?.listTableView.reloadData()
            self?.activityView.stopAnimating()
        }) { [weak self] error in
            self?.activityView.stopAnimating()
            self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
            HUDUtil.msg(msg: error, type: .error)
            dPrint(error)
        }
    }
}

// MARK: - UI&事件处理
extension PostList {
    //渲染UI
    fileprivate func renderUI() {
        // 背景色
        self.view.backgroundColor = .clear
        self.listTableView.backgroundColor = self.bgColorSys.toColor()
        // 背景图
        if self.bgImg != ""{
            let imgView = UIImageView(frame: self.view.bounds)
            imgView.kf.setImage(with: URL(string: self.bgImg))
            self.listTableView.backgroundView = imgView
        }
        // 圆角
        self.view.layer.cornerRadius = self.radius

        if limit == 1 {
            //table 的 header
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.heightTitle))
            headerView.backgroundColor = self.bgColorTitle.toColor()
            headerView.bottomLine(style: .full, color: .lightGray)
            // icon
            let titleIcon = UIImageView()
            headerView.addSubview(titleIcon)
            titleIcon.kf.setImage(with: URL(string: self.icon))
            titleIcon.snp.makeConstraints { make in
                make.centerY.equalTo(headerView)
                make.height.width.equalTo(17)
                make.left.equalTo(15)
            }
            //标题
            let titleLabel = UILabel()
            titleLabel.text = self.titleContent
            titleLabel.textColor = self.colorTitle.toColor()
            headerView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.centerY.equalTo(headerView)
                make.left.equalTo(titleIcon.snp.right)
            }

            //更多
            if more == 1 {
                let moreBtn = UIButton()
                headerView.addSubview(moreBtn)
                moreBtn.setYJText(prefixText: self.buttonTitle, icon: .nextArrow, postfixText: "", size: self.fontSizeRightTitle, forState: .normal)
                moreBtn.setTitleColor(self.colorRightTitle.toColor(), for: .normal)
                moreBtn.snp.makeConstraints { make in
                    make.right.equalTo(-14)
                    make.centerY.equalTo(headerView)
                }
                moreBtn.addTarget(self, action: #selector(showMore), for: .touchUpInside)
            }
            self.listTableView.tableHeaderView = headerView
            self.listTableView.isScrollEnabled = false
        }
//        else{
//            self.height = self.superview?.height ?? 0
            self.moduleDelegate?.moduleLayoutDidRefresh()
//        }

    }

    // MARK: 事件处理
    @objc func showMore() {
        let event = self.moreEvent
        event?.attachment = ["pageKey": self.pageKey ?? "", "moduleCode": self.moduleCode ?? ""]
        if let groupData = self.groupData {
            event?.attachment["GroupData"] = groupData
        }
        let result = EventUtil.handleEvents(event: event)
        EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
    }
}

// MARK: - 代理方法
extension PostList: UITableViewDelegate, UITableViewDataSource, Commentable {
    func comment(topicData: TopicData) {
        let singleEvent = self.singEvent
        singleEvent?.attachment = [TopicData.getClassName: topicData]
        let result = EventUtil.handleEvents(event: singleEvent)
        EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cellHeight = self.rowHeightDic[indexPath.row] {
            return cellHeight + 2 * spacing
        }
        return 44 + 2 * spacing
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.limit == 1 ? branchesNumber : (self.itemList?.count ?? 0)
        let dataCount = self.itemList?.count ?? 0
        let trueCount = count > dataCount ? dataCount : count
        if limit == 1 {
            switch listStyle {
            case 0:
                let height = 115 * trueCount
                let totalHeight = CGFloat(height) + self.heightTitle
                self.view.height = totalHeight == self.heightTitle ? 0 : totalHeight
                self.moduleDelegate?.moduleLayoutDidRefresh()
            case 1:
                break
            case 2:
                let height = 44 * trueCount
                let totalHeight = CGFloat(height) + self.heightTitle
                self.view.height = totalHeight == self.heightTitle ? 0 : totalHeight
                self.moduleDelegate?.moduleLayoutDidRefresh()
            default:
                let height = 44 * trueCount
                self.view.height = CGFloat(height)
                self.moduleDelegate?.moduleLayoutDidRefresh()
            }
        }
        if let footer = self.listTableView.mj_footer {
            if trueCount <= 4 {
                footer.isHidden = true
            } else {
                footer.isHidden = false
            }
        }
        return trueCount
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = self.itemList?[indexPath.row] else {
            return
        }
        PageRouter.shared.router(to: PageRouter.RouterPageType.articelDetail(model: model, cell: tableView.cellForRow(at: indexPath) as? PostListCell))
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let safeList = self.itemList else {
            return UITableViewCell()
        }
        var identifier = ""
        switch listStyle {
        case 0:
            identifier = "newsCell"
        case 1:
            identifier = "topicCell"
        case 2:
            identifier = "newsTopCell"
        default:
            break
        }

        let model = safeList[indexPath.row]
        var cell = PostListCell()
        if let safeCell = tableView.dequeueReusableCell(withIdentifier: identifier) as? PostListCell {
            cell = safeCell
        } else {
            let cells = Bundle.main.loadNibNamed("PostListCell", owner: nil, options: nil) ?? []
            cell = cells[listStyle] as? PostListCell ?? PostListCell()
            cell.bottomLine(style: .leftGap(margin: 10), color: .lightGray)
        }
        cell.spacing = spacing
        cell.cellModel = model

        cell.events = self.headEvent
        cell.delegate = self
        cell.selectionStyle = .none

        if self.rowHeightDic[indexPath.row] == nil {
            if listStyle == 0 {
                self.rowHeightDic[indexPath.row] = 115
            } else if listStyle == 1 {
                let otherH: CGFloat = 100
                let imageH = cell.imageConstraitH.constant
                let labelH = cell.contentConstraintH.constant
                self.rowHeightDic[indexPath.row] = otherH + imageH + labelH + 10
            } else if listStyle == 2 {
                self.rowHeightDic[indexPath.row] =  44
            }
        }
        return cell
    }
}
