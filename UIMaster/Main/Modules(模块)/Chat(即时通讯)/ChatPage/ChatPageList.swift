//
//  ChatPageList.swift
//  UIMaster
//
//  Created by hobson on 2018/9/27.
//  Copyright © 2018 one2much. All rights reserved.
//

import IQKeyboardManagerSwift
import RxSwift
import SnapKit
import UIKit

private let kChatLoadMoreOffset: CGFloat = 30

class ChatPageList: BaseNameVC, PageModuleAble, AVPermissionCheckAble {
    // MARK: 模块相关的配置属性
    private var articleListStyle = 0//底部标签样式
    private var bgColorInput = "255,255,255,1"//录入框背景 颜色
    private var bgColorLabel = "245,245,245,1"//标签背景 颜色
    private var bgColorMenu = "235,235,235,1"//+号菜单背景 颜色
    private var bgColorMy = "34,153,238,1"//己方聊天边框背景 颜色
    private var bgColorSwitchButton = "204,204,204,1"//+号菜单切换按钮默认颜色
    private var bgColorSwitchButtonSelected = "34,153,238,1"//+号菜单切换按钮选中颜色
    private var bgColorSys = "255,255,255,1"//背景 颜色
    private var bgColorSysMsg = "250,250,250,1.0"//系统消息 背景 颜色
    private var bgColorYour = "255,255,255,1"// 对方气泡 背景 颜色
    private var bgImgInput = ""//录入框背景 图片
    private var bgImgLabel = ""//标签 图片
    private var bgImgMenu = ""//+号菜单背景 图片
    private var bgImgModeInput = 0//录入框背景 平铺
    private var bgImgModeLabel = 0//标签 平铺
    private var bgImgModeMenu = 0//+号菜单背景 平铺
    private var bgImgModeMy = 0//己方聊天边框背景 平铺
    private var bgImgModeSwitchButton = 0//+号菜单切换按钮默认颜色 平铺
    private var bgImgModeSwitchButtonSelected = 0//+号菜单切换按钮选中颜色 平铺
    private var bgImgModeSys = 0//背景 平铺
    private var bgImgModeSysMsg = 0//系统消息 平铺
    private var bgImgModeYour = 0//对方气泡 背景 平铺
    private var bgImgMy = ""//己方聊天边框背景 图片
    private var bgImgSwitchButton = ""//+号菜单切换按钮默认颜色 图片
    private var bgImgSwitchButtonSelected = ""//+号菜单切换按钮选中颜色 图片
    private var bgImgSys = ""//背景 图片
    private var bgImgSysMsg = ""//系统消息 图片
    private var bgImgYour = ""//对方气泡 图片
    private var borderColor = "212,212,212,1"//+号菜单边框 颜色
    private var borderColorInput = "233,233,233,1"//录入框边框 颜色
    private var borderColorLabel = "216,216,216,1"//标签边框 颜色
    private var borderColorMy = "212,212,212,1"//己方聊天气泡边框 颜色
    private var borderColorSys = "230,230,230,1"//边框 颜色
    private var borderColorYour = "212,212,212,1"//对方气泡边框颜色
    private var borderShow = 1//+号菜单边框是否显示
    private var borderShowInput = 1//录入框边框 是否显示
    private var borderShowLabel = 1//标签边框 是否显示
    private var borderShowMy = 1//己方聊天气泡边框 是否显示
    private var borderShowSys = 1//边框 是否显示
    private var borderShowYour = 1//对方气泡边框 是否显示
    private var borderWidth = 0//+号菜单边框 宽度
    private var borderWidthInput = 0//录入框边框 宽度
    private var borderWidthLabel = 0//标签背景 宽度
    private var borderWidthMy = 0//己方聊天气泡边框 宽度
    private var borderWidthSys = 0//边框 宽度
    private var borderWidthYour = 0//对方气泡边框 宽度
    private var card = 1// 内容 名片开关
    private var heightInput = 35//录入框高度
    private var heightLabel = 45//标签高度
    private var heightMenu = 196//+号菜单高度
    private var heightSysMsg = 20//系统消息 高度
    private var iconCard = ""// 内容 ，名片 图标
    private var iconNormalCamera = ""//内容 相机 图片
    private var iconNormalFace = ""//内容 表情 图片
    private var iconNormalMenu = ""//内容 +号菜单 图片
    private var iconNormalPhoto = ""//内容 照片 图片
    private var iconNormalPosition = ""//内容 位置 图片
    private var iconNormalVideo = ""//内容 小视频 图片
    private var iconNormalVoice = ""//内容 语音 图片
    private var iconPhoto = ""//照片 图标
    private var iconPhotograph = ""//拍照 图标
    private var iconPosition = ""//内容 位置 开关
    private var iconSelectedCamera = ""//内容  相机  选中
    private var iconSelectedFace = ""//内容 表情 选中
    private var iconSelectedMenu = ""//内容 +号菜单 选中
    private var iconSelectedPhoto = ""//内容 照片 选中
    private var iconSelectedPosition = ""//内容 位置 选中
    private var iconSelectedVideo = ""//内容 小视频 选中
    private var iconSelectedVoice = ""//内容 语音 选中
    private var iconVideo = ""//小视频 图标
    private var imgTextMargin = 12//+号菜单图文间距
    private var inputPrompt = 0//录入框 提示文字
    private var opacityInput = 1//录入框背景 透明度
    private var opacityLabel = 1//标签边框 透明度
    private var opacityMenu = 1//+号菜单背景 透明度
    private var opacityMy = 1//己方聊天边框背景 透明度
    private var opacitySwitchButton = 1//+号菜单切换按钮默认颜色 透明度
    private var opacitySwitchButtonSelected = 1//+号菜单切换按钮选中颜色 透明度
    private var opacitySys = 1//背景 透明度
    private var opacitySysMsg = 1//系统消息 透明度
    private var opacityYour = 1//对方气泡 透明度
    private var photo = 1// 照片 开关
    private var photograph = 1//拍照 开关
    private var position = 1//位置 开关
    private var radius: CGFloat = 0//圆角
    private var text = ""//内容 录入框 提示文字
    private var titleCard = ""//内容 名片 文字
    private var titlePhoto = ""//照片 文字
    private var titlePhotograph = ""// 拍照 文字
    private var titlePosition = ""//内容 位置 文字
    private var titleVideo = ""//小视频 文字
    private var video = 1// 小视频 开关

    /// 代理也就是所在的组装VC
    weak var moduleDelegate: ModuleRefreshDelegate?
    ///样式传递
    var styleDic: [String: Any]? {
        didSet {
            if let chatPageModel = ChatPageModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.articleListStyle = chatPageModel.styles?.articleListStyle ?? self.articleListStyle
                self.bgColorInput = chatPageModel.styles?.bgColorInput ?? self.bgColorInput
                self.bgColorLabel = chatPageModel.styles?.bgColorLabel ?? self.bgColorLabel
                self.bgColorMenu = chatPageModel.styles?.bgColorMenu ?? self.bgColorMenu
                self.bgColorMy = chatPageModel.styles?.bgColorMy ?? self.bgColorMy
                self.bgColorSwitchButton = chatPageModel.styles?.bgColorSwitchButton ?? self.bgColorSwitchButton
                self.bgColorSwitchButtonSelected = chatPageModel.styles?.bgColorSwitchButtonSelected ?? self.bgColorSwitchButtonSelected
                self.bgColorSys = chatPageModel.styles?.bgColorSys ?? self.bgColorSys
                self.bgColorSysMsg = chatPageModel.styles?.bgColorSysMsg ?? self.bgColorSysMsg
                self.bgColorYour = chatPageModel.styles?.bgColorYour ?? self.bgColorYour
                self.bgImgInput = chatPageModel.styles?.bgImgInput ?? self.bgImgInput
                self.bgImgLabel = chatPageModel.styles?.bgImgLabel ?? self.bgImgLabel
                self.bgImgMenu = chatPageModel.styles?.bgImgMenu ?? self.bgImgMenu
                self.bgImgModeInput = chatPageModel.styles?.bgImgModeInput ?? self.bgImgModeInput
                self.bgImgModeLabel = chatPageModel.styles?.bgImgModeLabel ?? self.bgImgModeLabel
                self.bgImgModeMenu = chatPageModel.styles?.bgImgModeMenu ?? self.bgImgModeMenu
                self.bgImgModeMy = chatPageModel.styles?.bgImgModeMy ?? self.bgImgModeMy
                self.bgImgModeSwitchButton = chatPageModel.styles?.bgImgModeSwitchButton ?? self.bgImgModeSwitchButton
                self.bgImgModeSwitchButtonSelected = chatPageModel.styles?.bgImgModeSwitchButtonSelected ?? self.bgImgModeSwitchButtonSelected
                self.bgImgModeSys = chatPageModel.styles?.bgImgModeSys ?? self.bgImgModeSys
                self.bgImgModeSysMsg = chatPageModel.styles?.bgImgModeSysMsg ?? self.bgImgModeSysMsg
                self.bgImgModeYour = chatPageModel.styles?.bgImgModeYour ?? self.bgImgModeYour
                self.bgImgMy = chatPageModel.styles?.bgImgMy ?? self.bgImgMy
                self.bgImgSwitchButton = chatPageModel.styles?.bgImgSwitchButton ?? self.bgImgSwitchButton
                self.bgImgSwitchButtonSelected = chatPageModel.styles?.bgImgSwitchButtonSelected ?? self.bgImgSwitchButtonSelected
                self.bgImgSys = chatPageModel.styles?.bgImgSys ?? self.bgImgSys
                self.bgImgSysMsg = chatPageModel.styles?.bgImgSysMsg ?? self.bgImgSysMsg
                self.bgImgYour = chatPageModel.styles?.bgImgYour ?? self.bgImgYour
                self.borderColor = chatPageModel.styles?.borderColor ?? self.borderColor
                self.borderColorInput = chatPageModel.styles?.borderColorInput ?? self.borderColorInput
                self.borderColorLabel = chatPageModel.styles?.borderColorLabel ?? self.borderColorLabel
                self.borderColorMy = chatPageModel.styles?.borderColorMy ?? self.borderColorMy
                self.borderColorSys = chatPageModel.styles?.borderColorSys ?? self.borderColorSys
                self.borderColorYour = chatPageModel.styles?.borderColorYour ?? self.borderColorYour
                self.borderShow = chatPageModel.styles?.borderShow ?? self.borderShow
                self.borderShowInput = chatPageModel.styles?.borderShowInput ?? self.borderShowInput
                self.borderShowLabel = chatPageModel.styles?.borderShowLabel ?? self.borderShowLabel
                self.borderShowMy = chatPageModel.styles?.borderShowMy ?? self.borderShowMy
                self.borderShowSys = chatPageModel.styles?.borderShowSys ?? self.borderShowSys
                self.borderShowYour = chatPageModel.styles?.borderShowYour ?? self.borderShowYour
                self.borderWidth = chatPageModel.styles?.borderWidth ?? self.borderWidth
                self.borderWidthInput = chatPageModel.styles?.borderWidthInput ?? self.borderWidthInput
                self.borderWidthLabel = chatPageModel.styles?.borderWidthLabel ?? self.borderWidthLabel
                self.borderWidthMy = chatPageModel.styles?.borderWidthMy ?? self.borderWidthMy
                self.borderWidthSys = chatPageModel.styles?.borderWidthSys ?? self.borderWidthSys
                self.borderWidthYour = chatPageModel.styles?.borderWidthYour ?? self.borderWidthYour
                self.card = chatPageModel.fields?.card ?? self.card
                //                self.heightInput = chatPageModel.styles?.heightInput ?? self.heightInput
                //                self.heightLabel = chatPageModel.styles?.heightLabel ?? self.heightLabel
                //                self.heightMenu = chatPageModel.styles?.heightMenu ?? self.heightMenu
                //                self.heightSysMsg = chatPageModel.styles?.heightSysMsg ?? self.heightSysMsg
                self.iconCard = chatPageModel.styles?.iconCard ?? self.iconCard
                self.iconNormalCamera = chatPageModel.styles?.iconNormalCamera ?? self.iconNormalCamera
                self.iconNormalFace = chatPageModel.styles?.iconNormalFace ?? self.iconNormalFace
                self.iconNormalMenu = chatPageModel.styles?.iconNormalMenu ?? self.iconNormalMenu
                self.iconNormalPhoto = chatPageModel.styles?.iconNormalPhoto ?? self.iconNormalPhoto
                self.iconNormalPosition = chatPageModel.styles?.iconNormalPosition ?? self.iconNormalPosition
                self.iconNormalVideo = chatPageModel.styles?.iconNormalVideo ?? self.iconNormalVideo
                self.iconNormalVoice = chatPageModel.styles?.iconNormalVoice ?? self.iconNormalVoice
                self.iconPhoto = chatPageModel.styles?.iconPhoto ?? self.iconPhoto
                self.iconPhotograph = chatPageModel.styles?.iconPhotograph ?? self.iconPhotograph
                self.iconPosition = chatPageModel.styles?.iconPosition ?? self.iconPosition
                self.iconSelectedCamera = chatPageModel.styles?.iconSelectedCamera ?? self.iconSelectedCamera
                self.iconSelectedFace = chatPageModel.styles?.iconSelectedFace ?? self.iconSelectedFace
                self.iconSelectedMenu = chatPageModel.styles?.iconSelectedMenu ?? self.iconSelectedMenu
                self.iconSelectedPhoto = chatPageModel.styles?.iconSelectedPhoto ?? self.iconSelectedPhoto
                self.iconSelectedPosition = chatPageModel.styles?.iconSelectedPosition ?? self.iconSelectedPosition
                self.iconSelectedVideo = chatPageModel.styles?.iconSelectedVideo ?? self.iconSelectedVideo
                self.iconSelectedVoice = chatPageModel.styles?.iconSelectedVoice ?? self.iconSelectedVoice
                self.iconVideo = chatPageModel.styles?.iconVideo ?? self.iconVideo
                //                self.imgTextMargin = chatPageModel.styles?.imgTextMargin ?? self.imgTextMargin
                //                self.inputPrompt = chatPageModel.fields?.inputPrompt ?? self.inputPrompt
                self.opacityInput = chatPageModel.styles?.opacityInput ?? self.opacityInput
                self.opacityLabel = chatPageModel.styles?.opacityLabel ?? self.opacityLabel
                self.opacityMenu = chatPageModel.styles?.opacityMenu ?? self.opacityMenu
                self.opacityMy = chatPageModel.styles?.opacityMy ?? self.opacityMy
                self.opacitySwitchButton = chatPageModel.styles?.opacitySwitchButton ?? self.opacitySwitchButton
                self.opacitySwitchButtonSelected = chatPageModel.styles?.opacitySwitchButtonSelected ?? self.opacitySwitchButtonSelected
                self.opacitySys = chatPageModel.styles?.opacitySys ?? self.opacitySys
                self.opacitySysMsg = chatPageModel.styles?.opacitySysMsg ?? self.opacitySysMsg
                self.opacityYour = chatPageModel.styles?.opacityYour ?? self.opacityYour
                self.photo = chatPageModel.fields?.photo ?? self.photo
                self.photograph = chatPageModel.fields?.photograph ?? self.photograph
                self.position = chatPageModel.fields?.position ?? self.position
                self.radius = chatPageModel.styles?.radius ?? self.radius
                self.text = chatPageModel.fields?.text ?? self.text
                self.titleCard = chatPageModel.styles?.titleCard ?? self.titleCard
                self.titlePhoto = chatPageModel.styles?.titlePhoto ?? self.titlePhoto
                self.titlePhotograph = chatPageModel.styles?.titlePhotograph ?? self.titlePhotograph
                self.titlePosition = chatPageModel.styles?.titlePosition ?? self.titlePosition
                self.titleVideo = chatPageModel.styles?.titleVideo ?? self.titleVideo
                self.video = chatPageModel.fields?.video ?? self.video

                //                self.moduleDelegate?.setfullPageTableModule(table: listTableView)
            }
        }
    }
    /// 参数传递
    var moduleParams: [String: Any]? {
        didSet {
            self.currentSessionModel = moduleParams?[ChatSessionModel.getClassName] as? ChatSessionModel ?? ChatSessionModel()
            // 设置导航栏标题
            self.moduleDelegate?.handleNavibarItems(isHidden: false, position: .middle(title: self.currentSessionModel.nickname), params: nil)
            //给导航栏按钮传值
            if self.currentSessionModel.chat_type == 0 {
                self.moduleDelegate?.handleNavibarItems(isHidden: false, position: .right(index: 0), params: ["PCTuple": (self.currentSessionModel.receiver, self.currentSessionModel.receiver_pid)])
            } else {
                DatabaseTool.shared.queryChatGroupInfo(gid: self.currentSessionModel.session_id >> 32, pid: self.currentSessionModel.groupPid) { model in
                    if let safeModel = model {
                        DispatchQueue.main.async {
                            self.moduleDelegate?.handleNavibarItems(isHidden: false, position: .right(index: 0), params: [ChatGroupDetailData.getClassName: safeModel])
                        }
                    }
                }
            }
            //获取第一屏的数据
            self.firstFetchMessageList()
            // 设置输入框
            self.chatActionBarView.currentSessionID = self.currentSessionModel.session_id
            self.chatActionBarView.chatType = self.currentSessionModel.chat_type
            self.chatActionBarView.inputChatView.text = self.currentSessionModel.draft_content
            let contentHeight = chatActionBarView.inputChatView.contentSize.height
            self.chatActionBarView.inputTextViewCurrentHeight = contentHeight + 17 > kChatActionBarTextViewMaxHeight ? kChatActionBarTextViewMaxHeight : contentHeight + 17
            self.controlExpandableInputView(showExpandable: true)
            // 将该会话的未读清零
            DatabaseTool.shared.modifyUnreadState(with: self.currentSessionModel.session_id, chatType: currentSessionModel.chat_type, unreadNum: 0, reset: true, updateUI: true)
            // 告知后台，该会话的消息已读
            IMService.shared.setSessionMessagesRead(sessionID: self.currentSessionModel.session_id, chatType: currentSessionModel.chat_type)
            self.chatHelper = ChatHelper(chatSessionModel: self.currentSessionModel)
        }
    }
    // 聊天内容列表
    lazy var listTableView: BaseTableView = {
        let listTableView = BaseTableView(frame: .zero, style: .plain)
        listTableView.dataSource = self
        listTableView.delegate = self
        listTableView.backgroundColor = UIColor.clear
        listTableView.separatorStyle = .none
        listTableView.registerCellNib(ChatTextCell.self)
        listTableView.registerCellNib(ChatImageCell.self)
        listTableView.registerCellNib(ChatVoiceCell.self)
        listTableView.registerCellNib(ChatSystemCell.self)
        listTableView.registerCellNib(ChatTimeCell.self)
        listTableView.registerCellNib(ChatFileCell.self)
        listTableView.tableFooterView = UIView()
        listTableView.estimatedRowHeight = 0
        listTableView.estimatedSectionHeaderHeight = 0
        listTableView.estimatedSectionFooterHeight = 0
        let tap = UITapGestureRecognizer()
        tap.cancelsTouchesInView = false
        tap.delegate = self
        listTableView.addGestureRecognizer(tap)
        tap.rx.event
            .subscribe { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.hideAllKeyboard()
            }
            .disposed(by: rx.disposeBag)

        self.view.addSubview(listTableView)

        listTableView.snp.makeConstraints { make -> Void in
            make.left.right.equalTo(self.view)
            make.top.equalTo(0)
            make.bottom.equalTo(self.chatActionBarView.snp.top)
        }
        return listTableView
    }()

    lazy var indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(frame: .zero)
        indicatorView.color = .gray

        return indicatorView
    }()

    //刷新view
    lazy var refreshView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 44))
        view.addSubview(indicatorView)
        indicatorView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.center.equalToSuperview()
        }
        return view
    }()

    //分享键盘
    lazy var shareMoreView: ChatShareMoreView = {
        guard let shareMoreView = UIView.viewFromNib(ChatShareMoreView.self) else {
            return ChatShareMoreView()
        }
        shareMoreView.delegate = self.chatHelper
        view.addSubview(shareMoreView)
        shareMoreView.snp.makeConstraints { [weak self] make -> Void in
            guard let strongSelf = self else {
                return
            }
            make.left.equalTo(strongSelf.view.snp.left)
            make.right.equalTo(strongSelf.view.snp.right)
            make.top.equalTo(strongSelf.chatActionBarView.snp.bottom).offset(kCustomKeyboardHeight)
            make.height.equalTo(kCustomKeyboardHeight)
        }
        return shareMoreView
    }()

    // 输入栏
    lazy var chatActionBarView: ChatActionBarView = {
        guard let chatActionBarView = UIView.viewFromNib(ChatActionBarView.self) else {
            return ChatActionBarView()
        }
        chatActionBarView.delegate = self
        chatActionBarView.inputChatView.delegate = self
        chatActionBarView.inputTopContraint.constant = 10
        chatActionBarView.recieverAvator.isHidden = true
        chatActionBarView.recieverNameLabel.isHidden = true
        self.view.addSubview(chatActionBarView)
        chatActionBarView.snp.makeConstraints { [weak self] make -> Void in
            guard let strongSelf = self else {
                return
            }
            make.left.equalTo(strongSelf.view.snp.left)
            make.right.equalTo(strongSelf.view.snp.right)
            strongSelf.actionBarPaddingBottomConstranit = make.bottom.equalTo(strongSelf.view.snp.bottom).constraint
            make.height.equalTo(kChatActionBarOriginalHeight)
        }
        return chatActionBarView
    }()
    var actionBarPaddingBottomConstranit: Constraint? //action bar 的 bottom Constraint
    var keyboardHeightConstraint: NSLayoutConstraint?  //键盘高度的 Constraint
    lazy var voiceIndicatorView: ChatVoiceIndicatorView = {
        //voiceIndicatorView init
        guard let voiceIndicatorView = UIView.viewFromNib(ChatVoiceIndicatorView.self) else {
            return ChatVoiceIndicatorView()
        }
        self.view.addSubview(voiceIndicatorView)
        voiceIndicatorView.snp.makeConstraints { [weak self] make -> Void in
            guard let strongSelf = self else {
                return
            }
            make.top.equalTo(strongSelf.view.snp.top).offset(100)
            make.left.equalTo(strongSelf.view.snp.left)
            make.bottom.equalTo(strongSelf.view.snp.bottom).offset(-100)
            make.right.equalTo(strongSelf.view.snp.right)
        }
        voiceIndicatorView.isHidden = true
        return voiceIndicatorView
    }()

    var currentVoiceCell: ChatVoiceCell?     //现在正在播放的声音的 cell
    var isReloading: Bool = false               //UITableView 是否正在加载数据, 如果是，把当前发送的消息缓存起来后再进行发送
    var isEndRefreshing: Bool = true            // 是否结束了下拉加载更多
    var itemList = [ChatMessageModel]()  //聊天内容数据集合
    var currentSessionModel = ChatSessionModel()  //所属的会话
    var startIndex = 0 //分页获取消息时的起始索引
    let queryNum = 15//每次加载几条数据
    var photoModelArr = [PhotoModel]()
    var localImages = [UIImage?]()
    var chatHelper: ChatHelper?
    var clickedCell: ChatBaseCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        listTableView.tableHeaderView = refreshView
        // 初始化
        self.keyboardControl()
        self.setupActionBarButtonInterAction()
        //新消息
        NotificationCenter.default.rx.notification(Notification.Name(kChatAddMessageNotification))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] ntf in
                guard let strongSelf = self else {
                    return
                }
                if let model = ntf.object as? ChatMessageModel, model.session_id == self?.currentSessionModel.session_id {
                    for msgModel in self?.itemList ?? [] {
                        if msgModel.msg_id == model.msg_id && model.session_id == msgModel.session_id {
                            return
                        }
                    }
                    let lastModel = self?.itemList.last
                    if model.isLateForThreeMinutes(timestamp: lastModel?.msg_id ?? 0) {
                        let chatTimeModel = ChatMessageModel()
                        chatTimeModel.kind = ChatMessageType.time.rawValue
                        chatTimeModel.session_id = self?.currentSessionModel.session_id ?? 0
                        chatTimeModel.serverid = model.msg_id
                        chatTimeModel.content = Date(timeIntervalSince1970: TimeInterval(model.msg_id / 1_000)).chatTimeString
                        strongSelf.itemList.append(chatTimeModel)
                        let insertIndexPath = IndexPath(row: strongSelf.itemList.count - 1, section: 0)
                        strongSelf.listTableView.insertRowsAtBottom([insertIndexPath])
                    }
                    strongSelf.itemList.append(model)
                    let insertIndexPath = IndexPath(row: (self?.itemList.count ?? 0) - 1, section: 0)
                    strongSelf.listTableView.insertRowsAtBottom([insertIndexPath])
                    IMService.shared.setSessionMessagesRead(sessionID: model.session_id, chatType: model.chat_type)
                }
            })
            .disposed(by: rx.disposeBag)
        // 群信息更改
        NotificationCenter.default.rx.notification(Notification.Name(kChatGroupInfoChangeNotification))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] ntf in
                if let sessionModel = ntf.object as? ChatSessionModel {
                    let title = sessionModel.nickname
                    DispatchQueue.main.async {
                        self?.moduleDelegate?.handleNavibarItems(isHidden: false, position: NavibarPositionType.middle(title: title), params: nil)
                        DatabaseTool.shared.queryChatGroupInfo(gid: sessionModel.session_id >> 32, pid: sessionModel.groupPid, finish: { info in
                            guard let safeInfo = info else {
                                return
                            }
                            self?.moduleDelegate?.handleNavibarItems(isHidden: false, position: .right(index: 0), params: [ChatGroupDetailData.getClassName: safeInfo])
                        })
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        // 刷新单条消息
        NotificationCenter.default.rx
            .notification(Notification.Name(kChatMessageSingleDataChage))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] ntf in
                if let model = ntf.object as? ChatMessageModel, model.session_id == self?.currentSessionModel.session_id {
                    for index in 0..<(self?.itemList.count ?? 0) where self?.itemList[index].msg_id == model.msg_id {
                        self?.itemList[index] = model
                        self?.listTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.none)
                    }
                }
            })
            .disposed(by: rx.disposeBag)

        //        //设置录音 delegate
        //        AudioRecordInstance.delegate = self
        //        //设置播放 delegate
        //        AudioPlayInstance.delegate = self

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        AudioRecordInstance.checkPermissionAndSetupRecord()
        //        listTableView.tableHeaderView = self.refreshView
        self.checkCameraPermission()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        IMService.shared.currentSessionID = self.currentSessionModel.session_id
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        self.hideAllKeyboard()
        IMService.shared.currentSessionID = nil
        //        AudioPlayInstance.stopPlayer()
    }
}

extension ChatPageList: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatModel = self.itemList[indexPath.row]
        let type = ChatMessageType(rawValue: chatModel.kind) ?? .text
        return type.chatCell(tableView, indexPath: indexPath, model: chatModel, viewController: self)!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let chatModel = self.itemList[indexPath.row]
        let type = ChatMessageType(rawValue: chatModel.kind) ?? .text
        return type.chatCellHeight(chatModel) + 10
    }
}

// MARK: - @protocol UIScrollViewDelegate
extension ChatPageList: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //        kChatLoadMoreOffset
        if scrollView is UITextView {
            return
        }
        if scrollView.contentOffset.y < 0 {
            if self.isEndRefreshing {
                dPrint("pull to refresh")
                self.pullToLoadMore()
            }
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView is UITextView {
            return
        }
        self.hideAllKeyboard()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView is UITextView {
            return
        }
        if scrollView.contentOffset.y - scrollView.contentInset.top < kChatLoadMoreOffset {
            if self.isEndRefreshing {
                dPrint("pull to refresh")
                self.pullToLoadMore()
            }
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ChatPageList: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        //弹出键盘后，避免按钮的点击事件被listTableView的手势拦截而不执行，例如播放语音
        if touch.view is UIButton {
            return false
        }
        return true
    }
}
