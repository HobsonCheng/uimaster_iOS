//
//  PostListTableViewCell.swift
//  UIMaster
//
//  Created by hobson on 2018/7/5.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit
//import Kingfisher
import JXPhotoBrowser
struct PhotoModel {
    /// 缩略图
    var thumbnailUrl: String?
    /// 高清图
    var highQualityUrl: String?
    /// 原图
    var rawUrl: String?
    /// 本地图片
    var localName: String?
}

protocol Commentable: AnyObject {
    func comment(topicData: TopicData)
}

class PostListCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var commentNum: UILabel!
    @IBOutlet weak var soureceLabel: UILabel!
    @IBOutlet weak var badgeLabel: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleImageView: UIImageView! {
        didSet {
            titleImageView.layer.cornerRadius = 5
            titleImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var buttonsContainer: UIStackView!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var imageConstraitH: NSLayoutConstraint!
    @IBOutlet weak var contentConstraintH: NSLayoutConstraint!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var praiseBtn: UIButton!
    @IBOutlet weak var iconImgView: UIButton!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var reportBtn: UIButton!
    @IBOutlet weak var titleLabelRightConstraint: NSLayoutConstraint!
    weak var delegate: Commentable?

    var events: EventsData?
    var praiseNum = 0
    var imgBottom: CGFloat = 0
    var spacing: CGFloat = 0
    var photoModels: [PhotoModel]? = [PhotoModel]()
    var cellModel: TopicData? {
        didSet {
            if let titleLabel = self.titleLabel {
                titleLabel.text = cellModel?.title
                titleLabel.sizeToFit()
            }
            if let timeLabel = self.timeLabel {
                timeLabel.text = cellModel?.add_time?.getTimeTip()
            }
            if let sourceLabel = self.soureceLabel {
                sourceLabel.text = cellModel?.source
            }
            if let contentLabel = self.contentLabel {
                contentLabel.text = cellModel?.summarize
            }
            if let iconView = self.iconImgView {
                if cellModel?.user_info?.admin != 0 {
                    iconView.kf.setImage(with: URL(string: cellModel?.user_info?.head_portrait ?? ""), for: .normal, placeholder: UIImage(named: "admin.png"), options: nil, progressBlock: nil, completionHandler: nil)
                } else {
                    iconView.kf.setImage(with: URL(string: cellModel?.user_info?.head_portrait ?? ""), for: .normal, placeholder: UIImage(named: "defaultPortrait.png"), options: nil, progressBlock: nil, completionHandler: nil)
                    iconView.addTarget(self, action: #selector(gotoPersonalCenter), for: .touchUpInside)
                }
            }
            if let commentNum = self.commentNum {
                commentNum.text = "\(cellModel?.all_val_num ?? 0)条评论"
            }
            if let nickname = self.nickNameLabel {
                nickname.text = cellModel?.user_info?.admin == 0 ?  cellModel?.user_info?.zh_name ?? "" : "管理员"
            }

            if let praiseBtn = self.praiseBtn {
                let tip = cellModel?.praise_num == 0 ? "点赞" : "\(cellModel?.praise_num ?? 0)"
                praiseBtn.setYJText(prefixText: "", icon: .praise, postfixText: " "+tip, size: 15, forState: .normal)
                praiseBtn.setYJText(prefixText: "", icon: .praised, postfixText: " "+tip, size: 15, forState: .selected)
                praiseBtn.isSelected = cellModel?.praised == 1 ? true : false
                praiseBtn.addTarget(self, action: #selector(praised), for: .touchUpInside)
                praiseNum = self.cellModel?.praise_num ?? 0
            }

            if self.badgeLabel != nil {
                self.badgeLabel.layer.borderColor = UIColor.red.cgColor
                self.badgeLabel.layer.borderWidth = 0.1
                self.badgeLabel.layer.cornerRadius = 4
                self.badgeLabel.layer.masksToBounds = true
                if self.cellModel?.best == 1 {
                    self.badgeLabel.setTitle("精华", for: .normal)
                } else if self.cellModel?.top == 1 {
                    self.badgeLabel.setTitle("置顶", for: .normal)
                } else {
                    self.badgeLabel.removeFromSuperview()
                    if (self.soureceLabel != nil) {
                        self.soureceLabel.snp.updateConstraints { make in
                            make.left.equalTo(self).offset(15)
                        }
                    }
                }
            }

            if let commentBtn = self.commentBtn {
                commentBtn.setYJText(prefixText: "", icon: .comment, postfixText: " 评论", size: 15, forState: .normal)
                commentBtn.addTarget(self, action: #selector(comment), for: .touchUpInside)
            }
            if let reportBtn = self.reportBtn {
                reportBtn.setYJText(prefixText: "", icon: YJType.report, postfixText: " 举报", size: 15, forState: .normal)
                reportBtn.addTarget(self, action: #selector(report), for: .touchUpInside)
            }
            if let safeImageView = self.titleImageView {
                let arr = cellModel?.attachment_value.components(separatedBy: ",") ?? []
                if arr.isEmpty {
                    safeImageView.isHidden = true
                    titleLabelRightConstraint.constant = 15
                    return
                } else {
                    safeImageView.isHidden = false
                    titleLabelRightConstraint.constant = 140
                }
                safeImageView.kf.setImage(with: URL(string: "\(arr[0])?imageMogr2/thumbnail/115x76!"), placeholder: R.image.llplaceholder(), options: nil, progressBlock: nil, completionHandler: nil)
            }
            //图片排列
            if self.imageConstraitH != nil {
                if let imgs = self.cellModel?.attachment_value {
                    let imgsArr = imgs.split(separator: ",")
                    if !(imgsArr.isEmpty) {
                        //self.imageContainer.width
                        let totalWidth = UIScreen.main.bounds.size.width
                        let margin: CGFloat = 10
                        imgBottom = 0
                        var index = 0
                        let imgWidth: CGFloat = (totalWidth - (4 * margin)) / 3
                        let imgHeight: CGFloat = imgWidth
                        photoModels?.removeAll()
                        self.imageContainer.removeAllSubviews()
                        for imgUrl in imgsArr {
                            if index > 8 { break }
                            //图片浏览器
                            let photoModel = PhotoModel(thumbnailUrl: imgUrl + "?imageMogr2/thumbnail/100x100!", highQualityUrl: imgUrl + "?imageslim", rawUrl: String(imgUrl), localName: nil)
                            photoModels?.append(photoModel)
                            //排列图片
                            let imageButton = UIButton(frame: CGRect(x: CGFloat(index % 3) * (imgWidth + margin) + margin, y: CGFloat(index / 3) * (imgHeight + margin), width: imgWidth, height: imgHeight))
                            imageButton.adjustsImageWhenHighlighted = false
//                            imageButton.imageView?.contentMode = .scaleAspectFit
                            imageButton.kf.setBackgroundImage(with: URL(string: photoModel.thumbnailUrl ?? ""), for: .normal, placeholder: UIImage(named: "placeholder.png"), options: nil, progressBlock: nil, completionHandler: nil)
//                            imageButton.imageView?.kf.indicatorType = .activity
                            self.imageContainer.addSubview(imageButton)
                            imageButton.tag = index
                            imageButton.addTarget(self, action: #selector(showPhotos(btn:)), for: .touchUpInside)
                            if imageButton.bottom > imgBottom {
                                imgBottom = imageButton.bottom
                            }
                            index += 1
                        }
                        self.imageConstraitH.constant = imgBottom
                    } else {
                        self.imageConstraitH.constant = 0
                    }
                }
            }
            if self.contentConstraintH != nil {
                let size = cellModel?.summarize?.getSizeForString(font: 14, viewWidth: UIScreen.main.bounds.size.width - 20)
                self.contentConstraintH.constant = size?.height ?? 15
                self.contentLabel.layoutIfNeeded()
            }
        }
    }

    /// 更新数据
    func updateContent(cellModel: TopicData?) {
        if let commentNum = self.commentNum {
            commentNum.text = "\(cellModel?.all_val_num ?? 0)条评论"
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if let iconView = self.iconImgView {
            iconView.layer.cornerRadius = 20
            iconView.layer.masksToBounds = true
        }
        if let container = self.imageContainer {
            container.maskToBounds = true
        }
    }

    override var frame: CGRect {
        didSet {
            var newFrame = frame
//            newFrame.origin.x += spacing/2
//            newFrame.size.width -= spacing
            newFrame.origin.y += spacing
            newFrame.size.height -= spacing
            super.frame = newFrame
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let titleLabel = self.titleLabel {
            titleLabel.sizeToFit()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
// MARK: - 事件处理
extension PostListCell {
    @objc func gotoPersonalCenter() {
        let event = self.events
        guard let model = self.cellModel?.user_info else {
            return
        }
        event?.attachment = [UserInfoData.getClassName: model]
        let result = EventUtil.handleEvents(event: event)
        EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
    }
    @objc func showPhotos(btn: UIButton) {
        // 创建图片浏览器
        let browser = PhotoBrowser(animationType: .scaleNoHiding, delegate: self, originPageIndex: btn.tag)
        // 光点型页码指示器

        //        browser.cellPlugins = [ProgressViewPlugin(),RawImageButtonPlugin()]

        // 显示
//        VCController.push(browser, with: VCAnimationClassic.defaultAnimation())
        browser.show(from: kWindowRootVC)
    }

    @objc func praised(sender: UIButton) {
        //发送请求记录按钮状态
        let id = cellModel?.id ?? 0
        let pid = cellModel?.group_pid ?? 0
        NetworkUtil.request(target: .praiseInvitation(praise: !sender.isSelected, group_invitation_id: id, group_pid: pid), success: { [weak self] _ in
            //请求成功，切换按钮状态
            DispatchQueue.main.async(execute: {
                self?.handlePraiseBtnState()
            })
        }) { error in
            dPrint(error)
        }
    }

    func handlePraiseBtnState() {
        //点击之后，选中状态置反
        let isSelected = !self.praiseBtn.isSelected
        if isSelected {
            praiseNum += 1
            self.praiseBtn.setYJText(prefixText: "", icon: .praised, postfixText: " \(praiseNum)", size: 14, forState: .selected)
        } else {
            praiseNum -= 1
            let unPraisedTip = praiseNum == 0 ? " 点赞" : " \(praiseNum)"
            self.praiseBtn.setYJText(prefixText: "", icon: .praise, postfixText: unPraisedTip, size: 14, forState: .normal)
        }
        self.praiseBtn.isSelected = isSelected
    }

    @objc func comment() {
        if let safeDelegate = delegate {
            safeDelegate.comment(topicData: cellModel ?? TopicData())
        }
    }

    @objc func report() {
        let id = self.cellModel?.id ?? 0
        let pid = self.cellModel?.group_pid ?? 0
        var reason = ""
        let alertVC = UIAlertController(title: "举报", message: "请选择举报的类型", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "侵权举报", style: .destructive, handler: { _ in
            reason = "侵权举报"
            NetworkUtil.request(target: .tipOffReply(reason: reason, group_reply_id: id, group_pid: pid), success: { _ in
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
}

extension PostListCell: PhotoBrowserDelegate {
    /// 图片总数量
    func numberOfPhotos(in photoBrowser: PhotoBrowser) -> Int {
        return photoModels?.count ?? 0
    }

    /// 缩略图所在 view
    func photoBrowser(_ photoBrowser: PhotoBrowser, thumbnailViewForIndex index: Int) -> UIView? {
        return (self.imageContainer.subviews[index] as? UIButton)
    }

    /// 缩略图图片，在加载完成之前用作 placeholder 显示
    func photoBrowser(_ photoBrowser: PhotoBrowser, thumbnailImageForIndex index: Int) -> UIImage? {
        return (self.imageContainer.subviews[index] as? UIButton)?.backgroundImage(for: .normal)
    }

    /// 高清图
    func photoBrowser(_ photoBrowser: PhotoBrowser, highQualityUrlForIndex index: Int) -> URL? {
        return photoModels?[index].highQualityUrl.flatMap {
            URL(string: $0)
        }
    }
    /// 原图
    func photoBrowser(_ photoBrowser: PhotoBrowser, rawUrlForIndex index: Int) -> URL? {
        return photoModels?[index].rawUrl.flatMap {
            URL(string: $0)
        }
    }
    func photoBrowser(_ photoBrowser: PhotoBrowser, didLongPressForIndex index: Int, image: UIImage) {
        let actionSheet = UIAlertController()
        actionSheet.addAction(title: "保存到手机") {[weak self] _ in
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self?.image(image:didFinishSavingWithError:contextInfo:)), nil)
        }
        actionSheet.addAction(title: "取消", style: .cancel, handler: nil)
        photoBrowser.present(actionSheet, animated: true, completion: nil)
//        kWindowRootVC?.present(actionSheet, animated: true, completion: nil)
    }
//    /// 长按图片。你可以在此处得到当前图片，并可以做弹窗，保存图片等操作
//    func photoBrowser(_ photoBrowser: PhotoBrowser, didLongPressForIndex index: Int, image: UIImage, gesture: UILongPressGestureRecognizer) {
//        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        let saveImageAction = UIAlertAction(title: "图片信息", style: .default) { (_) in
//            // 图片信息
//            dPrint("图片：\(image)\n长按手势：\(gesture)")
//        }
//        actionSheet.addAction(saveImageAction)
//        let loadRawAction = UIAlertAction(title: "查看原图", style: .default) { (_) in
//            // 加载长按的原图
//            photoBrowser.loadRawImage(at: index)
//        }
//        actionSheet.addAction(loadRawAction)
//        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
//        actionSheet.addAction(cancelAction)
//        photoBrowser.present(actionSheet, animated: true, completion: nil)
//    }
//    func longTap(tableviewCell cell: JCMessageImageCollectionViewCell) {
//        selectImage = cell.messageImage.image
//        let actionSheet = UIAlertController.init()
//        actionSheet.addAction(title: "保存到手机") {[weak self] (action) in
//            self?.view.becomeFirstResponder()
//            if let image = self?.selectImage {
//                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self?.image(image:didFinishSavingWithError:contextInfo:)), nil)
//            }
//        }
//        actionSheet.addAction(title: "取消",style:.cancel, handler: nil)
//        kWindowRootVC?.present(actionSheet, animated: true, completion: nil)
//        SAIInputBarLoad()
//    }
    @objc func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            MBMasterHUD.showSuccess(title: "保存成功")
        } else {
            MBMasterHUD.showFail(title: "保存失败，请重试")
        }
    }
}
