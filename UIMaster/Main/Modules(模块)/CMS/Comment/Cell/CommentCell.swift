//
//  CommentCell.swift
//  UIMaster
//
//  Created by hobson on 2018/7/6.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

import YYText
class CommentCell: UITableViewCell {
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var repliesView: UIView!

    @IBOutlet weak var line: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var transmitButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var buttonsContainer: UIView!
//    @IBOutlet weak var repliesConstraintH: NSLayoutConstraint!
    var replyHeight: CGFloat = 0
//    var firstReplyBtn:UIButton?//第一行回复的按钮  显示昵称
//    var secondReplyBtn:UIButton?
//    var thirdReplyBtn:UIButton?
//
//    var firstReplyLabel:UILabel?//第一行回复的标签  显示回复内容
//    var secondReplyLabel:UILabel?
//    var thirdReplyLabel:UILabel?
    var clTextView: CLTextView?
    var praiseNum = 0
    var cellObj: ReplyData? {
        didSet {
            showData()
        }
    }
    var events: [String: EventsData]?

    //查看更多按钮
    lazy var seeMoreRepliesBtn = { () -> UIButton in
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.setTitleColor(UIColor.blue, for: .normal)
        btn.addTarget(self, action: #selector(seeMore(btn:)), for: .touchUpInside)
        return btn
    }()

// MARK: - 事件处理
    override func awakeFromNib() {
        super.awakeFromNib()
        //设置按钮的iconfont
        if let commentBtn = self.commentButton {
            commentBtn.setYJText(prefixText: "", icon: YJType.comment, postfixText: "", size: 15, forState: .normal)
        }
        if let transmitBtn = self.transmitButton {
            transmitBtn.setYJText(prefixText: "", icon: YJType.report, postfixText: "", size: 15, forState: .normal)
        }
        //头像添加手势
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(didTappedIconImageView))
        self.iconImgView.isUserInteractionEnabled = true
        self.iconImgView.addGestureRecognizer(tapgesture)
        self.iconImgView.layer.cornerRadius = 25
        self.iconImgView.layer.masksToBounds = true
        self.clTextView = CLTextView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH))
        self.clTextView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.clTextView?.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        repliesView.removeAllSubviews()
        replyHeight = 0
//        repliesConstraintH.constant = 0
        cellObj = nil
    }

    private func showData() {
        if self.cellObj != nil {
            //评论内容
            self.commentLabel.text = cellObj?.content.trim()
            var nickName = cellObj?.user_info.zh_name ?? "无名氏"
            if cellObj?.user_info?.admin != 0 {
                self.iconImgView.kf.setImage(with: URL(string: cellObj?.user_info?.head_portrait ?? ""), placeholder: UIImage(named: "admin.png"), options: nil, progressBlock: nil, completionHandler: nil)
                nickName = "管理员"
            } else {
                self.iconImgView.kf.setImage(with: URL(string: self.cellObj?.user_info.head_portrait ?? ""), placeholder: UIImage(named: "defaultPortrait"), options: nil, progressBlock: nil, completionHandler: nil)
            }

            var attText = NSMutableAttributedString()
            if cellObj?.reply_user_name != nil && cellObj?.reply_user_name != "" {
                if let replySubName = cellObj?.reply_user_name {
                    let replyTip = nickName + " 回复 " + replySubName
                    attText = NSMutableAttributedString(string: replyTip)
                    setHighlightText(attText: attText, range: NSRange(location: nickName.count + 4, length: replySubName.count), uid: cellObj?.user_info.uid, pid: cellObj?.user_info.pid)
                    self.nicknameLabel.attributedText = attText
                }
            } else {
                self.nicknameLabel.text = nickName
            }

            self.timeLabel.text = cellObj?.add_time.getTimeTip() ?? "未知时间"
            praiseNum = self.cellObj?.praise_num ?? 0
            //点赞
            if let likeBtn = self.likeButton {
                let tip = cellObj?.praise_num == 0 ? "赞" : "\(cellObj?.praise_num ?? 0)"
                likeBtn.setYJText(prefixText: "", icon: .praise2, postfixText: " "+tip, size: 15, forState: .normal)
                likeBtn.setYJText(prefixText: "", icon: .praised, postfixText: " "+tip, size: 15, forState: .selected)
                likeBtn.isSelected = cellObj?.praised == 1 ? true : false
                praiseNum = self.cellObj?.praise_num ?? 0
            }
            //回复内容
            let repliesArr = self.cellObj?.reply ?? []
            if repliesArr.count <= 0 { return }
            repliesView.removeAllSubviews()
            //            let replyModel = repliesArr[0]
            //            let nickname = "\(replyModel.user_info.zh_name ?? "无名氏")"
            //            let content = replyModel.content ?? ""
            //            let nicknameBtn:UIButton = UIButton.init()
            //            nicknameBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            //            nicknameBtn.setTitle(nickname, for: .normal)
            //            nicknameBtn.setTitleColor(UIColor.blue, for: .normal)
            //            let size:CGSize = nickname.getSize(font: UIFont.systemFont(ofSize: 12))
            //            nicknameBtn.frame = CGRect(x: 3, y: size.height + 3, width: size.width - 3, height: size.height)
            //            nicknameBtn.addTarget(self, action: #selector(didTapReplyHead), for: .touchUpInside)
            //            self.repliesView.addSubview(nicknameBtn)
            //            //回复的内容
            //            let contentLabel:UILabel = UILabel.init()
            //            contentLabel.font = UIFont.systemFont(ofSize: 12)
            //            contentLabel.text = content
            //            let labelSize:CGSize = content.getSize(font: UIFont.systemFont(ofSize: 12))
            //            contentLabel.frame = CGRect(x: size.width, y: labelSize.height + 3, width: labelSize.width, height: labelSize.height)
            //            self.repliesView.addSubview(contentLabel)
            //            //label约束  或者计算高度的时候指定宽度
            //            contentLabel.snp.makeConstraints { (make) in
            //                make.left.equalTo(nicknameBtn).offset(nicknameBtn.frame.maxX + 3)
            //                make.top.equalTo(self.repliesView).offset(labelSize.height+3)
            //                make.right.equalTo(self.repliesView).offset(-5)
            //                make.height.equalTo(labelSize.height)
            //            }
            //
            //            self.seeMoreRepliesBtn.setTitle("查看\(nickname)等\(repliesArr.count)条回复", for: .normal)
            //            self.seeMoreRepliesBtn.titleLabel?.lineBreakMode = .byWordWrapping
            //            let seeMoreSize:CGSize = (self.seeMoreRepliesBtn.currentTitle?.getSize(font: UIFont.systemFont(ofSize: 12)))!
            //            self.seeMoreRepliesBtn.frame = CGRect(x: 3, y: 6, width: seeMoreSize.width, height: seeMoreSize.height)
            //            self.repliesView.addSubview(self.seeMoreRepliesBtn)
            let margin: CGFloat = 5

            for index in 0...repliesArr.count - 1 {
                let replyData = repliesArr[index]
                let textLabel = YYLabel()

                let nickName = "\(replyData.user_info.zh_name ?? "无名氏"):"
                let content = replyData.content ?? ""
//                textLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(com)))
                //完整消息内容
                var replyMessage = ""
                //AttributeString
                var attText = NSMutableAttributedString()
                attText.yy_font = UIFont.systemFont(ofSize: 12)
                attText.yy_lineBreakMode = NSLineBreakMode.byCharWrapping
                if replyData.reply_user_name != nil && replyData.reply_user_name != ""{
                    if let replySubName = replyData.reply_user_name {
                        replyMessage = nickName + " 回复 " + replySubName + content.trimSpaceString()
                        attText = NSMutableAttributedString(string: replyMessage)
                        setHighlightText(attText: attText, range: NSRange(location: 0, length: nickName.count), uid: replyData.user_info.uid, pid: replyData.user_info.pid)
                        setHighlightText(attText: attText, range: NSRange(location: nickName.count + 4, length: replySubName.count), uid: replyData.reply_uid, pid: replyData.reply_pid)
                    }
                } else {
                    replyMessage = nickName + content.trimSpaceString()
                    attText = NSMutableAttributedString(string: replyMessage)
                    setHighlightText(attText: attText, range: NSRange(location: 0, length: nickName.count), uid: replyData.user_info.uid, pid: replyData.user_info.pid)
                }
//                let replySize: CGSize = replyMessage.getSizeForString(font: 12, viewWidth: kScreenW - 104 - (margin * 2))
                //textView.frame = CGRect(x: margin, y: replyHeight, width: replySize.width, height: replySize.height)
                textLabel.attributedText = attText
                textLabel.backgroundColor = .clear
                let layout = YYTextLayout(containerSize: CGSize(width: kScreenW - 104 - (margin * 2), height: CGFloat(MAXFLOAT)), text: attText)
                textLabel.textLayout = layout
//                textLabel.textVerticalAlignment = .top
//                textLabel.lineBreakMode = .byCharWrapping
                textLabel.numberOfLines = 0
//                textLabel.textContainerInset = .zero
                self.repliesView.addSubview(textLabel)
                textLabel.snp.makeConstraints { make in
                    make.left.equalTo(self.repliesView).offset(margin)
                    make.top.equalTo(self.repliesView).offset(replyHeight)
                    make.right.equalTo(-margin)
                    make.height.equalTo((layout?.textBoundingSize.height ?? 0) + 5)
                }
                replyHeight += (layout?.textBoundingSize.height ?? 0) + 5
                textLabel.lineBreakMode = .byCharWrapping
            }
            if cellObj?.reply_num > repliesArr.count {
                self.seeMoreRepliesBtn.setTitle("查看\(cellObj?.reply_num ?? 0)条回复", for: .normal)
                let seeMoreSize = self.seeMoreRepliesBtn.currentTitle?.getSizeForString(font: 12, viewWidth: self.repliesView.width) ?? .zero
                self.seeMoreRepliesBtn.frame = CGRect(x: 0, y: replyHeight, width: seeMoreSize.width, height: seeMoreSize.height)

                self.repliesView.addSubview(self.seeMoreRepliesBtn)
                replyHeight += seeMoreSize.height + margin
            }
//            self.repliesConstraintH.constant = replyHeight
            self.cellObj?.replyHeight = replyHeight
        }
    }

    /// 设置高亮的用户名，用于跳转到个人中心
    ///
    /// - Parameters:
    ///   - range: 名字的范围
    ///   - uid: 用户的uid
    ///   - pid: 用户的pid
    ///   - attText: 富文本
    func setHighlightText(attText: NSMutableAttributedString, range: NSRange, uid: Int64?, pid: Int64?) {
        attText.yy_setTextHighlight(range, color: UIColor.blue, backgroundColor: nil) { [weak self] _, _, _, _ in
            let event = self?.events?[kHeadEvent]
            NetworkUtil.request(target: .getInfo(user_id: uid ?? 0, user_pid: pid ?? 0), success: { json in
                guard let userData = UserInfoModel.deserialize(from: json)?.data else { return }
                event?.attachment =  [UserInfoData.getClassName: userData]
                let result = EventUtil.handleEvents(event: event)
                EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
            }) { error in
                HUDUtil.msg(msg: "获取个人信息失败", type: .error)
                dPrint(error)
            }
        }
    }
}

// MARK: - 事件处理
extension CommentCell: CLBottomCommentViewDelegate {
    //查看更多
    @objc func seeMore(btn: UIButton) {
        let event = self.events?[kMoreEvent]
        event?.attachment = [ReplyData.getClassName: self.cellObj!]
        let result = EventUtil.handleEvents(event: event)
        EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
    }

    //评论
    @IBAction func commentButtonClicked(_ sender: UIButton) {
        self.clTextView?.commentTextView.becomeFirstResponder()
        UIApplication.shared.keyWindow?.addSubview(self.clTextView!)
    }

    //举报
    @IBAction func reportButtonClicked(_ sender: Any) {
        let id = self.cellObj?.id ?? 0
        let pid = self.cellObj?.group_pid ?? 0
        var reason = ""
        let alertVC = UIAlertController(title: "举报", message: "请选择举报的类型", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "侵权举报", style: .destructive, handler: { _ in
            NetworkUtil.request(target: .tipOffReply(reason: reason, group_reply_id: id, group_pid: pid), success: { _ in
                reason = "侵权举报"
                HUDUtil.msg(msg: "举报成功", type: .successful)
            }) { error in
                dPrint(error)
            }
        }))

        alertVC.addAction(UIAlertAction(title: "有害信息举报", style: .destructive, handler: { _ in
            reason = "有害信息举报"
            NetworkUtil.request(target: .tipOffReply(reason: reason, group_reply_id: id, group_pid: pid), success: { _ in
                HUDUtil.msg(msg: "举报成功", type: .successful)
            }) { error in
                dPrint(error)
            }
        }))
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        kWindowRootVC?.present(alertVC, animated: true, completion: nil)
    }

    //点击点赞按钮
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        //发送请求记录按钮状态
        NetworkUtil.request(target: .praiseReply(praise: !sender.isSelected, group_reply_id: self.cellObj?.id ?? 0, group_pid: self.cellObj?.group_pid ?? 0), success: { _ in
        }) { error in
            dPrint(error)
        }
        handlePraiseBtnState()
    }

    func handlePraiseBtnState() {
        //点击之后，选中状态置反
        let isSelected = !self.likeButton.isSelected
        if isSelected {
            praiseNum += 1
            self.likeButton.setYJText(prefixText: "", icon: .praised, postfixText: " \(praiseNum)", size: 14, forState: .selected)
        } else {
            praiseNum -= 1
            let unPraisedTip = praiseNum == 0 ? " 赞" : " \(praiseNum)"
            self.likeButton.setYJText(prefixText: "", icon: .praise, postfixText: unPraisedTip, size: 14, forState: .normal)
        }
        self.likeButton.isSelected = isSelected
    }

    @objc func didTapReplyHead (sender: UIButton) {
        HUDUtil.msg(msg: "点击了用户昵称", type: .successful)
    }

    @objc func didTappedIconImageView (tap: UITapGestureRecognizer) {
        let event = events?[kHeadEvent]
        NetworkUtil.request(target: NetworkService.getInfo(user_id: cellObj?.user_info.uid ?? 0, user_pid: cellObj?.user_info.pid ?? 0), success: { json in
            let userModel = UserInfoModel.deserialize(from: json)?.data
            event?.attachment = [UserInfoData.getClassName: userModel ?? UserInfoData()]
            let result = EventUtil.handleEvents(event: event)
            EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
        }) { error in
            HUDUtil.msg(msg: "获取个人信息失败", type: .error)
            dPrint(error)
        }
    }

    func bottomViewDidShare() {
    }

    func bottomViewDidMark(_ markButton: UIButton) {
    }

    func cl_textViewDidChange(_ textView: CLTextView) {
    }

    func cl_textViewDidEndEditing(_ textView: CLTextView) {
        if textView.commentTextView.text.count != 0 {
            NetworkUtil.request(target: .addReply(content: textView.commentTextView.text, group_invitation_id: self.cellObj?.invitation_id ?? 0, group_pid: self.cellObj?.group_pid ?? 0, parent_id:self.cellObj?.id ?? 0), success: { _ in
                let commentNotification = Notification(name: Notification.Name(rawValue: kDidCommentNotification), object: nil, userInfo: nil)
                NotificationCenter.default.post(commentNotification)
            }) { error in
                dPrint(error)
            }
        }
    }
}
