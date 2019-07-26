//
//  DetailWeb.swift
//  UIDS
//
//  Created by one2much on 2018/1/24.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Foundation

import WebKit

// MARK: - webView相关
extension ArticleDetails: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webView.activityView.stopAnimating()
        self.webView.evaluateJavaScript("document.body.offsetHeight;") { [weak self] result, _ in
            if let height = result as? CGFloat {
                self?.view.height = height + 20
                self?.webView.height = height + 20
                self?.moduleDelegate?.moduleLayoutDidRefresh()
            }
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let urlStr = navigationAction.request.url?.absoluteString.stringByDecodingURLFormat()
        if urlStr?.hasPrefix("http") ?? true || urlStr?.hasPrefix("https") ?? true {
            let otherweb = OtherWebVC(name: "webview")
            otherweb.urlString = urlStr
            VCController.push(otherweb, with: VCAnimationClassic.defaultAnimation())
            decisionHandler(WKNavigationActionPolicy.cancel)
        } else {
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }
    /// 加载webView内容
    ///
    /// - Parameter model: 新闻内容数据
    func loadWebViewContent(model: DetailData) {
        //标题
        let titleTag = "<div class=\"head\">\(model.title ?? "")</div>"
        //头像
        var iconTag = ""
        guard let userInfo = model.user_info else {
            return
        }
        if userInfo.admin == 0 {
            if userInfo.head_portrait == nil || userInfo.head_portrait == ""{
                iconTag = "<div class=\"admin_pic zui-col-xs-2\"><img src=\"userHeader.png\" onclick='didTapAvatar()'></div>"
            } else {
                iconTag = "<div class=\"admin_pic zui-col-xs-2\" ><img onclick='didTapAvatar()' src=\"\(userInfo.head_portrait ?? "")\"></div>"
            }
        } else {
            iconTag = "<div class=\"admin_pic zui-col-xs-2\"><img src=\"admin.png\"></div>"
        }
        //昵称
        var nickTag = ""
        if userInfo.admin == 0 {
            if userInfo.zh_name == ""{
                nickTag = "<div class=\"nick_name\">未知</div>"
            } else {
                nickTag = "<div class=\"nick_name\">\(userInfo.zh_name ?? "")</div>"
            }
        } else {
            nickTag = "<div class=\"nick_name\">管理员</div>"
        }
        //时间
        var timeTag = ""
        if model.add_time == ""{
           timeTag = "<span class=\"time\">未知时间</span>"
        } else {
            timeTag = "<span class=\"time\">\(model.add_time.getTimeTip())</span>"
        }
        //标签
        //分类
        //图片
        var imageTag = "<div class=\"photo\"><img src=\"http://p8v2k1avt.bkt.clouddn.com/Fr0Yb38ZLh5Xfy7eBXVMdEWpPWMh\"></div>"
        var index = 0
        if (self.webDetailData?.attachment_value.count ?? 0) == 0 {
            imageTag = ""
        } else {
            imageTag = "<div class=\"photo\">"
            let imgs = self.webDetailData?.attachment_value.components(separatedBy: ",") ?? []
            self.imageUrlStr = imgs
            // 拼接图片标签
            for imgUrl in imgs {
                // 图片URL
                dPrint("imgUrl = \(imgUrl)")
                // img标签"<div class=\"photo\"><img class=\"loadingImg\" data-src=\"\(model)\"></div>"
                imageTag += "<img onclick='didTappedImage(\(index), \"\(imgUrl)\");'  src='\(imgUrl)' class='loadingImg'/>"
                index += 1
            }
            imageTag += "</div>"
        }
        //内容
        var contentTag = "<div class=\"content\">文章内容</div>"
        if model.content == ""{
            contentTag = ""
        } else {
            contentTag = "<div class=\"content\">\(model.content ?? "")</div>"
        }

        // 从本地加载网页模板
        let templatePath = Bundle.main.path(forResource: "article.html", ofType: nil)!
        var template = (try? String(contentsOfFile: templatePath, encoding: String.Encoding.utf8))
        //替换模板内容
        template = template?.replacingOccurrences(of: "<div class=\"head\">文章标题</div>", with: titleTag)
        template = template?.replacingOccurrences(of: "<div class=\"admin_pic zui-col-xs-2\"><img src=\"\"></div>", with: iconTag)
        template = template?.replacingOccurrences(of: "<div class=\"nick_name\">用户昵称</div>", with: nickTag)
        template = template?.replacingOccurrences(of: "<span class=\"time\">15小时前</span>", with: timeTag)
        template = template?.replacingOccurrences(of: "<div class=\"content\">文章内容</div>", with: contentTag)
        template = template?.replacingOccurrences(of: "<div class=\"photo\"><img src=\"\"></div>", with: imageTag)
        //加载模板
        let baseURL = URL(fileURLWithPath: templatePath)
        webView.loadHTMLString(template ?? "", baseURL: baseURL)
    }
}
