//
//  NewsDetailVC.swift
//  UIDS
//
//  Created by one2much on 2018/1/24.
//  Copyright © 2018年 one2much. All rights reserved.
//

import dsBridge
import IQKeyboardManagerSwift
import JXPhotoBrowser
import NVActivityIndicatorView
import Photos
import RxSwift
import SwiftyJSON
import UIKit
import WebKit

class ArticleDetails: BaseNameVC, PageModuleAble {
    // MARK: - 模块相关的配置属性
    private var admin = 1//用户信息
    private var adminTime = 1//其他文字==时间
    private var back = 0//返回
    private var bgColor = "250,250,250,1"//背景 颜色
    private var bgColorOptionButton = "250,250,250,1"//可操作按钮背景 颜色
    private var bgImg = ""//背景 图片
    private var bgImgMode = 0//背景 平铺
    private var bgImgModeOptionButton = 0//可操作按钮背景 平铺
    private var bgImgOptionButton = ""//可操作按钮背景 图片
    private var borderColor = "230,230,230,1"//边框 颜色
    private var borderShow = 1//边框 是否显示
    private var borderWidth = 0//边框 宽度
    private var buttonStyle = 0//布局
    private var collection = 0//收藏
    private var column = 1//栏目
    private var comment = 1//评论
    private var commentFarm = 1//评论框
    private var commentLists = 1//评论列表
    private var contentLineHight = 1//正文行高
    private var fans = 1//粉丝
    private var forward = 1//转发
    private var head = 1//头像
    private var like = 1//点赞
    private var lineHight = 2//标题行高
    private var nickName = 1//昵称
    private var opacity = 1//背景 透明度
    private var opacityOptionButton = 1//可操作按钮背景 透明度
    private var optionsMenu = 1//可操作菜单
    private var radius: CGFloat = 0//圆角
    private var time = 1//事件
    private var title1 = 1//标题
    private var headEvent: EventsData?

    weak var moduleDelegate: ModuleRefreshDelegate?
    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let articleDetailsModel = ArticleDetailsModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.admin = articleDetailsModel.fields?.admin ?? self.admin
                self.adminTime = articleDetailsModel.fields?.adminTime ?? self.adminTime
                self.back = articleDetailsModel.fields?.back ?? self.back
                //                self.bgColor = articleDetailsModel.styles?.bgColor ?? self.bgColor
                self.bgColorOptionButton = articleDetailsModel.styles?.bgColorOptionButton ?? self.bgColorOptionButton
                //                self.bgImg = articleDetailsModel.styles?.bgImg ?? self.bgImg
                //                self.bgImgMode = articleDetailsModel.styles?.bgImgMode ?? self.bgImgMode
                self.bgImgModeOptionButton = articleDetailsModel.styles?.bgImgModeOptionButton ?? self.bgImgModeOptionButton
                self.bgImgOptionButton = articleDetailsModel.styles?.bgImgOptionButton ?? self.bgImgOptionButton
                self.borderColor = articleDetailsModel.styles?.borderColor ?? self.borderColor
                self.borderShow = articleDetailsModel.styles?.borderShow ?? self.borderShow
                self.borderWidth = articleDetailsModel.styles?.borderWidth ?? self.borderWidth
                self.buttonStyle = articleDetailsModel.styles?.buttonStyle ?? self.buttonStyle
                self.collection = articleDetailsModel.fields?.collection ?? self.collection
                self.column = articleDetailsModel.fields?.column ?? self.column
                self.comment = articleDetailsModel.fields?.comment ?? self.comment
                self.commentFarm = articleDetailsModel.fields?.commentFarm ?? self.commentFarm
                self.commentLists = articleDetailsModel.fields?.commentList ?? self.commentLists
                self.contentLineHight = articleDetailsModel.styles?.contentLineHight ?? self.contentLineHight
                self.fans = articleDetailsModel.fields?.fans ?? self.fans
                self.forward = articleDetailsModel.fields?.forward ?? self.forward
                self.head = articleDetailsModel.fields?.head ?? self.head
                self.like = articleDetailsModel.fields?.like ?? self.like
                self.lineHight = articleDetailsModel.styles?.lineHight ?? self.lineHight
                self.nickName = articleDetailsModel.fields?.nickName ?? self.nickName
                self.opacity = articleDetailsModel.styles?.opacity ?? self.opacity
                self.opacityOptionButton = articleDetailsModel.styles?.opacityOptionButton ?? self.opacityOptionButton
                self.optionsMenu = articleDetailsModel.fields?.optionsMenu ?? self.optionsMenu
                self.radius = articleDetailsModel.styles?.radius ?? self.radius
                self.time = articleDetailsModel.fields?.time ?? self.time
                self.title1 = articleDetailsModel.fields?.title ?? self.title1
                self.headEvent = articleDetailsModel.events?[kHeadEvent]
            }
        }
    }

    var moduleParams: [String: Any]? {
        didSet {
            self.topicData = self.moduleParams?[TopicData.getClassName] as? TopicData
            self.ariticleCell = self.moduleParams?[PostListCell.getClassName] as? PostListCell
            requestNewsDetailData()
        }
    }
    // MARK: - 模块特有属性
    var topicData: TopicData?
    fileprivate var ariticleCell: PostListCell?
    /// 详情页面模型
    var webDetailData: DetailData? {
        didSet {
            self.moduleDelegate?.handleNavibarItems(isHidden: false, position: .middle(title: webDetailData?.title ?? ""), params: nil)
            self.moduleDelegate?.handleNavibarItems(isHidden: webDetailData?.user_info?.uid != UserUtil.share.appUserInfo?.uid, position: .right(index: 0), params: nil)
            bottomView?.praiseButton.isSelected = webDetailData?.praised == 1
            loadWebViewContent(model: webDetailData ?? DetailData())
        }
    }
    let webView = YJWebView()
    var imageUrlStr = [String]()
    weak var bottomView: CLBottomCommentView?
    var isDeleting = false

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.frame = self.view.bounds
        renderUI()
        webView.activityView.startAnimating()
        NotificationCenter
            .default
            .rx
            .notification(Notification.Name(kDeleteArticleNotification))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                self?.deleteArticle()
            })
            .disposed(by: rx.disposeBag)
    }

    override func viewWillDisappear(_ animated: Bool) {
        if isDeleting {
            return
        }
        let cell = self.ariticleCell
        NetworkUtil.request(target: .getInvitation(group_invitation_id: self.topicData?.id ?? 0, group_pid: self.topicData?.group_pid ?? 0), success: { json in
            DispatchQueue.main.async {
                cell?.updateContent(cellModel: TopicSingleModel.deserialize(from: json)?.data)
            }
        }) { error in
            dPrint(error)
        }
        super.viewWillDisappear(animated)
    }
}
// MARK: - UI&事件处理
extension ArticleDetails {
    //渲染UI
    private func renderUI() {
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        webView.backgroundColor = self.bgColor.toColor()
        webView.scrollView.isScrollEnabled = false
        //设置web bridge
        let bridgeObj = ArticleDetailBridgeApi()
        bridgeObj.delegate = self
        webView.addJavascriptObject(bridgeObj, namespace: nil)
        webView.setDebugMode(true)
    }

    func showImage(data: [String:Int]) {
        let json = JSON(data)
        let index = json["index"].intValue
        DispatchQueue.main.async {
            let browser = PhotoBrowser(animationType: .fade, delegate: self, originPageIndex: index)
            kWindowRootVC?.present(browser, animated: true, completion: nil)
        }
    }

    func gotoPC() {
        let event = self.headEvent
        NetworkUtil.request(target: .getInfo(user_id: self.topicData?.user_info?.uid ?? 0, user_pid: self.topicData?.user_info?.pid ?? 0), success: { json in
            event?.attachment = [UserInfoData.getClassName: UserInfoModel.deserialize(from: json)?.data ?? UserInfoData()]
            let result = EventUtil.handleEvents(event: event)
            EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
        }) { error in
            dPrint(error)
        }
    }

    /**
     保存图片到相册
     */
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let _ = error {
            HUDUtil.msg(msg: "保存失败", type: .error)
        } else {
            HUDUtil.msg(msg: "保存成功", type: .successful)
        }
    }
    @objc func deleteArticle() {
        let vc = UIAlertController(title: "确定删除该帖？", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "确定", style: .destructive, handler: { [weak self] _ in
            NetworkUtil.request(
                target: .delInvitation(group_invitation_id: self?.webDetailData?.id ?? 0, group_pid: self?.webDetailData?.group_pid ?? 0),
                success: { [weak self] _ in
                    HUDUtil.msg(msg: "已删除", type: .successful)
                    let postListRefreshNotification = Notification(name: Notification.Name(rawValue: kPostListRefreshNotification), object: self?.topicData, userInfo: nil)
                    self?.isDeleting = true
                    NotificationCenter.default.post(postListRefreshNotification)
                    _ = VCController.pop(with: VCAnimationClassic.defaultAnimation())
                }
            ) { error in
                dPrint(error)
            }
        })
        let action2 = UIAlertAction(title: "点错了", style: .cancel, handler: nil)
        vc.addAction(action)
        vc.addAction(action2)
        kWindowRootVC?.present(vc, animated: true, completion: nil)
    }
}
// MARK: - 网络请求
extension ArticleDetails {
    //获取文章数据
    private func requestNewsDetailData() {
        NetworkUtil.request(target: .getInvitation(group_invitation_id: self.topicData?.id ?? 0, group_pid: self.topicData?.group_pid ?? 0), success: { [weak self] json in
            self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
            self?.webDetailData = DetailModel.deserialize(from: json)?.data
            self?.renderUI()
        }) { error in
            HUDUtil.stopLoadingHUD(ok: false, callback: nil, hint: "加载失败")
            dPrint(error)
        }
    }

    //    // 删帖
    //    @objc private func deleteNewsClick() {
    //        let vc = UIAlertController(title: "确定删除该帖？", message: nil, preferredStyle: .alert)
    //        let action = UIAlertAction.init(title: "确定", style: .destructive, handler: { [weak self] (_) in
    //            let params = NSMutableDictionary()
    //            params.setValue(self?.webDetailData?.id, forKey: "group_invitation_id")
    //            params.setValue(self?.webDetailData?.group_pid, forKey: "group_pid")
    //            ApiUtil.share.cms_DeleteNews(params: params) { (status, _, msg) in
    //                if ResponseStatus.success == status {
    //                    HUDUtil.msg(msg: "已删除", type: .successful)
    //                    //请求成功，返回并刷新
    //                    _ = VCController.pop(with: VCAnimationClassic.defaultAnimation())
    //                } else {
    //                    HUDUtil.msg(msg: msg ?? "失败", type: .error)
    //                }
    //            }
    //        })
    //        let action2 = UIAlertAction.init(title: "点错了", style: .cancel, handler: nil)
    //        vc.addAction(action)
    //        vc.addAction(action2)
    //        VCController.getTopVC()?.present(vc, animated: true, completion: nil)
    //    }
}

extension ArticleDetails: PhotoBrowserDelegate {
    /// 浏览非本地图片时必须实现本方法
    /// 实现本方法以返回图片数量
    func numberOfPhotos(in photoBrowser: PhotoBrowser) -> Int {
        return self.imageUrlStr.count
    }
    /// 实现本方法以返回高质量图片的 url。可选
    func photoBrowser(_ photoBrowser: PhotoBrowser, highQualityUrlForIndex index: Int) -> URL? {
        return URL(string: self.imageUrlStr[index])
    }

    /// 实现本方法以返回原图级质量的 url。当本代理方法有返回值时，自动显示查看原图按钮。可选
    func photoBrowser(_ photoBrowser: PhotoBrowser, rawUrlForIndex index: Int) -> URL? {
        return URL(string: self.imageUrlStr[index])
    }

    /// 实现本方法以返回本地大图。
    /// 本地图片的展示将优先于网络图片。
    /// 如果给 PhotoBrowser 设置了本地图片组 localImages，则本方法不生效。
    func photoBrowser(_ photoBrowser: PhotoBrowser, thumbnailImageForIndex index: Int) -> UIImage? {
        return nil
    }

    /// 长按时回调。可选
    func photoBrowser(_ photoBrowser: PhotoBrowser, didLongPressForIndex index: Int, image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == PHAuthorizationStatus.authorized {
                let actionSheet = UIAlertController()
                actionSheet.addAction(title: "保存到手机") {[weak self] _ in
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self?.image(image:didFinishSavingWithError:contextInfo:)), nil)
                }
                actionSheet.addAction(title: "取消", style: .cancel, handler: nil)
                photoBrowser.present(actionSheet, animated: true, completion: nil)
            }
        }
    }
    @objc func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            HUDUtil.msg(msg: "保存成功", type: .successful)
        } else {
            HUDUtil.msg(msg: "保存失败，请重试", type: .error)
        }
    }
}
