import SwiftyJSON
import UIKit

class PersonalCenterModel: BaseData {
    var events: [String: EventsData]?
    var fields: PersonalCenterFields?
    var status: Int?
    var styles: PersonalCenterStyles?
}
enum RelationType: Int {
    case group = 5
    case post = 8
    case comment = 9
    case fllow = 10
    case fans = 11
    case friends = 12
    case includeMe = 15
    case huoKe = 17
    case qiangDan = 18
    case news = 19
    case like = 20
    case forward = 22
    case chat = -1
    case addFriend = -2
    case follow = -3
}

class PersonalCenterFields: BaseData {
    var buttonGroup: Int?
    var buttonGuest: Int?
    var buttonAT: Int?
    var buttonAttention: Int?
    var buttonConsult: Int?
    var buttonLike: Int?
    var buttonRelease: Int?
    var optionsMenuLayout: Int?
    var buttonComment: Int?
    var buttonFans: Int?
    var buttonForward: Int?
}
class PersonalCenterStyles: BaseStyleModel {
    var bgImgSys: String?
    var borderColor: String?
    var opacity: Int?
    var bgImgModeOptions: Int?
    var borderWidth: Int?
    var showType: Int?
    var bgColorSys: String?
    var bgImgModeSys: Int?
    var button: Int?
    var opacityOptions: Int?
    var bgColorOptions: String?
    var bgImgOptions: String?
    var borderShow: Int?
    var opacitySys: Int?
    var optionsMenuShowType: Int?
}

class PersonalCenter: UIView, PageModuleAble {
    // MARK: - 模块相关的配置属性
    private var bgColor = "255,255,255,1"//上面背景 颜色
    private var bgColorOptions = "255,255,255,1"//下面背景 颜色
    private var bgColorSys = "255,255,255,1"//整体背景    颜色 
    private var bgImg = "http://p8v2k1avt.bkt.clouddn.com/Fg8u1s9qhT-6wVddMf0jyb9maDOp"//上面背景图片
    private var bgImgMode = 0//上面背景 平铺
    private var bgImgModeOptions = 0//下面背景 平铺
    private var bgImgModeSys = 0//整体背景 平铺
    private var bgImgOptions = ""//下面背景 图片
    private var bgImgSys = ""//整体背景 图片
    private var borderColor = "230,230,230,1"//边框 颜色
    private var borderShow = 1//边框是否显示
    private var borderWidth = 0//边框 宽度
    private var button = 1//按钮
    private var buttonAT = 1//@我
    private var buttonAttention = 1//关注
    private var buttonComment = 1//评论
    private var buttonConsult = 1//咨询
    private var buttonFans = 1//粉丝
    private var buttonForward = 1//转发
    private var buttonGroup = 1//群组
    private var buttonGuest = 1//预约客户
    private var buttonLike = 1//点赞
    private var buttonRelease = 1//发布
    private var opacity = 1//上面背景 透明度
    private var opacityOptions = 1//下面背景 透明度
    private var opacitySys = 1//全面背景 透明度
    private var optionsMenuLayout = 1//布局
    private var optionsMenuShowType = 1//操作菜单展示方式
    private var radius: CGFloat = 0//圆角
    private var showType = 0//布局样式
    private var styleHeight: CGFloat = 200
    private var events: [String: EventsData]?

    /// 模块代理
    weak var moduleDelegate: ModuleRefreshDelegate?
    /// 模块参数
    var moduleParams: [String: Any]? {
        didSet {
            self.userInfo = moduleParams?[UserInfoData.getClassName] as? UserInfoData
            self.userChatInfo = moduleParams?["PCTuple"] as? (Int64, Int64)
            //获取数据
            reloadViewData()
        }
    }
    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let personalCenterModel = PersonalCenterModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.bgColor = personalCenterModel.styles?.bgColor ?? self.bgColor
                self.bgColorOptions = personalCenterModel.styles?.bgColorOptions ?? self.bgColorOptions
                self.bgColorSys = personalCenterModel.styles?.bgColorSys ?? self.bgColorSys
                self.bgImg = personalCenterModel.styles?.bgImg ?? self.bgImg
                self.bgImgMode = personalCenterModel.styles?.bgImgMode ?? self.bgImgMode
                self.bgImgModeOptions = personalCenterModel.styles?.bgImgModeOptions ?? self.bgImgModeOptions
                self.bgImgModeSys = personalCenterModel.styles?.bgImgModeSys ?? self.bgImgModeSys
                self.bgImgOptions = personalCenterModel.styles?.bgImgOptions ?? self.bgImgOptions
                self.bgImgSys = personalCenterModel.styles?.bgImgSys ?? self.bgImgSys
                self.borderColor = personalCenterModel.styles?.borderColor ?? self.borderColor
                self.borderShow = personalCenterModel.styles?.borderShow ?? self.borderShow
                self.borderWidth = personalCenterModel.styles?.borderWidth ?? self.borderWidth
                self.button = personalCenterModel.styles?.button ?? self.button
                self.buttonAT = personalCenterModel.fields?.buttonAT ?? self.buttonAT
                self.buttonAttention = personalCenterModel.fields?.buttonAttention ?? self.buttonAttention
                self.buttonComment = personalCenterModel.fields?.buttonComment ?? self.buttonComment
                self.buttonConsult = personalCenterModel.fields?.buttonConsult ?? self.buttonConsult
                self.buttonFans = personalCenterModel.fields?.buttonFans ?? self.buttonFans
                self.buttonForward = personalCenterModel.fields?.buttonForward ?? self.buttonForward
                self.buttonGroup = personalCenterModel.fields?.buttonGroup ?? self.buttonGroup
                self.buttonGuest = personalCenterModel.fields?.buttonGuest ?? self.buttonGuest
                self.buttonLike = personalCenterModel.fields?.buttonLike ?? self.buttonLike
                self.buttonRelease = personalCenterModel.fields?.buttonRelease ?? self.buttonRelease
                self.opacity = personalCenterModel.styles?.opacity ?? self.opacity
                self.opacityOptions = personalCenterModel.styles?.opacityOptions ?? self.opacityOptions
                self.opacitySys = personalCenterModel.styles?.opacitySys ?? self.opacitySys
                self.optionsMenuLayout = personalCenterModel.fields?.optionsMenuLayout ?? self.optionsMenuLayout
                self.optionsMenuShowType = personalCenterModel.styles?.optionsMenuShowType ?? self.optionsMenuShowType
                self.radius = personalCenterModel.styles?.radius ?? self.radius
                self.showType = personalCenterModel.styles?.showType ?? self.showType
                self.styleHeight = personalCenterModel.styles?.height ?? self.styleHeight
                self.events = personalCenterModel.events

                self.renderUI()
                self.changeData()
            }
        }
    }

    // MARK: - 模块特有属性
    private var relationList: [Relation]?
    private var btnContainer = UIView()
    var userChatInfo: (uid: Int64, pid: Int64)?
    var userInfo: UserInfoData?
    fileprivate var phoneButton: UIButton?
    private var isOthers: Bool {
        if userInfo == nil && userChatInfo == nil {
            return false
        } else if userInfo != nil {
            return !(self.userInfo?.uid == UserUtil.share.appUserInfo?.uid)
        } else if userChatInfo != nil {
            return !(userChatInfo?.uid == UserUtil.share.appUserInfo?.uid)
        } else {
            return false
        }
    }
    //头像
    private let headImg = UIButton()
    //昵称
    private let nick = UILabel()
    //用户简介
    private let intro = UILabel()

    private var otherRelation: [Relation] {
        var relationArr = [Relation]()
        let relation1 = Relation()
        let relation2 = Relation()
        let relation3 = Relation()
        relation1.relation_type = -1
        relation1.color = "#f44336"
        relation1.icon = "#xe63e;"
        relation1.relation_name = "发消息"
        relation2.relation_type = -2
        relation2.color = "#65ca00"
        relation2.icon = "#xe64f;"
        if userInfo?.is_friend == 0 {
            relation2.relation_name = "加好友"
        } else {
            relation2.relation_name = "删除好友"
        }
        relation3.relation_type = -3
        relation3.color = "#3d9ee2"
        relation3.icon = "#xe6ee;"
        if userInfo?.follow_status == 0 {
            relation3.relation_name = "加关注"
        } else {
            relation3.relation_name = "取消关注"
        }
        relationArr.append(relation1)
        relationArr.append(relation2)
        relationArr.append(relation3)
        for relation in self.userInfo?.relations ?? [] {
            if relation.relation_type == 10 {
                relation.relation_name = "Ta的关注"
                relation.type_define = relation.relation_type
                relationArr.append(relation)
            }
            if relation.relation_type == 5 {
                relation.relation_name = "Ta的群组"
                relation.type_define = relation.relation_type
                relationArr.append(relation)
            }
        }
        return relationArr
    }
    // MARK: init方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.rx
            .notification(Notification.Name(kPersonalInfoChangeNotification))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                self?.reloadViewData()
            })
            .disposed(by: rx.disposeBag)

        NotificationCenter.default.rx
            .notification(Notification.Name(kLogoutNotification))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.cacheJson(key: kPCRelatios, json: "")
                    self?.userInfo = nil
                    self?.changeData()
                }
            })
            .disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 网络请求
extension PersonalCenter {
    //页面刷新时会调用该方法
    func reloadViewData() {
        //请求M2数据信息
//        if self.optionsMenuLayout == 1 {
//            self.requestRelationTypeList()
//        }
        if userChatInfo != nil || userInfo != nil {
            self.requestOthersInfo()
        } else {
            self.requestSelfInfo()
        }
    }

    //获取关系列表
//    private func requestRelationTypeList(){
//        NetworkUtil.request(target: .getRelationTypeList, success: { [weak self] (json) in
//            //内存缓存
//            self?.relationList = RelationModel.deserialize(from: json)?.data
//            //本地缓存
//            self?.cacheJson(key: kPCRelatios, json: json)
//            DispatchQueue.main.async {
//                self?.renderButtons()
//            }
//        }) { (error) in
//            dPrint(error)
//        }
//    }

    //获取PersonalCenter数据
    private func requestSelfInfo() {
        let uid = UserUtil.share.appUserInfo?.uid ?? 0
        let pid = UserUtil.share.appUserInfo?.pid ?? 0
        NetworkUtil.request(target: .getInfo(user_id: uid, user_pid: pid), success: { [weak self] json in
            UserUtil.share.saveUser(userInfo: json)
            DispatchQueue.main.async {
                self?.userInfo = UserInfoModel.deserialize(from: json)?.data
                self?.changeData()
                //请求完成，回调告知AssembleVC停止刷新
                self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
            }
        }) { error in
            dPrint(error)
        }
    }
    private func requestOthersInfo() {
        let uid = userInfo?.uid ?? userChatInfo?.uid ?? 0
        let pid = userInfo?.pid ?? userChatInfo?.pid ?? 0
        NetworkUtil.request(target: .getInfo(user_id: uid, user_pid: pid), success: { [weak self] json in
            let userInfo = UserInfoModel.deserialize(from: json)?.data
            self?.userInfo = userInfo
            //进入别人个人中心时，保存这个人的个人信息
            if UserUtil.isValid() {
                let db = DatabaseTool.shared
                db.isContactsInfoExsist(uid: userInfo?.uid ?? 0, pid: userInfo?.pid ?? 0) { exsist in
                    if exsist {
                        db.modifyContacts(uid: userInfo?.uid ?? 0, pid: userInfo?.pid ?? 0, avatar: userInfo?.head_portrait ?? "", nickname: userInfo?.zh_name ?? "", type: 0, message: nil)
                    } else {
                        db.insertContacts(uid: userInfo?.uid ?? 0, pid: userInfo?.pid ?? 0, avatar: userInfo?.head_portrait ?? "", nickname: userInfo?.zh_name ?? "", type: 0, message: nil)
                    }
                }
            }
            DispatchQueue.main.async {
                self?.changeData()
                //请求完成，回调告知AssembleVC停止刷新
                self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
            }
        }) { error in
            dPrint(error)
        }
    }
    //添加关注
    @objc private func addFollower(btn: UIButton) {
        guard let btnView = btn.superview as? PersonalCenterBtnView else {
            return
        }
        if btnView.lable?.text == "加关注"{
            NetworkUtil.request(target: .addFollower(follow_uid: userInfo?.uid ?? 0, follow_pid: userInfo?.pid ?? 0), success: { [weak self] json in
                let success = JSON(parseJSON: json ?? "")["data"].boolValue
                if success {
                    if let btnView = btn.superview as? PersonalCenterBtnView {
                        btnView.lable?.text = "取消关注"
                        self?.otherRelation[2].relation_name = "取消关注"
                    }
                }
            }) { error in
                dPrint(error)
            }
        } else {
            NetworkUtil.request(target: .deleteFollower(follow_uid: userInfo?.uid ?? 0, follow_pid: userInfo?.pid ?? 0), success: { [weak self] json in
                let success = JSON(parseJSON: json ?? "")["data"].boolValue
                if success {
                    if let btnView = btn.superview as? PersonalCenterBtnView {
                        btnView.lable?.text = "加关注"
                        self?.otherRelation[2].relation_name = "加关注"
                    }
                }
            }) { error in
                dPrint(error)
            }
        }
    }
    //添加好友
    @objc private func addFriend(btn: UIButton) {
        guard let btnView = btn.superview as? PersonalCenterBtnView else {
            return
        }
        if btnView.lable?.text == "加好友" {
            NetworkUtil.request(target: .addFriend(friend_uid: userInfo?.uid ?? 0, friend_pid: userInfo?.pid ?? 0, answer: ""), success: {[weak self] json in
                let success = JSON(parseJSON: json ?? "")["data"].boolValue
                if success {
                    if let btnView = btn.superview as? PersonalCenterBtnView {
                        btnView.lable?.text = "删除好友"
                        self?.otherRelation[1].relation_name = "删除好友"
                    }
                    HUDUtil.msg(msg: "添加成功", type: .successful)
                } else {
                    HUDUtil.msg(msg: "请求已发送", type: .successful)
                }
            }) { error in
                dPrint(error)
            }
        } else {
            let alertVC = UIAlertController(title: "确定删除该好友？", message: nil, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { [weak self] _ in
                NetworkUtil.request(target: .deleteFriend(friend_uid: self?.userInfo?.uid ?? 0, friend_pid: self?.userInfo?.pid ?? 0, answer: ""), success: { [weak self] json in
                    let success = JSON(parseJSON: json ?? "")["data"].boolValue
                    if success {
                        if let btnView = btn.superview as? PersonalCenterBtnView {
                            btnView.lable?.text = "加好友"
                            self?.otherRelation[1].relation_name = "加好友"
                        }
                        HUDUtil.msg(msg: "删除成功", type: .successful)
                    } else {
                        HUDUtil.msg(msg: "删除失败", type: .error)
                    }
                }) { error in
                    dPrint(error)
                }
            }))
            alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alertVC.show()
        }
    }
    //添加黑名单
    @objc private func addBlackUser() {
        NetworkUtil.request(target: .addBlackUser(black_uid: userInfo?.uid ?? 0, black_pid: userInfo?.pid ?? 0), success: {_ in
            HUDUtil.msg(msg: "请求已发送", type: .successful)
        }) { error in
            dPrint(error)
        }
    }
}

// MARK: - UI&事件处理
extension PersonalCenter {
    //渲染UI
    private func renderUI() {
        self.removeAllSubviews()
        self.backgroundColor = self.bgColorSys.toColor()
        //个人中心头部
        let headTop = UIView()
        headTop.backgroundColor = self.bgColorSys.toColor()
        self.backgroundColor = self.bgColor.toColor()
        self.layer.cornerRadius = self.radius
        self.layer.masksToBounds = true
        if self.bgImg != ""{
            let imageView = UIImageView()
            headTop.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.left.right.top.bottom.equalTo(headTop)
            }
            imageView.kf.setImage(with: URL(string: self.bgImg))
        }
        self.addSubview(headTop)
        headTop.addSubview(headImg)
        headImg.layer.cornerRadius = 30
        headImg.layer.masksToBounds = true
        headImg.layer.borderColor = UIColor.white.cgColor
        headImg.layer.borderWidth = 2
        headImg.setImage(UIImage(named: "defaultPortrait"), for: .normal)
        headTop.addSubview(nick)
        headTop.addSubview(intro)
        if showType == 1 {
            headTop.frame = CGRect(x: 0, y: 0, width: self.width, height: 81)
            headTop.backgroundColor = self.bgColor.toColor()
            //            //点击事件UIButton
            //            let clickBtn = UIButton()
            //            clickBtn.frame = headTop.frame
            //            self.addSubview(clickBtn)
            //            clickBtn.addTarget(self, action: #selector(touchEdit(btn:)), for: .touchUpInside)
            //            if let personalCenterModel = self.model as? PersonalCenterModel{
            //                let personalDetailsEvent = personalCenterModel.events?[kPersonalDetails]
            //                clickBtn.event = personalDetailsEvent
            //            }
            //头像
            headImg.frame = CGRect(x: 12, y: 12, width: 80, height: 80)
            //用户昵称
            nick.frame = CGRect(x: 78, y: 22, width: headTop.width - x - 12, height: 16)
            nick.textColor = UIColor(red: 248, green: 248, blue: 248)
            nick.font = UIFont.systemFont(ofSize: 16)
            nick.text = "赶快去登录吧~~"
            //用户简介
            intro.font = UIFont.systemFont(ofSize: 12)
            intro.top = nick.bottom + 8
            intro.left = nick.left
            intro.height = 20
            intro.width = self.width - 90
            intro.textColor = UIColor(red: 248, green: 248, blue: 248)
            intro.text = "暂无简介"
            if !isOthers {
                let clickBtn = UIButton()
                clickBtn.frame = headTop.frame
                self.addSubview(clickBtn)
                clickBtn.addTarget(self, action: #selector(touchEdit(btn:)), for: .touchUpInside)
                let personalDetailsEvent = self.events?[kPersonalDetails]
                clickBtn.event = personalDetailsEvent
                //右边箭头 cell_arrow
                let imgRight = UIImageView()
                headTop.addSubview(imgRight)
                imgRight.frame = CGRect(x: headTop.width - 30, y: headTop.height / 2 - 10, width: 20, height: 20)
                imgRight.image = R.image.whiteNext()!
            } else {
                //                let followBtn = UIButton()
                //                headTop.addSubview(followBtn)
                //                followBtn.frame = CGRect.init(x: headTop.width - 50, y: headTop.height / 2 - 10, width: 40, height: 20)
                //                followBtn.setTitle("关注", for: .normal)
                //                followBtn.setTitleColor(.red, for: .normal)
                //                followBtn.addTarget(self, action: #selector(addFollower), for: .touchUpInside)
            }
        } else {
            let height = self.styleHeight
            headTop.frame = CGRect(x: 0, y: 0, width: self.width, height: height)
            headTop.backgroundColor = self.bgColor.toColor()
            //            headTop.backgroundColor = UIColor.init(patternImage: UIImage(named: self.bgImg)!)
            //左上消息按钮
            //            let msgButton = UIButton()
            //            headTop.addSubview(msgButton)
            //            msgButton.frame = CGRect.init(x: 12, y: 32, width: 20, height: 15)
            //            msgButton.addTarget(self, action: #selector(touchMsgList(btn:)), for: .touchUpInside)
            //            if let personalCenterModel = self.model as? PersonalCenterModel{
            //                let messageListEvent = personalCenterModel.events?[kMessageList]
            //                msgButton.event = messageListEvent
            //            }
            //            msgButton.setImage(UIImage(named: "pcMsg"), for: .normal)
            //右上按钮
            //            if !isOthers{
            phoneButton = UIButton()
            self.addSubview(phoneButton!)
            phoneButton?.isHidden = true
            phoneButton?.width = 30
            phoneButton?.height = 30
            phoneButton?.right = self.right - 30
            phoneButton?.top = 32
            phoneButton?.rx.tap.subscribe(onNext: { () in
                let user = self.userInfo != nil ? self.userInfo : UserUtil.share.appUserInfo
                let phoneNum = user?.login_name ?? ""
                DeviceTool.makePhoneCall(with: phoneNum)
            }).disposed(by: rx.disposeBag)
            phoneButton?.setImage(R.image.callWhite(), for: .normal)
            phoneButton?.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            //            }else{//TODO: 加关注
            ////                let changeButton = UIButton()
            ////                self.addSubview(changeButton)
            ////                changeButton.frame = CGRect.init(x: self.width - 100, y: 32, width: 120, height: 18)
            ////                changeButton.addTarget(self, action: #selector(addFollower), for: .touchUpInside)
            ////                changeButton.setTitle("关注", for: .normal)
            ////                changeButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            ////                changeButton.setTitleColor(.red, for: .normal)
            //            }

            //头像图片
            headImg.frame = CGRect(x: self.width / 2 - 30, y: 32, width: 60, height: 60)
            if !isOthers {
                headImg.addTarget(self, action: #selector(touchEdit(btn:)), for: .touchUpInside)
                let personalDetailsEvent = self.events?[kPersonalDetails]
                headImg.event = personalDetailsEvent
            }

            //昵称
            nick.top = headImg.bottom + 12
            nick.width = self.width - 40
            nick.height = 22
            nick.left = 20
            nick.textAlignment = .center
            nick.font = UIFont.systemFont(ofSize: 20)
            nick.textColor = .white
            //简介
            intro.top = nick.bottom + 12
            intro.height = 44
            intro.width = self.width - 40
            intro.left = 20
            intro.textAlignment = .center
            intro.textColor = UIColor(red: 248, green: 248, blue: 248)
            intro.numberOfLines = 2
        }
        //底部按钮容器
        if self.optionsMenuLayout == 1 {
            btnContainer.top = headTop.bottom
            btnContainer.width = self.width
            btnContainer.height = 0
            self.addSubview(btnContainer)
            renderButtons()
        } else {
            self.height = headTop.height
            self.moduleDelegate?.moduleLayoutDidRefresh()
        }
        self.moduleDelegate?.moduleLayoutDidRefresh()
    }

    private func changeData() {
        let user = self.userInfo != nil ? self.userInfo : UserUtil.share.appUserInfo
        headImg.kf.setImage(with: URL(string: user?.head_portrait ?? ""), for: .normal, placeholder: R.image.defaultPortrait(), options: nil, progressBlock: nil, completionHandler: nil)
        if user?.signature == "" || user?.signature == nil {
            intro.text = "暂无简介"
        } else {
            intro.text = user?.signature ?? ""
        }

        if user?.zh_name == "" || user?.zh_name == nil {
            nick.text = "请点击头像登录"
        } else {
            nick.text = user?.zh_name ?? ""
        }
        let phoneNum = user?.login_name ?? ""
        phoneButton?.isHidden = !(phoneNum != "" && isOthers)

        // 内存缓存
        self.relationList = user?.relations ?? []
        // 渲染按钮
        DispatchQueue.main.async {
            self.renderButtons()
        }
    }
    //渲染下面的按钮
    private func renderButtons() {
        self.btnContainer.removeAllSubviews()
        self.btnContainer.bottomLine(style: .full, color: .lightGray)
        self.backgroundColor = self.bgColorOptions.toColor()

        guard var relations = self.relationList, UserUtil.isValid() else {
            return
        }
        DispatchQueue.main.async {
            //别人的个人中心
            if self.isOthers {
                relations = self.otherRelation
            } else {
                relations = relations.filter({ relation -> Bool in
                    switch RelationType(rawValue: relation.type_define ?? 8) ?? .huoKe {
                    case .group, .fans, .fllow, .friends, .post:
                        return true
                    default:
                        return false
                    }
                })
            }

            let row = 5
            let column = 5
            //                if self?.showType == 1 || (self?.isOthers ?? false){
            //                    column = 3
            //                }
            //单页item数量
            let onePageNum = Int(row * column)
            //保存单页的item
            var singleList = [Relation]()
            //保存singleList
            var groupList = [[Relation]]()
            //遍历itemData，将数据分组保存在groupList中
            for (index, item) in relations.enumerated() {
                singleList.append(item)
                if singleList.count == onePageNum {//如果单页满了，添加到组中，清空单页数组
                    groupList.append(singleList)
                    singleList = []
                } else if((index + 1) == relations.count) {//如果是最后一页，添加到组中
                    groupList.append(singleList)
                }
            }
            //每个按钮宽高
            let itemWidth: CGFloat = (self.btnContainer.width) / CGFloat(column)
            let itemHeight: CGFloat = 90
            let marginY: CGFloat = 10
            var maxHeight: CGFloat = 0

            //生成item
            for (groupIndex, groupItem) in groupList.enumerated() {
                for (index, item) in groupItem.enumerated() {
                    let startX = (self.btnContainer.width) * CGFloat(groupIndex) + itemWidth * CGFloat(index % Int(column))
                    let startY = CGFloat(index / column) * (itemHeight + marginY) + marginY
                    let btnView = PersonalCenterBtnView(frame: CGRect(x: startX, y: startY, width: itemWidth, height: itemHeight))
                    btnView.setUI(with: item)
                    switch RelationType(rawValue: item.relation_type ?? 8) ?? .post {
                    case .group :
                        btnView.button?.addTarget(self, action: #selector(self.touchRelationBtn(btn:)), for: .touchUpInside)
                        let groupListTopicEvent = self.events?[kGroupEvent]
                        btnView.button?.event = groupListTopicEvent
                    case .post :
                        btnView.button?.addTarget(self, action: #selector(self.touchRelationBtn(btn:)), for: .touchUpInside)
                        let postListEvent = self.events?[kPostList]
                        btnView.button?.event = postListEvent
                    case .fans:
                        btnView.button?.addTarget(self, action: #selector(self.touchRelationBtn(btn:)), for: .touchUpInside)
                        let funEvent = self.events?[kFunEvent]
                        funEvent?.attachment = ["RelationType": RelationType.fans]
                        btnView.button?.event = funEvent
                    case .fllow:
                        btnView.button?.addTarget(self, action: #selector(self.touchRelationBtn(btn:)), for: .touchUpInside)
                        let followEvent = self.events?[kFollowEvent]
                        followEvent?.attachment = ["RelationType": RelationType.fllow]
                        btnView.button?.event = followEvent
                    case .friends:
                        btnView.button?.addTarget(self, action: #selector(self.touchRelationBtn(btn:)), for: .touchUpInside)
                        let friendsEvent = self.events?[kFriendsEvent]
                        friendsEvent?.attachment = ["RelationType": RelationType.friends]
                        btnView.button?.event = friendsEvent
                    case .chat:
                        btnView.button?.addTarget(self, action: #selector(self.touchChat(btn:)), for: .touchUpInside)
                        let chatEvent = self.events?[kChatEvent]
                        chatEvent?.attachment = ["RelationType": RelationType.friends]
                        btnView.button?.event = chatEvent
                    case .addFriend:
                        btnView.button?.addTarget(self, action: #selector(self.addFriend(btn:)), for: .touchUpInside)
                    case .follow:
                        btnView.button?.addTarget(self, action: #selector(self.addFollower(btn:)), for: .touchUpInside)
                    default :
                        break
                    }
                    if btnView.bottom > maxHeight {
                        maxHeight = btnView.bottom
                    }
                    self.btnContainer.addSubview(btnView)
                }
            }
            self.btnContainer.height = maxHeight + 10
            self.height = self.btnContainer.bottom
            self.moduleDelegate?.moduleLayoutDidRefresh()
        }
    }
    // MARK: 事件处理
    @objc func touchEdit(btn: UIButton) {
        if !UserUtil.isValid() {
            let loginPageKey = GlobalConfigTool.shared.global?.loginPageKey
            EventUtil.gotoPage(with: loginPageKey ?? "")
        } else {
            guard !isOthers else { return }
            let result = EventUtil.handleEvents(event: btn.event)
            EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
        }
    }

    @objc func touchRelationBtn(btn: UIButton) {
        btn.event?.attachment["UserID"] = self.userInfo?.uid
        btn.event?.attachment["UserPID"] = self.userInfo?.pid
        let result = EventUtil.handleEvents(event: btn.event)
        EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
    }

    /// 点击了私聊
    ///
    /// - Parameter btn: 私聊按钮
    @objc func touchChat(btn: UIButton) {
        guard let ownUid = UserUtil.share.appUserInfo?.uid, let ownPid = UserUtil.share.appUserInfo?.pid else {
            PageRouter.shared.router(to: PageRouter.RouterPageType.login)
            return
        }
        guard let othersUid = userInfo?.uid, let othersPid = userInfo?.pid else {
            HUDUtil.msg(msg: "获取他人信息失败", type: .error)
            return
        }
        let sessionModel = IMService.shared.createChatSession(ownUid: ownUid, ownPid: ownPid, otherUid: othersUid, otherPid: othersPid)
        sessionModel.nickname = self.userInfo?.zh_name ?? ""
        sessionModel.avatar = self.userInfo?.head_portrait ?? ""
        let event = btn.event
        event?.attachment = [ChatSessionModel.getClassName: sessionModel]
        let result = EventUtil.handleEvents(event: event)
        EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
    }
}
