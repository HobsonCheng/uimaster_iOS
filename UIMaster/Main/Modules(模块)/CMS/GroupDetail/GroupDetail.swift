//  模块通用模板,保持整体完整性，
//  不需要的部分可以先注释掉，之后完成后，再统一删掉
//  可以参考GroupDetail模块，如果涉及到分页显示数据，请参考GroupListTopic模块

import RxSwift
import UIKit

class GroupDetail: UIView, PageModuleAble {
    // MARK: - 模块相关的配置属性
    private var bgColor = "255,255,255,1"//模块背景 颜色
    private var bgColorItem = "8,253,15,1"//项背景 颜色
    private var bgImg = ""//模块背景 图片
    private var bgImgItem = ""//项背景 图片
    private var bgImgMode = 0//模块背景 平铺
    private var bgImgModeItem = 0//项背景 平铺
    private var borderColor = "40,190,44,1"//边框 颜色
    private var borderShow = 1//边框 是否显示
    private var borderWidth: CGFloat = 0//边框 宽度
    private var opacity = 1//边框 透明度
    private var opacityItem = 1//项背景 透明度
    private var personalNumber = 0//群组人数开关
    private var postNumber = 1//帖子数开关
    private var radius: CGFloat = 0//圆角
    private var events: [String: EventsData]?

    weak var moduleDelegate: ModuleRefreshDelegate?
    /// 传参
    var moduleParams: [String: Any]? {
        didSet {
            self.groupData = moduleParams?[GroupData.getClassName] as? GroupData
            //渲染UI
            renderUI()
        }
    }
    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let groupDetailModel = GroupDetailModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.bgColor = groupDetailModel.styles?.bgColor ?? self.bgColor
                self.bgColorItem = groupDetailModel.styles?.bgColorItem ?? self.bgColorItem
                self.bgImg = groupDetailModel.styles?.bgImg ?? self.bgImg
                self.bgImgItem = groupDetailModel.styles?.bgImgItem ?? self.bgImgItem
                self.bgImgMode = groupDetailModel.styles?.bgImgMode ?? self.bgImgMode
                self.bgImgModeItem = groupDetailModel.styles?.bgImgModeItem ?? self.bgImgModeItem
                self.borderColor = groupDetailModel.styles?.borderColor ?? self.borderColor
                self.borderShow = groupDetailModel.styles?.borderShow ?? self.borderShow
                self.borderWidth = groupDetailModel.styles?.borderWidth ?? self.borderWidth
                self.opacity = groupDetailModel.styles?.opacity ?? self.opacity
                self.opacityItem = groupDetailModel.styles?.opacityItem ?? self.opacityItem
                self.personalNumber = groupDetailModel.fields?.personalNumber ?? self.personalNumber
                self.postNumber = groupDetailModel.fields?.postNumber ?? self.postNumber
                self.radius = groupDetailModel.styles?.radius ?? self.radius
                self.events = groupDetailModel.events
            }
        }
    }

    // MARK: - 模块特有属性
    var groupData: GroupData?
    var groupIcon: UIImageView?
    var groupNameLabel: UILabel?
    var groupIntroLabel: UILabel?

    // MARK: init方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.rx.notification(Notification.Name(kGroupInfoChangeNotification)).takeUntil(self.rx.deallocated).subscribe(onNext: {
            [weak self] ntf in
            if let groupData = ntf.object as? GroupData {
                self?.groupData = groupData
                self?.changeInfo()
            }
        }).disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 网络请求
extension GroupDetail {
    @objc func sendApplyGroup() {
        NetworkUtil.request(target: .applyGroup(group_id: self.groupData?.id ?? 0, member_id: self.groupData?.member_id ?? 0, group_pid: self.groupData?.pid ?? 0), success: {  _ in
            HUDUtil.msg(msg: "加入成功", type: .successful)
        }) { error in
            dPrint(error)
        }
    }
}

// MARK: - UI&事件处理
extension GroupDetail {
    //渲染UI
    private func renderUI() {
        //背景
        self.backgroundColor = self.bgColor.toColor()
        if self.bgImg != ""{
            let imageView = UIImageView(frame: self.bounds)
            imageView.kf.setImage(with: URL(string: self.bgImg))
            self.addSubview(imageView)
        }
        //圆角
        self.layer.cornerRadius = self.radius
        self.layer.masksToBounds = true
        //左侧图片
        let imageView = UIImageView()
        self.addSubview(imageView)
        self.groupIcon = imageView
        imageView.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.width.height.equalTo(85)
            make.top.equalTo(17)
        }
        if self.groupData?.index_pic == "" || self.groupData?.index_pic == nil {
            imageView.image = UIImage(named: "groupHead")
        } else {
            imageView.kf.setImage(with: URL(string: self.groupData?.index_pic ?? ""), placeholder: UIImage(named: "groupHead"), options: nil, progressBlock: nil, completionHandler: nil)
        }
        //右上标题
        let name: String
        if self.groupData?.name == "" || self.groupData?.name == nil {
            name = "无群名称"
        } else {
            name = self.groupData?.name ?? ""
        }
        let titleLabel = UILabel()
        self.addSubview(titleLabel)
        self.groupNameLabel = titleLabel
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(14)
            make.top.equalTo(imageView.snp.top)
            make.right.equalTo(10)
            make.height.equalTo(20)
        }
        titleLabel.text = "\(name)"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        //群组简介
        let introduction: String
        if self.groupData?.introduction == "" || self.groupData?.introduction == nil {
            introduction = "群组简介 暂无"
        } else {
            introduction = self.groupData?.introduction ?? ""
        }
        let introLabel = UILabel()
        self.addSubview(introLabel)
        self.groupIntroLabel = introLabel
        introLabel.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(14)
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.right.equalTo(-10)
        }
        introLabel.numberOfLines = 3
        introLabel.text = "\(introduction)"
        introLabel.textColor = UIColor(red: 153, green: 153, blue: 153)
        introLabel.font = UIFont.systemFont(ofSize: 12)
        // 进入群组详情按钮
        let gotoSetBtn = UIButton()
        if UserUtil.share.appUserInfo?.uid == self.groupData?.build_uid {
            self.addSubview(gotoSetBtn)
            gotoSetBtn.snp.makeConstraints { make in
                make.left.right.top.equalTo(0)
                make.bottom.equalTo(imageView.snp.bottom)
            }
            gotoSetBtn.addTarget(self, action: #selector(gotoGroupSet(btn:)), for: .touchUpInside)
        }
        //加入小组
//        let addBtn = UIButton()
//        self.addSubview(addBtn)
//        addBtn.layer.cornerRadius = 12
//        addBtn.layer.masksToBounds = true
//        addBtn.layer.borderColor = UIColor.init(red: 34, green: 153, blue: 238).cgColor
//        addBtn.layer.borderWidth = 0.3
//        addBtn.setTitle(" ＋加入小组 ", for: .normal)
//        addBtn.setTitle(" ✓已加入 ", for: .selected)
//        addBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
//        addBtn.setTitleColor(UIColor.init(red: 34, green: 153, blue: 238), for: .normal)
//        addBtn.addTarget(self, action: #selector(sendApplyGroup), for: .touchUpInside)
//        addBtn.snp.makeConstraints { (make) in
//            make.centerX.equalTo(imageView.snp.centerX)
//            make.top.equalTo(imageView.snp.bottom).offset(12)
//        }
        //人数
        if personalNumber == 1 {
            let btn2 = UIButton()
            self.addSubview(btn2)
            let userNumber: Int
            if self.groupData?.user_num == nil {
                userNumber = 0
            } else {
                userNumber = self.groupData?.user_num ?? 0
            }
            btn2.setYJText(prefixText: "", icon: YJType.users4, postfixText: " \(userNumber)", size: 15, forState: .normal)
            btn2.setYJTitleColor(color: UIColor(red: 153, green: 153, blue: 153))
            btn2.snp.makeConstraints { make in
                make.right.equalTo(-10)
                make.bottom.equalTo(self.snp.bottom).offset(-5)
            }
        }
        // 分割线
        bottomLine(style: .full, color: .lightGray)
        //高度
        self.height = 120
        self.moduleDelegate?.moduleLayoutDidRefresh()
    }

    func changeInfo() {
        self.groupIcon?.kf.setImage(with: URL(string: self.groupData?.index_pic ?? ""), placeholder: UIImage(named: "groupHead"), options: nil, progressBlock: nil, completionHandler: nil)
        self.groupNameLabel?.text = "\(groupData?.name ?? "无群组名称")"
        self.groupIntroLabel?.text = "\(groupData?.introduction ?? "这个群主很懒什么都没有留下...")"
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    // MARK: 事件处理
    @objc func gotoGroupSet(btn: UIButton) {
        let editEvent = self.events?[kGroupEdit]
        editEvent?.attachment = [GroupData.getClassName: self.groupData ?? GroupData()]
        let result = EventUtil.handleEvents(event: editEvent)
        EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
    }
}
