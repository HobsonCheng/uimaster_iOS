//  模块通用模板,保持整体完整性，
//  不需要的部分可以先注释掉，之后完成后，再统一删掉
//  可以参考Comment模块，如果涉及到分页显示数据，请参考GroupListTopic模块

import RxSwift
import UIKit

class Comment: BaseTableView, PageModuleAble {
    // MARK: - 模块相关的配置属性
    private var bgColor = "255,255,255,1"//背景 颜色
    private var bgColorReply = "233,233,233,1"//回复区背景 颜色
    private var bgImg = ""//背景 图片
    private var bgImgMode = 0//背景 平铺
    private var bgImgModeReply = 0//回复区背景 平铺
    private var bgImgReply = ""//回复区背景 图片
    private var borderColor = "232,232,232,1"//边框 颜色
    private var borderShow = 1//边框 是否显示
    private var borderWidth = 0//边框 宽度
    private var branchesNumber = 10//展示条数
    private var commentStyle = 0//评论样式
    private var likeButton = 1//操作按钮 先赞
    private var limit = 1//限制条数
    private var more = 1//更多
    private var opacity = 1//背景 透明度
    private var opacityReply = 1//恢复区背景 透明度
    private var radius: CGFloat = 10//模块圆角
    private var replyButton = 1//操作按钮 回复
    private var replyStyle = 0//回复样式
    private var splitterColor = "232,232,232,1"//分割线 颜色
    private var splitterType = "solid"//分割线 样式
    private var splitterWidth = 1//分割线宽度
    private var splitterShow = 1//分隔线是否显示
    private var transmitButton = 1//操作按钮 转发
    private var heightTitle: CGFloat = 40//标题栏 高度
    private var bgColorTitle = "222,222,222,1.0"//标题栏背景 背景颜色
    private var titleTitle = "评论列表"//内容 标题 标题······
    private var colorTitle = "42,42,42,1"//标题文字 颜色
    private var titleContent = "更多"//内容 内容区右侧图标
    private var colorRightTitle = "42,42,42,1"//标题栏右侧文字 颜色
    private var fontSizeRightTitle: CGFloat = 16//标题栏右侧文字 大小
    private var events: [String: EventsData]?

    weak var moduleDelegate: ModuleRefreshDelegate?
    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let commentModel = CommentModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
//                self.listStyle = commentModel.styles?.listStyle ?? self.listStyle
//                self.abstract = commentModel.fields?.abstract ?? self.abstract
//                self.admin = commentModel.fields?.admin ?? self.admin
                self.bgColor = commentModel.styles?.bgColor ?? self.bgColor
                self.bgColorReply = commentModel.styles?.bgColorReply ?? self.bgColorReply
//                self.bgColorSys = commentModel.styles?.bgColorSys ?? self.bgColorSys
                self.bgImg = commentModel.styles?.bgImg ?? self.bgImg
                self.splitterColor = commentModel.styles?.splitterColor ?? self.splitterColor
                self.splitterWidth = commentModel.styles?.splitterWidth ?? self.splitterWidth
                self.bgImgMode = commentModel.styles?.bgImgMode ?? self.bgImgMode
//                self.bgImgModeSys = commentModel.styles?.bgImgModeSys ?? self.bgImgModeSys
//                self.bgImgSys = commentModel.styles?.bgImgSys ?? self.bgImgSys
                self.branchesNumber = commentModel.styles?.branchesNumber ?? self.branchesNumber
//                self.buttonImage = commentModel.fields?.buttonImage ?? self.buttonImage
//                self.buttonStyle = commentModel.fields?.buttonStyle ?? self.buttonStyle
//                self.buttonTitle = commentModel.fields?.buttonTitle ?? self.buttonTitle
//                self.classify = commentModel.fields?.classify ?? self.classify
//                self.collectButton = commentModel.fields?.collectButton ?? self.collectButton
//                self.commentButton = commentModel.fields?.commentButton ?? self.commentButton
//                self.editButton = commentModel.fields?.editButton ?? self.editButton
//                self.head = commentModel.fields?.head ?? self.head
//                self.icon = commentModel.styles?.icon ?? self.icon
                self.likeButton = commentModel.fields?.likeButton ?? self.likeButton
                self.limit = commentModel.fields?.limit ?? self.limit
//                self.lineHeight = commentModel.styles?.lineHeight ?? self.lineHeight
                self.more = commentModel.fields?.more ?? self.more
//                self.nickName = commentModel.fields?.nickName ?? self.nickName
//                self.otherWords = commentModel.fields?.otherWords ?? self.otherWords
//                self.pageViewButton = commentModel.fields?.pageViewButton ?? self.pageViewButton
                self.radius = commentModel.styles?.radius ?? self.radius
//                self.spacing = commentModel.styles?.spacing ?? self.spacing
//                self.time = commentModel.fields?.time ?? self.time
//                self.title = commentModel.styles?.title ?? self.title
                self.transmitButton = commentModel.fields?.transmitButton ?? self.transmitButton
                self.events = commentModel.events

                //渲染UI
                renderUI()
            }
        }
    }

    // MARK: - 模块特有属性
    private var itemList: [ReplyData]?//保存M2请求回来的数据
    private var pageNum: Int = 1//如果涉及到数据分页，需要此变量
    var moduleParams: [String: Any]? {
        didSet {
            self.topicData = moduleParams?[TopicData.getClassName] as? TopicData
            self.replyData = moduleParams?[ReplyData.getClassName] as? ReplyData
            if let replyData = moduleParams?[ReplyData.getClassName + "Notification"] as? ReplyData {
                self.itemList = [replyData]
                self.reloadData()
                return
            }
            //获取数据
            reloadViewData()
        }
    }
    fileprivate var topicData: TopicData? //接受外界传来的帖子数据
    fileprivate var replyData: ReplyData? //接受外界传来的父级评论数据  或者保存推送过来的评论信息
    fileprivate var cellHeightArr = [CGFloat]()
    fileprivate var trueCount: Int?
    fileprivate var reload: Bool?
    // MARK: init方法
    init(frame: CGRect) {
        super.init(frame: frame, style: .plain)
        self.dataSource = self
        self.delegate = self
        self.separatorStyle = .none
        self.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        NotificationCenter.default.rx.notification(Notification.Name(kDidCommentNotification)).takeUntil(self.rx.deallocated).subscribe(onNext: {
            [weak self] _ in
            self?.reload = true
            self?.reloadViewData()
        }).disposed(by: rx.disposeBag)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 网络请求
extension Comment {
    //页面刷新时会调用该方法
    func reloadViewData() {
        self.pageNum = 1
        //请求M2数据信息
        self.requestCommentList()
    }
    /// 加载更多
    func loadMoreData() {
        //加载更多时，分页数加1，不需要分页可以去掉下面这行
        self.pageNum += 1
        //请求M2数据信息
        self.requestCommentList()
    }
    //获取评论信息
    func requestCommentList() {
        var pageIndex = 1
        var pageNum = 10
        if reload ?? false {
            pageIndex = 1
            pageNum = self.pageNum * 10
            reload = false
        } else {
            pageIndex = self.pageNum
            pageNum = 10
        }
        let id = self.topicData?.id ?? self.replyData?.invitation_id ?? 0
        let pid = self.topicData?.group_pid ?? self.replyData?.invitation_pid ?? 0
        let rid = self.replyData?.id ?? 0
        let rPid = self.replyData?.group_pid ?? 0
        NetworkUtil.request(target: .getRepliesByInvitation(parent_pid: rPid, parent_id: rid, group_pid: pid, group_invitation_id: id, page_context: pageNum, page_index: pageIndex), success: { [weak self] json in
            //如果数据需要分页，使用下面的代码
            let tmpList = ReplyListModel.deserialize(from: json)?.data
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
            //tableView需要刷新数据
            self?.reloadData()
        }) { [weak self] error in
            self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
            dPrint(error)
        }
    }
}

// MARK: - UI&事件处理
extension Comment {
    //渲染UI
    private func renderUI() {
//        self.config()
        self.moduleDelegate?.setfullPageTableModule(table: self)
        self.configRefresh()
        self.separatorColor = self.splitterColor.toColor()
        if self.bgImg != ""{
            let imgView = UIImageView(frame: self.bounds)
            imgView.kf.setImage(with: URL(string: self.bgImg))
            self.addSubview(imgView)
        }
//        if limit == 1{
//            self.bounces = false
//            //table 的 header
//            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.width, height: self.heightTitle))
//            headerView.backgroundColor = self.bgColorTitle.toColor()
//            //标题
//            let titleLabel = UILabel()
//            titleLabel.text = self.titleTitle
//            titleLabel.textColor = self.colorTitle.toColor()
//            headerView.addSubview(titleLabel)
//            titleLabel.snp.makeConstraints { (make) in
//                make.centerY.equalTo(headerView)
//                make.left.equalTo(10)
//            }
//            //更多
//            let moreBtn = UIButton()
//            headerView.addSubview(moreBtn)
//            moreBtn.setYJText(prefixText: self.titleContent, icon: .nextArrow, postfixText: "", size: self.fontSizeRightTitle, forState: .normal)
//            moreBtn.setTitleColor(self.colorRightTitle.toColor(), for: .normal)
//            moreBtn.snp.makeConstraints { (make) in
//                make.right.equalTo(-17)
//                make.centerY.equalTo(headerView)
//            }
//            moreBtn.addTarget(self, action: #selector(seeMore), for: .touchUpInside)
//            moreBtn.isHidden = (self.more == 1 ? false : true)
//            self.tableHeaderView = headerView
//        }else{
//
//        }
    }

    // MARK: 事件处理
    @objc func seeMore(btn: UIButton) {
        let event = self.events?[kMoreEvent]
        event?.attachment = [TopicData.getClassName: self.topicData ?? TopicData()]
        let result = EventUtil.handleEvents(event: event)
        EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
    }

    override func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let text = "暂无评论"
        let font = UIFont.systemFont(ofSize: 22)
        let textColor = UIColor(hexString: "cccccc")
        let attributes = NSMutableDictionary()
        attributes.setObject(textColor, forKey: NSAttributedStringKey.foregroundColor as NSCopying)
        attributes.setObject(font, forKey: NSAttributedStringKey.font as NSCopying)
        return NSAttributedString(string: text, attributes: attributes  as? [NSAttributedStringKey: Any])
    }

    override func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let text = ""
        return NSMutableAttributedString(string: text, attributes: nil)
    }
    override func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> NSAttributedString? {
        let text = "点击抢占沙发"
        let font = UIFont.systemFont(ofSize: 18)
        let textColor = UIColor(hexString: "aaaaaa")
        let attributes = NSMutableDictionary()
        attributes.setObject(textColor, forKey: NSAttributedStringKey.foregroundColor as NSCopying)
        attributes.setObject(font, forKey: NSAttributedStringKey.font as NSCopying)
        return NSAttributedString(string: text, attributes: attributes  as? [NSAttributedStringKey: Any])
    }

    override func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {
        NotificationCenter.default.post(name: Notification.Name(kBeginCommentNotification), object: self.topicData?.id)
    }
}

// MARK: - 代理方法
extension Comment: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.cellHeightArr.removeAll()
//        let count = self.limit == 1 ? branchesNumber : (self.itemList?.count ?? 0)
        let count = self.itemList?.count ?? 0
        trueCount = count > (self.itemList?.count ?? 0) ? self.itemList?.count : count
        if let footer = self.mj_footer {
            if (trueCount ?? 0) < 2 {
                footer.isHidden = true
            } else {
                footer.isHidden = false
            }
        }

        return trueCount ?? 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") ?? UITableViewCell()
        cell.backgroundColor = self.bgColor.toColor()
        cell.cornerRadius = self.radius
        cell.maskToBounds = true
        if let commentCell = cell as? CommentCell {
            commentCell.cellObj = self.itemList?[indexPath.row]
            commentCell.commentButton.tag = indexPath.row
            commentCell.events = self.events
            commentCell.repliesView.backgroundColor = self.bgColorReply.toColor()
            commentCell.buttonsView.backgroundColor = self.bgColor.toColor()
            commentCell.line.backgroundColor = self.splitterColor.toColor()
            commentCell.line.height = CGFloat(self.splitterWidth)
        }
        return cell
    }

    //cell高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.itemList?.isEmpty ?? true {
            return 0
        }
        //获取到请求的数据Model
        let replyData = self.itemList?[indexPath.row]
        //获取评论的内容
        let comment = replyData?.content
        let commentH = comment?.getSizeForString(font: 15, viewWidth: self.width - 104).height ?? 0
        //回复的数据
//        let replyCount = replyData?.reply?.count ?? 0
//        let replyH:CGFloat = replyCount == 0 ? 0 : 12 + 12

        let margin: CGFloat = 10
        let padding: CGFloat = 5
        let iconImgViewH: CGFloat = 50
//
//        var  replyViewH:CGFloat = replyH
//        if replyCount <= 3 {
//            replyViewH = CGFloat(replyCount) * replyH
//        }else{
//            replyViewH = 4 * replyH
//        }
        let replyViewH = replyData?.replyHeight ?? 0 //self.replyH
        let buttonsBarH: CGFloat = 30
        //头像距离顶部间距+头像高度+评论高度+间距+回复高度+间距+按钮高度+间距
        let partHeight = margin + iconImgViewH + padding + commentH + padding
        let cellH = partHeight + replyViewH + padding + buttonsBarH + padding
        cellHeightArr.append(cellH)

        return cellH - 1
    }
}
