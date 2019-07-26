//
//  ChatSessionList.swift
//  UIMaster
//
//  Created by hobson on 2018/9/26.
//  Copyright © 2018 one2much. All rights reserved.
//

import Foundation
import MobileCoreServices
import RxSwift
import SnapKit

class ChatSessionList: BaseNameVC, PageModuleAble {
    // MARK: 模块相关的配置属性
    private var bgColor = "255,255,255,1.0"//背景 颜色
    private var bgColorList = "255,255,255,1"//列表项背景 颜色
    private var bgImg = ""//背景 图片
    private var bgImgList = ""//列表项背景 图片
    private var bgImgMode = 0//背景 平铺
    private var bgImgModeList = 0//列表项背景 平铺
    private var borderColor = "230,230,230,1"//边框 颜色
    private var borderShow = 1//边框 是否显示
    private var borderShowList = 1//分割线 是否显示
    private var heightColumn: CGFloat = 80 // 行高
    private var borderWidth: CGFloat = 0//边框 宽度
    private var buttonImage = ""//内容 更多 图标图片
    private var buttonStyle = 1//内容 更多 选中哪个
    private var buttonTitle = "更多>>"//内容 更多 显示文字
    //    private var height: CGFloat = 182//高度
    private var iconTitle = ""//内容 标题栏 图标
    private var limitSwitch = 0//限制条数
    private var limits = 3//群头像
    private var more = 1//更多
    private var opacity = 1//背景 透明度
    private var opacityList = 1//列表项背景 透明度
    private var radius: CGFloat = 0//圆角
    private var splitterColorList = "230,230,230,1"//分割线 颜色
    private var splitterTypeList = "solid"//分割线 样式
    private var splitterWidthList: CGFloat = 1//分割线 宽度
    private var splitterShowList = 1
    private var titleTitle = ""//内容 标题栏 文字
    private var unreadMessageStyle = 1//未读消息样式
    private var events: [String: EventsData]?

    /// 代理
    weak var moduleDelegate: ModuleRefreshDelegate?
    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let recentConversationModel = RecentConversationModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.bgColor = recentConversationModel.styles?.bgColor ?? self.bgColor
                self.bgColorList = recentConversationModel.styles?.bgColorList ?? self.bgColorList
                self.bgImg = recentConversationModel.styles?.bgImg ?? self.bgImg
                self.bgImgList = recentConversationModel.styles?.bgImgList ?? self.bgImgList
                self.bgImgMode = recentConversationModel.styles?.bgImgMode ?? self.bgImgMode
                self.bgImgModeList = recentConversationModel.styles?.bgImgModeList ?? self.bgImgModeList
                self.borderColor = recentConversationModel.styles?.borderColor ?? self.borderColor
                self.borderShow = recentConversationModel.styles?.borderShow ?? self.borderShow
                self.borderShowList = recentConversationModel.styles?.borderShowList ?? self.borderShowList
                self.borderWidth = recentConversationModel.styles?.borderWidth ?? self.borderWidth
                self.buttonImage = recentConversationModel.fields?.buttonImage ?? self.buttonImage
                self.buttonStyle = recentConversationModel.fields?.buttonStyle ?? self.buttonStyle
                self.buttonTitle = recentConversationModel.fields?.buttonTitle ?? self.buttonTitle
                //                self.height = recentConversationModel.styles?.height ?? self.height
                self.heightColumn = recentConversationModel.styles?.heightColumn ?? self.heightColumn
                self.iconTitle = recentConversationModel.styles?.iconTitle ?? self.iconTitle
                self.limitSwitch = recentConversationModel.fields?.limitSwitch ?? self.limitSwitch
                self.limits = recentConversationModel.styles?.limits ?? self.limits
                self.more = recentConversationModel.fields?.more ?? self.more
                self.opacity = recentConversationModel.styles?.opacity ?? self.opacity
                self.opacityList = recentConversationModel.styles?.opacityList ?? self.opacityList
                self.radius = recentConversationModel.styles?.radius ?? self.radius
                self.splitterColorList = recentConversationModel.styles?.splitterColorList ?? self.splitterColorList
                self.splitterTypeList = recentConversationModel.styles?.splitterTypeList ?? self.splitterTypeList
                self.splitterShowList = recentConversationModel.styles?.splitterShowList ?? self.splitterShowList
                self.splitterWidthList = recentConversationModel.styles?.splitterWidthList ?? self.splitterWidthList
                self.titleTitle = recentConversationModel.styles?.titleTitle ?? self.titleTitle
                self.unreadMessageStyle = recentConversationModel.styles?.unreadMessageStyle ?? self.unreadMessageStyle
                self.events = recentConversationModel.events

                self.moduleDelegate?.setfullPageTableModule(table: tableView)
            }
        }
    }
    /// 参数
    var moduleParams: [String: Any]? {
        didSet {
        }
    }
    /// 所有会话
    var itemList = [ChatSessionModel]()
    /// 输入栏顶部约束
    var actionBarTopConstranit: Constraint?
    /// 声音
    var voiceIndicatorView: ChatVoiceIndicatorView?
    /// 输入栏
    lazy var chatActionBarView: ChatActionBarView = {
        guard let chatActionBarView = UIView.viewFromNib(ChatActionBarView.self) else {
            return ChatActionBarView()
        }
        chatActionBarView.delegate = self
        chatActionBarView.inputChatView.delegate = self
        chatActionBarView.inputTopContraint.constant = 30
        self.view.addSubview(chatActionBarView)
        chatActionBarView.snp.makeConstraints { [weak self] make -> Void in
            guard let strongSelf = self else {
                return
            }
            make.left.equalTo(strongSelf.view.snp.left)
            make.right.equalTo(strongSelf.view.snp.right)
            strongSelf.actionBarPaddingBottomConstranit = make.bottom.equalTo(strongSelf.view.snp.bottom).constraint
            make.height.equalTo(kChatActionBarOriginalHeight + 30)
        }
        return chatActionBarView
    }()

    /// table
    lazy var tableView: BaseTableView = {
        let table = BaseTableView(frame: CGRect.zero, style: .plain)
        table.dataSource = self
        table.delegate = self
        table.register(UINib(nibName: "ChatSessionCell", bundle: nil), forCellReuseIdentifier: "chatSessionCell")
        table.rowHeight = 80
        //            self.heightColumn
        self.view.addSubview(table)
        table.snp.makeConstraints { make -> Void in
            make.top.left.right.bottom.equalTo(self.view)
        }
        table.separatorStyle = .none
        return table
    }()
    var keyboardHeightConstraint: NSLayoutConstraint?  //键盘高度的 Constraint
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

    fileprivate var unreadID: String?
    var currentVoiceCell: ChatVoiceCell?    //现在正在播放的声音的 cell
    var isReloading: Bool = false               //UITableView 是否正在加载数据, 如果是，把当前发送的消息缓存起来后再进行发送
    var actionBarPaddingBottomConstranit: Constraint?
    var currentModel: ChatSessionModel? { //当前点击回复的是哪个
        didSet {
            if let safeHelper = self.chatHelper {
                safeHelper.setChatSessionModel(chatSessionModel: currentModel)
            } else {
                self.chatHelper = ChatHelper(chatSessionModel: currentModel)
            }
        }
    }
    var chatHelper: ChatHelper?
    lazy var maskView = { [weak self] () -> UIView in
        let view = UIView(frame: .zero)
        self?.view.addSubview(view)
        let tap = UITapGestureRecognizer()
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
        tap.rx.event
            .subscribe { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                tap.cancelsTouchesInView = false
                strongSelf.hideAllKeyboard()
            }
            .disposed(by: rx.disposeBag)
        view.isHidden = true
        view.backgroundColor = .clear
        view.snp.makeConstraints({ make in
            make.top.bottom.right.left.equalTo((self?.tableView)!)
        })
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.keyboardControl()
        self.setupActionBarButtonInterAction()
        self.setupKeyboardInputView()
        reloadViewData()
        //重新加载列表数据
        NotificationCenter.default.rx.notification(Notification.Name(kChatSessionListDataChange))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                self?.reloadViewData()
            })
            .disposed(by: rx.disposeBag)

        // 退出登录
        NotificationCenter.default.rx.notification(Notification.Name(kLogoutNotification))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                self?.itemList = []
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            })
            .disposed(by: rx.disposeBag)

        // 刷新单条
        NotificationCenter.default.rx.notification(Notification.Name(kChatSessionSingleDataChage))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] ntf in
                if let model = ntf.object as? ChatSessionModel {
                    for (index, curModel) in (self?.itemList ?? []).enumerated() where curModel.session_id == model.session_id {
                        self?.itemList[index] = model
                        DispatchQueue.main.async {
                            self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.none)
                        }
                        return
                    }
                    self?.itemList.insert(model, at: 0)
                    self?.tableView.reloadData()
                }
            })
            .disposed(by: rx.disposeBag)

        NotificationCenter.default.rx.notification(Notification.Name(kChatGroupInfoChangeNotification)).takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.reloadViewData()
                }
            })
            .disposed(by: rx.disposeBag)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 网络请求
extension ChatSessionList {
    func reloadViewData() {
        guard UserUtil.isValid() else {
            return
        }
        DatabaseTool.shared.querySessionList(finish: { chatSessionList in
            self.itemList = chatSessionList
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        })
    }
}

// MARK: - UIScrollView 代理方法
extension ChatSessionList: UITableViewDelegate & UITableViewDataSource & ChatSessionCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemList.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.itemList[indexPath.row]
        let tmpModel = ChatMessageModel()
        tmpModel.sender = model.receiver
        tmpModel.sender_pid = model.receiver_pid
        tmpModel.session_id = model.session_id
        tmpModel.groupPid = model.groupPid
        if model.chat_type == 1 {
            let pageKey = GlobalConfigTool.shared.global?.groupChatKey ?? ""
            EventUtil.gotoPage(with: pageKey, attachment: [ChatSessionModel.getClassName: model])
        } else {
            let event = self.events?[kPersonEvent]
            event?.attachment = [ChatSessionModel.getClassName: model]
            let result = EventUtil.handleEvents(event: event)
            EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatSessionCell") as? ChatSessionCell
        if cell == nil {
            return Bundle.main.loadNibNamed("ChatSessionCell", owner: nil, options: nil)?[0] as? ChatSessionCell ?? UITableViewCell()
        }
        cell?.backgroundColor = self.bgColorList.toColor()
        if !self.bgImgList.isEmpty {
            let imageView = UIImageView()
            imageView.kf.setImage(with: URL(string: self.bgImgList))
            cell?.backgroundView = imageView
        }
        cell?.lineView.height = self.splitterWidthList
        cell?.lineView.backgroundColor = self.splitterColorList.toColor()
        cell?.lineView.isHidden = self.splitterShowList == 0
        cell?.delegate = self
        cell?.selectionStyle = .none
        cell?.model = self.itemList[indexPath.row]
        return cell!
    }

    func setActionBarData(model: ChatSessionModel) {
        currentModel = model
        chatActionBarView.recieverNameLabel.text = model.nickname
        chatActionBarView.recieverAvator.kf.setImage(with: URL(string: model.avatar), placeholder: R.image.defaultPortrait(), options: nil, progressBlock: nil, completionHandler: nil)
        chatActionBarView.currentSessionID = model.session_id
        chatActionBarView.chatType = model.chat_type
        chatActionBarView.inputChatView.text = model.draft_content
        let contentHeight = chatActionBarView.inputChatView.contentSize.height
        self.chatActionBarView.inputTextViewCurrentHeight = contentHeight + 17 > kChatActionBarTextViewMaxHeight ? kChatActionBarTextViewMaxHeight : contentHeight + 17
        self.controlExpandableInputView(showExpandable: true)
        chatActionBarView.inputChatView.becomeFirstResponder()
    }

    /// 长按弹出菜单
    ///
    /// - Parameters:
    ///   - model: 会话数据
    ///   - cell: 点击的cell
    func longPressed(model: ChatSessionModel, cell: ChatSessionCell) {
        let manager = PopMenuManager.default
        manager.popMenuAppearance.popMenuBackgroundStyle = .none()
        manager.popMenuAppearance.popMenuColor.backgroundColor = .solid(fill: .white)
        manager.popMenuAppearance.popMenuItemSeparator = .fill(.darkGray, height: 1)
        manager.popMenuAppearance.popMenuCornerRadius = 3
        manager.actions.removeAll()
        DatabaseTool.shared.querySingleMessage(sessionID: model.session_id, chatType: model.chat_type, msgID: 0, pickOthers: true) { [weak self] message in
            if let id = message?.notificationID {
                self?.unreadID = id
                let markAction = PopMenuDefaultAction(title: cell.unreadLabel.isHidden ? "标记未读" : "标记已读", image: nil, color: .gray) { _ in
                    self?.markUnread(model: model, state: cell.unreadLabel.isHidden ? 1 : 0)
                }
                manager.actions.append(markAction)
            }
            let delActcion = PopMenuDefaultAction(title: "删除会话", image: nil, color: .gray) { _ in
                self?.delSession(model: model)
            }
            manager.actions.append(delActcion)
            let view = UIView(frame: CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y + cell.frame.height / 2, width: cell.frame.width, height: cell.frame.height))
            view.backgroundColor = .clear
            self?.tableView.addSubview(view)
            DispatchQueue.main.async {
                manager.present(sourceView: view, on: kWindowRootVC, animated: true) {
                    view.removeFromSuperview()
                }
            }
        }
    }

    /// 标记已读，未读
    ///
    /// - Parameter model: 会话数据模型
    func markUnread(model: ChatSessionModel, state: Int) {
        DatabaseTool.shared.modifyUnreadState(with: model.session_id, chatType: model.chat_type, unreadNum: model.unread_remind_num > 0 ? 0 : 1, reset: true)
        if state == 0 {//标记已读
            IMService.shared.setSessionMessagesRead(sessionID: model.session_id, chatType: model.chat_type)
        } else {//标记未读
            NetworkUtil.request(
                target: .addUnreadMessage(msg_id: self.unreadID ?? ""),
                success: { _ in
                    DatabaseTool.shared.modifyUnreadMessageState(with: self.unreadID ?? "", state: 1)
                }
            ) { error in
                dPrint(error)
            }
        }
        self.reloadViewData()
    }

    /// 删除会话
    ///
    /// - Parameter model: 会话数据模型
    func delSession(model: ChatSessionModel) {
        let alertVC = UIAlertController(title: "确定删除该会话？", message: "该会话相关的消息也会被删除", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { _ in
            IMService.shared.setSessionMessagesRead(sessionID: model.session_id, chatType: model.chat_type) {
                _ = DatabaseTool.shared.deleteChatSession(by: model.session_id, type: model.chat_type)
            }
        }))
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alertVC.show()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ChatSessionList: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        //弹出键盘后，避免按钮的点击事件被listTableView的手势拦截而不执行，例如播放语音
        if touch.view is UIButton {
            return false
        }
        return true
    }
}

extension ChatSessionList {
    /**
     初始化表情键盘，分享更多键盘
     */
    fileprivate func setupKeyboardInputView() {
        //emotionInputView init
        //        self.emotionInputView = UIView.viewFromNib(ChatEmotionInputView.self)
        //        self.emotionInputView.delegate = self
        //        self.view.addSubview(self.emotionInputView)
        //        self.emotionInputView.snp.makeConstraints {[weak self] (make) -> Void in
        //            guard let strongSelf = self else { return }
        //            make.left.equalTo(strongSelf.view.snp.left)
        //            make.right.equalTo(strongSelf.view.snp.right)
        //            make.top.equalTo(strongSelf.chatActionBarView.snp.bottom).offset(0)
        //            make.height.equalTo(kCustomKeyboardHeight)
        //        }
        //
        //shareMoreView init
        self.shareMoreView = UIView.viewFromNib(ChatShareMoreView.self) ?? ChatShareMoreView()
        self.shareMoreView.delegate = self.chatHelper
        self.view.addSubview(self.shareMoreView)
        self.shareMoreView.snp.makeConstraints { [weak self] make -> Void in
            guard let strongSelf = self else {
                return
            }
            make.left.equalTo(strongSelf.view.snp.left)
            make.right.equalTo(strongSelf.view.snp.right)
            make.top.equalTo(strongSelf.chatActionBarView.snp.bottom).offset(0)
            make.height.equalTo(kCustomKeyboardHeight)
        }
    }

    /**
     初始化操作栏的 button 事件。包括 声音按钮，录音按钮，表情按钮，分享按钮 等各种事件的交互
     */
    func setupActionBarButtonInterAction() {
        let voiceButton: ChatButton = self.chatActionBarView.voiceBtn
        //        let recordButton: UIButton = self.chatActionBarView.recordBtn
        //        let emotionButton: ChatButton = self.chatActionBarView.emojiBtn
        let shareButton: ChatButton = self.chatActionBarView.shareBtn

        //切换声音按钮
        voiceButton.rx.tap
            .subscribe { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.chatActionBarView.resetButtonUI()
                //根据不同的状态进行不同的键盘交互
                let showRecoring = strongSelf.chatActionBarView.recordBtn.isHidden
                if showRecoring {
                    strongSelf.chatActionBarView.showRecording()
                    voiceButton.emotionSwiftVoiceButtonUI(showKeyboard: true)
                    strongSelf.controlExpandableInputView(showExpandable: false)
                } else {
                    strongSelf.chatActionBarView.showTyingKeyboard()
                    voiceButton.emotionSwiftVoiceButtonUI(showKeyboard: false)
                    strongSelf.controlExpandableInputView(showExpandable: true)
                }
            }
            .disposed(by: rx.disposeBag)

        //        录音按钮
        //            var finishRecording: Bool = true  //控制滑动取消后的结果，决定停止录音还是取消录音
        //            let longTap = UILongPressGestureRecognizer()
        //            recordButton.addGestureRecognizer(longTap)
        //            longTap.rx.event.subscribe {[weak self] _ in
        //                guard let strongSelf = self else { return }
        //                if longTap.state == .began { //长按开始
        //                    finishRecording = true
        //                    strongSelf.voiceIndicatorView.recording()
        //                    AudioRecordInstance.startRecord()
        //                    recordButton.replaceRecordButtonUI(isRecording: true)
        //                } else if longTap.state == .changed { //长按平移
        //                    let point = longTap.location(in: self!.voiceIndicatorView)
        //                    if strongSelf.voiceIndicatorView.point(inside: point, with: nil) {
        //                        strongSelf.voiceIndicatorView.slideToCancelRecord()
        //                        finishRecording = false
        //                    } else {
        //                        strongSelf.voiceIndicatorView.recording()
        //                        finishRecording = true
        //                    }
        //                } else if longTap.state == .ended { //长按结束
        //                    if finishRecording {
        //                        AudioRecordInstance.stopRecord()
        //                    } else {
        //                        AudioRecordInstance.cancelRrcord()
        //                    }
        //                    strongSelf.voiceIndicatorView.endRecord()
        //                    recordButton.replaceRecordButtonUI(isRecording: false)
        //                }
        //                }.disposed(by: rx.disposeBag)

        //表情按钮
        //        emotionButton.rx.tap.subscribe {[weak self] _ in
        //            guard let strongSelf = self else { return }
        //            strongSelf.chatActionBarView.resetButtonUI()
        //            //设置 button 的UI
        //            emotionButton.replaceEmotionButtonUI(showKeyboard: !emotionButton.showTypingKeyboard)
        //            //根据不同的状态进行不同的键盘交互
        //            if emotionButton.showTypingKeyboard {
        //                strongSelf.chatActionBarView.showTyingKeyboard()
        //            } else {
        //                strongSelf.chatActionBarView.showEmotionKeyboard()
        //            }
        //
        //            strongSelf.controlExpandableInputView(showExpandable: true)
        //            }.disposed(by: self.disposeBag)

        //分享按钮
        shareButton.rx.tap
            .subscribe { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.chatActionBarView.resetButtonUI()
                //根据不同的状态进行不同的键盘交互
                if shareButton.showTypingKeyboard {
                    strongSelf.chatActionBarView.showTyingKeyboard()
                } else {
                    strongSelf.chatActionBarView.showShareKeyboard()
                }

                strongSelf.controlExpandableInputView(showExpandable: true)
            }
            .disposed(by: rx.disposeBag)

        //文字框的点击，唤醒键盘
        let textView: UITextView = self.chatActionBarView.inputChatView
        let tap = UITapGestureRecognizer()
        textView.addGestureRecognizer(tap)
        tap.rx.event
            .subscribe { _ in
                textView.inputView = nil
                textView.becomeFirstResponder()
                textView.reloadInputViews()
            }
            .disposed(by: rx.disposeBag)
    }

    /**
     Control the actionBarView height:
     We should make actionBarView's height to original value when the user wants to show recording keyboard.
     Otherwise we should make actionBarView's height to currentHeight
     
     - parameter showExpandable: show or hide expandable inputTextView
     */
    func controlExpandableInputView(showExpandable: Bool) {
        let textView = self.chatActionBarView.inputChatView
        let currentTextHeight = self.chatActionBarView.inputTextViewCurrentHeight
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            let textHeight = showExpandable ? currentTextHeight : kChatActionBarOriginalHeight + 30
            self.chatActionBarView.snp.updateConstraints { make -> Void in
                make.height.equalTo(textHeight + 30)
            }
            textView?.scrollRangeToVisible(NSRange(location: 0, length: 1))
            self.view.layoutIfNeeded()
        })
    }
}
