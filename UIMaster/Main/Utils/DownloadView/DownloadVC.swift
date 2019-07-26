//
//  DownloadVC.swift
//  UIMaster
//
//  Created by hobson on 2018/10/29.
//  Copyright © 2018 one2much. All rights reserved.
//

import QuickLook
import Tiercel
import UIKit

struct DownloadConfig {
    var fileName: String
    var urlStr: String
    var sessionID: Int64
    var messageID: Int64
    var chatType: Int
    var cell: ChatFileCell
}

class DownloadVC: NaviBarVC {
    @IBOutlet weak var downloadProgress: UIProgressView!
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var fileIcon: UIImageView!

    var config: DownloadConfig?
    var downloadManager: TRManager?
    var webView = UIWebView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fileName.text = config?.fileName ?? ""
        self.naviBar?.setTitle(title: config?.fileName ?? "")
        self.naviBar?.backgroundColor = UIColor(hexString: "#222222")
        self.naviBar?.setTitleColor(color: .white)
        self.setDefaultBackButton()
        self.view.addSubview(webView)
        self.webView.isHidden = true
        self.webView.snp.makeConstraints { [weak self] make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self?.naviBar?.bottom ?? 0)
        }

        if self.config?.cell.model?.localStoreName == nil || self.config?.cell.model?.localStoreName == "" {
            downloadManager = TRManager()
            _ = downloadManager?.download(config?.urlStr ?? "", fileName: config?.fileName ?? "", progressHandler: { [weak self] task in
                let progress = task.progress.fractionCompleted
                DispatchQueue.main.async {
                    self?.downloadProgress.progress = Float(progress)
                }
                }, successHandler: { [weak self] _ in
                    // 获取本地路径
                    let path = (self?.downloadManager?.cache.downloadFilePath ?? "") + "/" + (self?.config?.fileName ?? "")
                    // 保存到cell的model中
                    self?.config?.cell.model?.localStoreName = path
                    // 添加到数据库
                    DatabaseTool.shared.modifyFileMessage(with: self?.config?.messageID ?? 0, sessionID: self?.config?.sessionID ?? 0, chatType: self?.config?.chatType ?? 0, filePath: path)
                    // 调出webView显示内容
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self?.showFileContnet()
                    })
            }) { _ in
                HUDUtil.msg(msg: "下载失败，请重试。", type: .error)
            }
        } else {
            showFileContnet()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    /// 展示文件内容
    func showFileContnet() {
        self.webView.isHidden = false
        self.webView.loadRequest(URLRequest(url: URL(fileURLWithPath: self.config?.cell.model?.localStoreName.removingPercentEncoding ?? "")))
//        self.webView.loadLocal(localUrlStr: self.config?.cell.model?.localStoreName.removingPercentEncoding)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, config: DownloadConfig) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.config = config
    }

    deinit {
        downloadManager?.invalidate()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func closeVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
