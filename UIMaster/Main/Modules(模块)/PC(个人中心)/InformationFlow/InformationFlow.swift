import NVActivityIndicatorView
import RxSwift
import UIKit

//  模块通用模板,保持整体完整性，
//  不需要的部分可以先注释掉，之后完成后，再统一删掉
//  可以参考InformationFlow模块，如果涉及到分页显示数据，请参考GroupListTopic模块

class InformationFlow: BaseTableView, PageModuleAble {
    // MARK: 模块相关的配置属性
    private var browsingVolume = 0//浏览量
    private var groupListStyle = 0//群组列表布局样式
    private var messageListTitle = 1//消息列表标题栏
//    private var style = 0//信息流样式
    private var adminMessageArticlesList = 1//文章列表用户信息
    private var articlesList = 0//文章列表布局
    private var articlesListAbstract = 1//文章列表摘要
    private var articlesListAdminHead = 1//文章列表用户头像
    private var articlesListAdminNickName = 1//文章列表用户昵称
    private var articlesListKind = 0//文章列表分类
    private var articlesListOtherText = 1//文章列表其他文字
    private var articlesListTime = 1//文章列表时间
    private var bgColor = "255,255,255,1"//群组列表背景 颜色额
    private var bgColorArticlesList = "255,255,255,1"//文章列表背景 颜色
    private var bgColorMessageList = "255,255,255,1"//消息列表背景 颜色
    private var bgColorSaySomething = "255,255,255,1"//说说背景 颜色额
    private var bgColorSys = "255,255,255,1"//背景 颜色
    private var bgImg = ""//群组列表背景 图片
    private var bgImgArticlesList = ""//文章列表背景 图片
    private var bgImgMessageList = ""//消息列表背景 图片
    private var bgImgMode = 0//群组列表背景 平铺
    private var bgImgModeArticlesList = 0//文章列表背景 平铺
    private var bgImgModeMessageList = 0//消息列表背景 平铺
    private var bgImgModeSaySomething = 0//说说背景 平铺
    private var bgImgModeSys = 0//背景 平铺
    private var bgImgSaySomething = ""//说说北京 图片
    private var bgImgSys = ""//背景 图片
    private var borderColor = "230,230,230,1"//边框 颜色
    private var borderShow = 1//边框 是否显示
    private var borderWidth = 0//边框 宽度
    private var collection = 0//收藏
    private var comment = 1//评论
    private var forward = 1//转发
    private var groupListAbstract = 0//群组列表摘要
    private var groupListAdminHead = 1//群组列表用户头像
    private var groupListAdminMessage = 1//群组列表用户信息
    private var groupListAdminNickName = 1//群组列表用户昵称
    private var groupListGroupHead = 1//群组列表群组头像
    private var groupListGroupNickName = 1//群组昵称
    private var groupListOptionsMenu = 1//群组列表可操作菜单
    private var groupListOtherText = 1//群组列表其他文字
    private var groupListTime = 1//群组列表时间
    private var heightSpacing: CGFloat = 0//项间距
    private var iconTitle = ""//内容  图标
    private var like = 1//点赞
    private var lineHeight = 0//信息流行高
    private var messageListAdminHead = 1//消息列表用户头像
    private var messageListAdminNickName = 1//消息列表用户昵称
    private var messageListReplyButton = 1//消息列表回复按钮
    private var messageListTime = 1//消息列表时间
    private var opacity = 1//群组列表背景 透明度
    private var opacityArticlesList = 1//文章列表背景 透明度
    private var opacityMessageList = 1//消息列表背景 透明度
    private var opacitySaySomething = 1//说说背景 透明度
    private var opacitySys = 1//背景 透明度
    private var optionsButtonStyle = 0//可操作按钮样式
    private var optionsMenu = 1//说说可操作菜单
    private var optionsMenuArticlesList = 1//文章列表可操作菜单
    private var radius: CGFloat = 0//圆角
    private var saySomething = 0//说说样式
    private var saySomethingTitle = 1//说说标题
    private var titleTitle = ""//内容 文字
    private var events: [String: EventsData]?

    weak var moduleDelegate: ModuleRefreshDelegate?
    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let informationFlowModel = InformationFlowModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.browsingVolume = informationFlowModel.fields?.browsingVolume ?? self.browsingVolume
                self.groupListStyle = informationFlowModel.styles?.groupListStyle ?? self.groupListStyle
                self.messageListTitle = informationFlowModel.fields?.messageListTitle ?? self.messageListTitle
//                self.style = informationFlowModel.styles?.style ?? self.style
                self.adminMessageArticlesList = informationFlowModel.fields?.adminMessageArticlesList ?? self.adminMessageArticlesList
                self.articlesList = informationFlowModel.styles?.articlesList ?? self.articlesList
                self.articlesListAbstract = informationFlowModel.fields?.articlesListAbstract ?? self.articlesListAbstract
                self.articlesListAdminHead = informationFlowModel.fields?.articlesListAdminHead ?? self.articlesListAdminHead
                self.articlesListAdminNickName = informationFlowModel.fields?.articlesListAdminNickName ?? self.articlesListAdminNickName
                self.articlesListKind = informationFlowModel.fields?.articlesListKind ?? self.articlesListKind
                self.articlesListOtherText = informationFlowModel.fields?.articlesListOtherText ?? self.articlesListOtherText
                self.articlesListTime = informationFlowModel.fields?.articlesListTime ?? self.articlesListTime
                self.bgColor = informationFlowModel.styles?.bgColor ?? self.bgColor
                self.bgColorArticlesList = informationFlowModel.styles?.bgColorArticlesList ?? self.bgColorArticlesList
                self.bgColorMessageList = informationFlowModel.styles?.bgColorMessageList ?? self.bgColorMessageList
                self.bgColorSaySomething = informationFlowModel.styles?.bgColorSaySomething ?? self.bgColorSaySomething
                self.bgColorSys = informationFlowModel.styles?.bgColorSys ?? self.bgColorSys
                self.bgImg = informationFlowModel.styles?.bgImg ?? self.bgImg
                self.bgImgArticlesList = informationFlowModel.styles?.bgImgArticlesList ?? self.bgImgArticlesList
                self.bgImgMessageList = informationFlowModel.styles?.bgImgMessageList ?? self.bgImgMessageList
                self.bgImgMode = informationFlowModel.styles?.bgImgMode ?? self.bgImgMode
                self.bgImgModeArticlesList = informationFlowModel.styles?.bgImgModeArticlesList ?? self.bgImgModeArticlesList
                self.bgImgModeMessageList = informationFlowModel.styles?.bgImgModeMessageList ?? self.bgImgModeMessageList
                self.bgImgModeSaySomething = informationFlowModel.styles?.bgImgModeSaySomething ?? self.bgImgModeSaySomething
                self.bgImgModeSys = informationFlowModel.styles?.bgImgModeSys ?? self.bgImgModeSys
                self.bgImgSaySomething = informationFlowModel.styles?.bgImgSaySomething ?? self.bgImgSaySomething
                self.bgImgSys = informationFlowModel.styles?.bgImgSys ?? self.bgImgSys
                self.borderColor = informationFlowModel.styles?.borderColor ?? self.borderColor
                self.borderShow = informationFlowModel.styles?.borderShow ?? self.borderShow
                self.borderWidth = informationFlowModel.styles?.borderWidth ?? self.borderWidth
                self.collection = informationFlowModel.fields?.collection ?? self.collection
                self.comment = informationFlowModel.fields?.comment ?? self.comment
                self.forward = informationFlowModel.fields?.forward ?? self.forward
                self.groupListAbstract = informationFlowModel.fields?.groupListAbstract ?? self.groupListAbstract
                self.groupListAdminHead = informationFlowModel.fields?.groupListAdminHead ?? self.groupListAdminHead
                self.groupListAdminMessage = informationFlowModel.fields?.groupListAdminMessage ?? self.groupListAdminMessage
                self.groupListAdminNickName = informationFlowModel.fields?.groupListAdminNickName ?? self.groupListAdminNickName
                self.groupListGroupHead = informationFlowModel.fields?.groupListGroupHead ?? self.groupListGroupHead
                self.groupListGroupNickName = informationFlowModel.fields?.groupListGroupNickName ?? self.groupListGroupNickName
                self.groupListOptionsMenu = informationFlowModel.fields?.groupListOptionsMenu ?? self.groupListOptionsMenu
                self.groupListOtherText = informationFlowModel.fields?.groupListOtherText ?? self.groupListOtherText
                self.groupListTime = informationFlowModel.fields?.groupListTime ?? self.groupListTime
                self.heightSpacing = informationFlowModel.styles?.heightSpacing ?? self.heightSpacing
                self.iconTitle = informationFlowModel.styles?.iconTitle ?? self.iconTitle
                self.like = informationFlowModel.fields?.like ?? self.like
                self.lineHeight = informationFlowModel.styles?.lineHeight ?? self.lineHeight
                self.messageListAdminHead = informationFlowModel.fields?.messageListAdminHead ?? self.messageListAdminHead
                self.messageListAdminNickName = informationFlowModel.fields?.messageListAdminNickName ?? self.messageListAdminNickName
                self.messageListReplyButton = informationFlowModel.fields?.messageListReplyButton ?? self.messageListReplyButton
                self.messageListTime = informationFlowModel.fields?.messageListTime ?? self.messageListTime
                self.opacity = informationFlowModel.styles?.opacity ?? self.opacity
                self.opacityArticlesList = informationFlowModel.styles?.opacityArticlesList ?? self.opacityArticlesList
                self.opacityMessageList = informationFlowModel.styles?.opacityMessageList ?? self.opacityMessageList
                self.opacitySaySomething = informationFlowModel.styles?.opacitySaySomething ?? self.opacitySaySomething
                self.opacitySys = informationFlowModel.styles?.opacitySys ?? self.opacitySys
                self.optionsButtonStyle = informationFlowModel.styles?.optionsButtonStyle ?? self.optionsButtonStyle
                self.optionsMenu = informationFlowModel.fields?.optionsMenu ?? self.optionsMenu
                self.optionsMenuArticlesList = informationFlowModel.fields?.optionsMenuArticlesList ?? self.optionsMenuArticlesList
                self.radius = informationFlowModel.styles?.radius ?? self.radius
                self.saySomething = informationFlowModel.styles?.saySomething ?? self.saySomething
                self.saySomethingTitle = informationFlowModel.fields?.saySomethingTitle ?? self.saySomethingTitle
                self.titleTitle = informationFlowModel.styles?.titleTitle ?? self.titleTitle
                self.events = informationFlowModel.events

                //加载UI
                renderUI()
            }
        }
    }
    var moduleParams: [String: Any]? {
        didSet {
            self.userInfo = moduleParams?[UserInfoData.getClassName] as? UserInfoData
            self.userChatInfo = moduleParams?["PCTuple"] as? (Int64, Int64)
            //获取数据
            reloadViewData()
        }
    }
    //模块特有属性
    private var itemList: [InformationFlowData]?//保存M2请求回来的数据
    private var pageNum: Int = 1//如果涉及到数据分页，需要此变量
    var userChatInfo: (uid: Int64, pid: Int64)?
    var userInfo: UserInfoData?
    private var rowHeightDic = [Int: CGFloat]()
    private var totalHeight: CGFloat = 0
    private var disposeBag = DisposeBag()

    // MARK: init方法
    init(frame: CGRect) {
        super.init(frame: frame, style: .plain)
        self.delegate = self
        self.dataSource = self
        self.register(UINib(nibName: "AddFriendCell", bundle: nil), forCellReuseIdentifier: "addFriend")
        self.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "message")
        NotificationCenter.default.rx.notification(Notification.Name(kPersonalInfoChangeNotification))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                self?.reloadViewData()
            })
            .disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(Notification.Name(kLogoutNotification))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                self?.itemList?.removeAll()
                self?.reloadData()
            })
            .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 网络请求
extension InformationFlow {
    //页面刷新时会调用该方法
    func reloadViewData() {
        //加载更多时，分页数加1，不需要分页可以去掉下面这行
        self.pageNum = 1
        //请求M2数据信息
        if userChatInfo != nil {
            self.requestPCDataByAppKey()
        } else {
            self.requestInformationFlowData()
        }
    }

    func loadMoreData() {
        self.pageNum += 1
        //请求M2数据信息
        if userChatInfo != nil {
            self.requestPCDataByAppKey()
        } else {
            self.requestInformationFlowData()
        }
    }

    //获取个人信息数据
    private func requestPCDataByAppKey() {
        NetworkUtil.request(
            target: .getInfo(user_id: userChatInfo?.uid ?? 0, user_pid: userChatInfo?.pid ?? 0),
            success: { [weak self] json in
                let userInfo = UserInfoModel.deserialize(from: json)?.data
                self?.userInfo = userInfo
                DispatchQueue.main.async {
                    self?.requestInformationFlowData()
                }
            }
        ) { error in
            dPrint(error)
        }
    }

    //获取InformationFlow数据
    private func requestInformationFlowData() {
        let uid = userInfo?.uid ?? UserUtil.share.appUserInfo?.uid ?? 0
        let pid = userInfo?.pid ?? UserUtil.share.appUserInfo?.pid ?? 0

        NetworkUtil.request(
            target: .getMessagePool(page_context: 20, page_index: self.pageNum, user_id: uid, user_pid: pid),
            success: { [weak self] json in
                //如果数据需要分页，使用下面的代码
                let tmpList = InformationFlowDataModel.deserialize(from: json)?.data
                guard let safeTmpList = tmpList, !safeTmpList.isEmpty else {
                    self?.moduleDelegate?.moduleDataDidRefresh(noMore: true)
                    return
                }

                if self?.pageNum == 1 {
                    self?.rowHeightDic.removeAll()
                    self?.itemList = safeTmpList
                } else if let safeList = self?.itemList {
                    self?.itemList = safeList + safeTmpList
                }
                //整理数据
                var tempList = [InformationFlowData]()
                for item in self?.itemList ?? [] {
                    switch item.feed_type ?? 0 {
                    case 3, 11, 12, 24:
                        tempList.append(item)
                    default:
                        break
                    }
                }
                self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
                self?.itemList = tempList
                self?.reloadData()
            }
        ) { [weak self] error in
            self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
            HUDUtil.msg(msg: error, type: .error)
            dPrint(error)
        }
    }
}

//renderUI
extension InformationFlow {
    func renderUI() {
        self.tableFooterView = UIView()
        self.moduleDelegate?.setfullPageTableModule(table: self)
//        self.config()
        self.cornerRadius = self.radius
        self.maskToBounds = true
        self.backgroundColor = self.bgColorSys.toColor()
        self.configRefresh()
//        self.rowHeight = UITableViewAutomaticDimension
//        self.estimatedRowHeight = 200
        self.separatorColor = .clear
    }
}

// MARK: - 代理方法
/**
 1.协议的采纳放到该扩展上。
 2.代理方法统一放到这里，不同的代理用//MARK: 分开
 */
extension InformationFlow: UITableViewDelegate & UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (self.rowHeightDic[indexPath.row] ?? 44) + self.heightSpacing
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.itemList?.count ?? 0

        if let footer = self.mj_footer {
            footer.isHidden = self.itemList?.isEmpty ?? true
        }
        return count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? PostListCell {
            cell.comment()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.itemList?[indexPath.row]
        switch model?.feed_type ?? 0 {
        case 11:
            var cell: PostListCell? = tableView.dequeueReusableCell(withIdentifier: "topicCell") as? PostListCell
            if cell == nil {
                cell = Bundle.main.loadNibNamed("PostListCell", owner: nil, options: nil)?[1] as? PostListCell
            }
            let postModel = TopicData.deserialize(from: model?.object)
            if postModel?.id == nil || postModel?.id == 0 {
                let cell = UITableViewCell()
                cell.textLabel?.text = "帖子已删除"
                cell.detailTextLabel?.text = "该帖子已经被主人删除"
                if self.rowHeightDic[indexPath.row] == nil {
                    self.rowHeightDic[indexPath.row] = 44
                }
                return cell
            }
            cell?.cellModel = postModel
            cell?.delegate = self
            //计算高度
            let otherH: CGFloat = 100
            let imageH = cell?.imageConstraitH.constant ?? 0
            let labelH = cell?.contentConstraintH.constant ?? 0
            //保存高度
            if self.rowHeightDic[indexPath.row] == nil {
                self.rowHeightDic[indexPath.row] = otherH + imageH + labelH + 10
            }
            cell?.events = self.events?[kHeadEvent]
            cell?.spacing = self.heightSpacing
            cell?.selectionStyle = .none
            return cell!
        case 12:
            let cell: MessageCell? = tableView.dequeueReusableCell(withIdentifier: "message") as? MessageCell
            let model = TopicData.deserialize(from: model?.object)
            let size = model?.content.getSizeForString(font: 14, viewWidth: self.width - 24)
            if self.rowHeightDic[indexPath.row] == nil {
                self.rowHeightDic[indexPath.row] = 180 + (size?.height ?? 0) + 0.4
            }
            cell?.topicModel = model
            cell?.selectionStyle = .none
            cell?.spacing = self.heightSpacing
            cell?.events = self.events
            cell?.bottomLine(style: .full, color: .lightGray)
            return cell!
        case 3, 24:
            let cell = tableView.dequeueReusableCell(withIdentifier: "addFriend") as? AddFriendCell
            let userInfo = UserInfoData.deserialize(from: model?.object)
            if self.rowHeightDic[indexPath.row] == nil {
                self.rowHeightDic[indexPath.row] = 110
            }
            cell?.selectionStyle = .none
            cell?.spacing = self.heightSpacing
            cell?.addTime = model?.message_time
            cell?.friendInfo = userInfo
            return cell!
        default:
            if self.rowHeightDic[indexPath.row] == nil {
                self.rowHeightDic[indexPath.row] = 44
            }
            return UITableViewCell()
        }
    }
}

extension InformationFlow: Commentable {
    func comment(topicData: TopicData) {
        let articleEvent = self.events?[kArticleEvent]
        articleEvent?.attachment = [TopicData.getClassName: topicData]
        let result = EventUtil.handleEvents(event: articleEvent)
        EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
    }
}
