import UIKit

class FriendsListModel: BaseData {
    var events: [String: EventsData] = [:]
    var status: Int?
    var styles: FriendsListStyles?
}

class FriendsListStyles: BaseStyleModel {
    var bgImgList: String?
    var groupHeight: CGFloat?
    var opacity: Int?
    var bgImgModeList: Int?
    var bgImgModeReply: Int?
    var opacityList: Int?
    var bgColorReply: String?
    var borderColor: String?
    var listStyle: Int?
    var opacityReply: Int?
    var bgColorList: String?
    var bgImgReply: String?
    var borderShow: Int?
    var borderWidth: Int?
    var heightList: CGFloat?
}

class FriendsList: BaseTableView, PageModuleAble {
    weak var moduleDelegate: ModuleRefreshDelegate?

    // MARK: - 模块相关的配置属性
    private var bgColor = "255,255,255,1.0"//背景 颜色
    private var bgColorList = "255,255,255,1.0"//列表栏背景 颜色
    private var bgColorReply = "255,255,255,1.0"//恢复区背景 颜色
    private var bgImg = ""//背景 图片
    private var bgImgList = ""//列表栏背景 图片
    private var bgImgMode = 0//背景 平铺
    private var bgImgModeList = 0//列表栏背景 平铺
    private var bgImgModeReply = 0//恢复区背景 平铺
    private var bgImgReply = ""//恢复区背景 图片
    private var borderColor = "255,255,255,1"//边框颜色
    private var borderShow = 1//边框是否显示
    private var borderWidth = 0//边框宽度
    private var groupHeight: CGFloat = 40//分组栏 高度
    private var heightList: CGFloat = 40//列表栏行高
    private var listStyle = 0//列表样式
    private var opacity = 1//背景 透明度
    private var opacityList = 1//列表栏背景 透明度
    private var opacityReply = 1//恢复区背景 透明度

    var moduleParams: [String: Any]? {
        didSet {
            self.type = moduleParams?["RelationType"] as? RelationType
            self.userID = moduleParams?["UserID"] as? Int64 ?? UserUtil.share.appUserInfo?.uid
            self.userPID = moduleParams?["UserPID"] as? Int64 ?? UserUtil.share.appUserInfo?.uid
            //获取数据
            reloadViewData()
        }
    }

    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let friendsListModel = FriendsListModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.bgColor = friendsListModel.styles?.bgColor ?? self.bgColor
                self.bgColorList = friendsListModel.styles?.bgColorList ?? self.bgColorList
                self.bgColorReply = friendsListModel.styles?.bgColorReply ?? self.bgColorReply
                self.bgImg = friendsListModel.styles?.bgImg ?? self.bgImg
                self.bgImgList = friendsListModel.styles?.bgImgList ?? self.bgImgList
                self.bgImgMode = friendsListModel.styles?.bgImgMode ?? self.bgImgMode
                self.bgImgModeList = friendsListModel.styles?.bgImgModeList ?? self.bgImgModeList
                self.bgImgModeReply = friendsListModel.styles?.bgImgModeReply ?? self.bgImgModeReply
                self.bgImgReply = friendsListModel.styles?.bgImgReply ?? self.bgImgReply
                self.borderColor = friendsListModel.styles?.borderColor ?? self.borderColor
                self.borderShow = friendsListModel.styles?.borderShow ?? self.borderShow
                self.borderWidth = friendsListModel.styles?.borderWidth ?? self.borderWidth
                self.groupHeight = friendsListModel.styles?.groupHeight ?? self.groupHeight
                self.heightList = friendsListModel.styles?.heightList ?? self.heightList
                self.listStyle = friendsListModel.styles?.listStyle ?? self.listStyle
                self.opacity = friendsListModel.styles?.opacity ?? self.opacity
                self.opacityList = friendsListModel.styles?.opacityList ?? self.opacityList
                self.opacityReply = friendsListModel.styles?.opacityReply ?? self.opacityReply
                self.moduleDelegate?.setfullPageTableModule(table: self)
                //渲染UI
                renderUI()
            }
        }
    }

    // MARK: - 模块特有属性
    private var itemList: [UserInfoData] = []//保存M2请求回来的数据
    private var pageNum: Int = 1//如果涉及到数据分页，需要此变量
    private var userID: Int64? = UserUtil.share.appUserInfo?.uid//用户id
    private var userPID: Int64? = UserUtil.share.appUserInfo?.pid//用户pid
    var type: RelationType?

    // MARK: init方法
    init(frame: CGRect) {
        super.init(frame: frame, style: .plain)
        self.delegate = self
        self.dataSource = self
        self.register(UINib(nibName: "FriendListCell", bundle: nil), forCellReuseIdentifier: "FriendListCell")
        self.configEmptyDataSet()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 网络请求
extension FriendsList {
    //页面刷新时会调用该方法
    func reloadViewData() {
        guard UserUtil.isValid() else {
            PageRouter.shared.router(to: .login)
            return
        }
        self.pageNum = 1
        //请求M2数据信息
        switch type ?? .friends {
        case .friends:
            self.requestFriendsListData()
        case .fans:
            self.getFunsList()
        case .fllow:
            self.getFollowerList()
        default:
            self.requestFriendsListData()
        }
    }

    func loadMoreData() {
        guard UserUtil.isValid() else {
            PageRouter.shared.router(to: .login)
            return
        }
        self.pageNum += 1
        //请求M2数据信息
        switch type ?? .friends {
        case .friends:
            self.requestFriendsListData()
        case .fans:
            self.getFunsList()
        case .fllow:
            self.getFollowerList()
        default:
            self.requestFriendsListData()
        }
    }

    //获取FriendsList数据
    private func requestFriendsListData() {
        guard let uid = userID, let uPid = userPID else {
            return
        }
        NetworkUtil.request(
            target: .getFriendList(user_id: uid, user_pid: uPid, page_context: 20, page_index: self.pageNum),
            success: { [weak self] json in
                self?.mj_header.endRefreshing()
                //请求成功
                //分页
                let tmpList = UserListModel.deserialize(from: json)?.data
                guard let safeTmpList = tmpList else {
                    return
                }
                if self?.pageNum == 1 {
                    self?.itemList = safeTmpList
                } else if let safeList = self?.itemList {
                    self?.mj_footer.endRefreshing()
                    self?.itemList = safeList + safeTmpList
                }
                if tmpList?.isEmpty ?? true {
                    self?.mj_footer.endRefreshingWithNoMoreData()
                }
                //tableview需要刷新数据
                self?.reloadData()
            }
        ) { [weak self] error in
            self?.mj_footer.endRefreshing()
            HUDUtil.msg(msg: "获取数据失败", type: .error)
            dPrint(error)
        }
    }

    //获取粉丝列表
    private func getFunsList() {
        guard let uid = userID, let uPid = userPID else {
            return
        }
        NetworkUtil.request(
            target: .getFanList(user_id: uid, user_pid: uPid, page_context: 20, page_index: self.pageNum),
            success: { [weak self] json in
                self?.mj_header.endRefreshing()
                //请求成功
                //分页
                let tmpList = UserListModel.deserialize(from: json)?.data
                guard let safeTmpList = tmpList else {
                    return
                }
                if self?.pageNum == 1 {
                    self?.itemList = safeTmpList
                } else if let safeList = self?.itemList {
                    self?.mj_footer.endRefreshing()
                    self?.itemList = safeList + safeTmpList
                }
                if tmpList?.isEmpty ?? true {
                    self?.mj_footer.endRefreshingWithNoMoreData()
                }
                //tableview需要刷新数据
                self?.reloadData()
            }
        ) { [weak self] error in
            self?.mj_footer.endRefreshing()
            HUDUtil.msg(msg: "获取数据失败", type: .error)
            dPrint(error)
        }
    }

    //获取关注列表
    private func getFollowerList() {
        guard let uid = userID, let uPid = userPID else {
            return
        }
        NetworkUtil.request(
            target: .getFollowerList(user_id: uid, user_pid: uPid, page_context: 20, page_index: self.pageNum),
            success: { [weak self] json in
                self?.mj_header.endRefreshing()
                //分页
                let tmpList = UserListModel.deserialize(from: json)?.data
                guard let safeTmpList = tmpList else {
                    return
                }
                if self?.pageNum == 1 {
                    self?.itemList = safeTmpList
                } else if let safeList = self?.itemList {
                    self?.mj_footer.endRefreshing()
                    self?.itemList = safeList + safeTmpList
                }
                if tmpList?.isEmpty ?? true {
                    self?.mj_footer.endRefreshingWithNoMoreData()
                }
                //tableview需要刷新数据
                self?.reloadData()
            }
        ) { [weak self]error in
            self?.mj_footer.endRefreshing()
            HUDUtil.msg(msg: "获取数据失败", type: .error)
            dPrint(error)
        }
    }

//    //获取好友列表
//    private func getFriendList() {
//
//        NetworkUtil.request(target: .getFriendList(user_id: userID ?? 0, page_context: 20, page_index: self.pageNum), success: { [weak self] (json) in
//            self?.mj_header.endRefreshing()
//            //请求成功
//            //分页
//            let tmpList = UserListModel.deserialize(from: json)?.data
//            guard let safeTmpList = tmpList else{
//                return
//            }
//            if self?.pageNum == 1 {
//                self?.itemList = safeTmpList
//            } else if let safeList = self?.itemList{
//                self?.mj_footer.endRefreshing()
//                self?.itemList = safeList + safeTmpList
//            }
//            if tmpList?.count == 0 {
//                self?.mj_footer.endRefreshingWithNoMoreData()
//            }
//            //tableview需要刷新数据
//            self?.reloadData()
//
//        }) { [weak self] (error) in
//            self?.mj_footer.endRefreshing()
//            HUDUtil.msg(msg: "获取数据失败", type: .error)
//            dPrint(error)
//        }
//    }
}

// MARK: - UI&事件处理
extension FriendsList {
    //渲染UI
    private func renderUI() {
        self.rowHeight = UITableViewAutomaticDimension
        self.estimatedRowHeight = 44
        self.backgroundColor = self.bgColor.toColor()
        self.tableFooterView = UIView()
        //        self.config()
        self.configRefresh()
    }
}

// MARK: - 代理方法
/**
 1.协议的采纳放到该扩展上。
 2.代理方法统一放到这里，不同的代理用//MARK: 分开
 */
extension FriendsList: UITableViewDelegate & UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.itemList.count) <= 8 {
            if let footer = self.mj_footer {
                footer.isHidden = true
            }
        }
        return self.itemList.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        PageRouter.shared.router(to: PageRouter.RouterPageType.personalCenterT(tuple: (self.itemList[indexPath.row].uid ?? 0, self.itemList[indexPath.row].pid ?? 0)))
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendListCell") as? FriendListCell else {
            return UITableViewCell()
        }
        let item = self.itemList[indexPath.row]
        cell.cellModel = item
        cell.backgroundColor = self.bgColorList.toColor()
        cell.selectionStyle = .none
        return cell
    }
}
