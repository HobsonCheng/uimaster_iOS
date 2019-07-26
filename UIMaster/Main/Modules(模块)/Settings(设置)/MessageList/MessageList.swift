//
//  MessageList.swift
//  UIMaster
//
//  Created by hobson on 2018/7/6.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

class MessageModel: BaseModel {
    var data: [MessageData]?
}

// swiftlint:disable identifier_name
class MessageData: BaseData {
    var action: Int?
    var add_time: String?
    var update_time: String?
    var action_time: String?
    var target_name: String?
    var sender_name: String?
    var action_name: String?
    var action_object_name: String?
    var sender: Int64?
    var target: Int64?
    var sender_pid: Int64?
}

class MessageListModel: BaseData {
    var events: [String: EventsData]?
    var styles: MessageListStyles?
}

class MessageListStyles: BaseStyleModel {
    var Style: Int?
    var bgImgSys: String?
    var bgImgModeSys: Int?
    var opacitySys: Int?
    var bgColorSys: String?
    var borderColor: String?
    var borderShow: Int?
    var opacity: Int?
    var borderWidth: Int?
    var lineHeight: Int?
    var heightSpacing: CGFloat?
}

// swiftlint:enable identifier_name

//  模块通用模板,保持整体完整性，
//  不需要的部分可以先注释掉，之后完成后，再统一删掉
//  可以参考MessageList模块，如果涉及到分页显示数据，请参考GroupListTopic模块

class MessageList: BaseTableView, PageModuleAble {
    // MARK: 模块相关的配置属性
//    private var messageListStyle = 0//布局样式选择
    private var bgColor = "255,255,255,1.0"//项背景 颜色
    private var bgColorSys = "255,255,255,1.0"//背景 颜色
    private var bgImg = ""//项背景 图片
    private var bgImgMode = 0//项背景 平铺
    private var bgImgModeSys = 0//背景 平铺
    private var bgImgSys = ""//背景 图片
    private var borderColor = "230,230,230,1"//边框 颜色
    private var borderShow = 1//边框 是否显示
    private var borderWidth = 0//边框 宽度
    private var spacing: CGFloat = 0//项间距
    private var lineHeight = 0//行高
    private var opacity = 1//项背景 透明度
    private var opacitySys = 1//
    private var radius: CGFloat = 0//圆角

    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let messageListModel = MessageListModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
//                self.messageListStyle = messageListModel.styles?.messageListStyle ?? self.style
                self.bgColor = messageListModel.styles?.bgColor ?? self.bgColor
                self.bgColorSys = messageListModel.styles?.bgColorSys ?? self.bgColorSys
                self.bgImg = messageListModel.styles?.bgImg ?? self.bgImg
                self.bgImgMode = messageListModel.styles?.bgImgMode ?? self.bgImgMode
                self.bgImgModeSys = messageListModel.styles?.bgImgModeSys ?? self.bgImgModeSys
                self.bgImgSys = messageListModel.styles?.bgImgSys ?? self.bgImgSys
                self.borderColor = messageListModel.styles?.borderColor ?? self.borderColor
                self.borderShow = messageListModel.styles?.borderShow ?? self.borderShow
                self.borderWidth = messageListModel.styles?.borderWidth ?? self.borderWidth
                self.spacing = messageListModel.styles?.heightSpacing ?? self.spacing
                self.lineHeight = messageListModel.styles?.lineHeight ?? self.lineHeight
                self.opacity = messageListModel.styles?.opacity ?? self.opacity
                self.opacitySys = messageListModel.styles?.opacitySys ?? self.opacitySys
                self.radius = messageListModel.styles?.radius ?? self.radius
                self.moduleDelegate?.setfullPageTableModule(table: self)
                //渲染UI
                renderUI()
                //获取数据
                reloadViewData()
            }
        }
    }

    //模块特有属性
    private var itemList: [MessageData]?//保存M2请求回来的数据
    private var pageNum: Int = 1//如果涉及到数据分页，需要此变量
    private var rowHeightDic = [Int: CGFloat]()
    weak var moduleDelegate: ModuleRefreshDelegate?

    // MARK: init方法
    init(frame: CGRect) {
        super.init(frame: frame, style: .plain)
        self.dataSource = self
        self.delegate = self
        self.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "message")
        self.register(UINib(nibName: "AddFriendCell", bundle: nil), forCellReuseIdentifier: "addFriend")
        self.register(UINib(nibName: "MessageCell2", bundle: nil), forCellReuseIdentifier: "MessageCell2")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 网络请求
extension MessageList {
    //页面刷新时会调用该方法
    func reloadViewData() {
        //加载更多时，分页数加1，不需要分页可以去掉下面这行
        self.pageNum = 1
        //请求M2数据信息
        self.requestMessageListData()
    }

    func loadMoreData() {
        self.pageNum += 1
        //请求M2数据信息
        self.requestMessageListData()
    }

    //获取MessageList数据
    private func requestMessageListData() {
        NetworkUtil.request(
            target: .getUserNotifyListByUser(page_index: self.pageNum, page_context: 20),
            success: { [weak self] json in
                //请求成功
                //如果数据需要分页，使用下面的代码
                let tmpList = MessageModel.deserialize(from: json)?.data
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
                //处理UI
                //请求完成，回调告知AssembleVC停止刷新
                self?.moduleDelegate?.moduleLayoutDidRefresh()
            }
        ) { error in
            dPrint(error)
        }
    }
}

// MARK: - UI&事件处理
extension MessageList {
    //渲染UI
    private func renderUI() {
//        self.config()
        self.configRefresh()
//        self.rowHeight = 110
//        self.separatorStyle = .none
        self.backgroundColor = self.bgColorSys.toColor()
    }
}

// MARK: - 代理方法
/**
 1.协议的采纳放到该扩展上。
 2.代理方法统一放到这里，不同的代理用//MARK: 分开
 */
extension MessageList: UITableViewDelegate & UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let footer = self.mj_footer {
            if (self.itemList?.count ?? 0) <= 10 {
                footer.isHidden = true
            } else {
                footer.isHidden = false
            }
        }
        return self.itemList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.itemList?[indexPath.row].action == 3 {
            return 110 + 2 * spacing
        }
        return 44 + 2 * spacing
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.itemList?[indexPath.row].action == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addFriend") as? AddFriendCell
            cell?.spacing = spacing
            cell?.selectionStyle = .none
            cell?.cellModel = self.itemList?[indexPath.row]
            cell?.backgroundColor = self.bgColor.toColor()
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell2") as? MessageCell2
            cell?.backgroundColor = self.bgColor.toColor()
            cell?.spacing = spacing
            cell?.selectionStyle = .none
            cell?.timeNow.text = self.itemList?[indexPath.row].action_time?.getTimeTip()
            if self.itemList?[indexPath.row].sender_name?.isEmpty ?? true {
                cell?.userName.text = "无名氏"
            } else {
                cell?.userName.text = self.itemList?[indexPath.row].sender_name
            }
            switch self.itemList?[indexPath.row].action {
            case 4:
                cell?.postText.text = "关注了您"
            case 11:
                cell?.postText.text = "赞了您的回复"
            case 10:
                cell?.postText.text = "赞了您的帖子"
            case 5:
                cell?.postText.text = "回复了您"
            case 6:
                cell?.postText.text = "回复了您的评论"
            case 14:
                cell?.postText.text = self.itemList?[indexPath.row].action_name
            default:
                cell?.postText.text = ""
            }
            return cell!
        }
    }
}
