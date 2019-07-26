//
//  AppSearchNavVC.swift
//  UIDS
//
//  Created by bai on 2018/2/1.
//  Copyright © 2018年 one2much. All rights reserved.
//
import Differentiator
import EmptyDataSet_Swift
import IQKeyboardManagerSwift
import KeychainAccess
import MJRefresh
import NSObject_Rx
import RxCocoa
import RxDataSources
import RxGesture
import RxSwift
import SnapKit
import SwiftyJSON
import Then
import UIKit

// MARK: - 代理
@objc protocol AppSearchVCDelectege {
    //搜索结束
    func searchpidEnd(pidObj: Any?)
}

class AppSearchNavVC: BaseNameVC, PageModuleAble {
    var styleDic: [String: Any]?

    var moduleDelegate: ModuleRefreshDelegate?

    // MARK: - 属性
    weak var delegate: AppSearchVCDelectege?
    fileprivate var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, Project>>?
    fileprivate var viewModel: SearchResultViewModel?
    fileprivate var page: Int = 1
    fileprivate var searchKey: String = ""
    fileprivate var searchField: UITextField?
    fileprivate var tableview: UITableView?

    // MARK: - 视图生命周期
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //初始化UI
        self.genderUI()
        //绑定数据
        self.bindUI()
        //初始化刷新
        self.refreshUI()
        //展示历史
        self.showHistoy()
        //隐藏悬浮按钮
        SuspensionUtil.shared.showSuspensionButton(show: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func gotoBack() {
        VCController.pop(with: VCAnimationBottom.defaultAnimation())
    }
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
// MARK: - gender UI
extension AppSearchNavVC {
    fileprivate func genderUI() {
        //搜索容器View
        let searchView = UIView(frame: CGRect(x: 0, y: 1, width: kScreenW, height: 60))
        searchView.backgroundColor = GlobalConfigTool.shared.globalData?.naviBar?.styles?.bgColor?.toColor()
        //顶部线
        let lineView = UIView()
        lineView.backgroundColor = UIColor(hexString: "ffffff")
        searchView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.top.equalTo(searchView.snp.top).offset(-1)
            make.width.equalTo(searchView.snp.width)
            make.height.equalTo(1)
        }
        //        //扫码按钮
        //        let scanButton = UIButton()
        //        scanButton.setImage(UIImage.init(named: "扫一扫"), for: .normal)
        //        scanButton.addTarget(self, action: #selector(gotoSyS), for: .touchUpInside)
        //        searchView.addSubview(scanButton)
        //        scanButton.snp.makeConstraints { (make) in
        //            make.centerY.equalTo(searchView.snp.centerY)
        //            make.height.equalTo(30)
        //            make.width.equalTo(25)
        //            make.left.equalTo(14)
        //        }
        //输入框
        let searchField = SearchBarFiled()
        searchField.backgroundColor = UIColor(white: 1, alpha: 0.3)
        searchField.layer.cornerRadius = 5
        searchField.tintColor = .white
        searchField.textColor = .white
        searchField.placeholderTextColor = UIColor.white
        searchField.layer.masksToBounds = true
        searchField.setClearButtonImage()
        searchView.addSubview(searchField)
        searchField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(-15)
            make.height.equalTo(29)
            make.centerY.equalTo(searchView.snp.centerY)
        }
        self.searchField = searchField
        //tableView
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.register(SearchVCell.self, forCellReuseIdentifier: SearchVCell.getIdentifier)
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        self.tableview = tableView

        self.view.addSubview(searchView)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(searchView.snp.bottom)
        }
    }
    //扫码
    @objc func gotoSyS() {
        self.searchField?.endEditing(true)
        Permissions.authorizeCameraWith { granted in
            if granted {
                //设置扫码区域参数
                var style = ScanViewStyle()
                style.centerUpOffset = 60
                style.xScanRetangleOffset = 30

                if UIScreen.main.bounds.size.height <= 480 {
                    //3.5inch 显示的扫码缩小
                    style.centerUpOffset = 40
                    style.xScanRetangleOffset = 20
                }

                style.colorNotRecoginitonArea = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.4)

                style.photoframeAngleStyle = ScanViewPhotoframeAngleStyle.inner
                style.photoframeLineW = 2.0
                style.photoframeAngleW = 16
                style.photoframeAngleH = 16

                style.isNeedShowRetangle = false

                style.anmiationStyle = ScanViewAnimationStyle.netGrid
                style.animationImage = UIImage(named: "qrcode_scan_full_net.png")

                let scan = ScanViewController(name: "ScanViewController")
                scan.naviBar?.setTitle(title: "扫一扫")
                scan.scanStyle = style
                VCController.push(scan, with: VCAnimationBottom.defaultAnimation())
            } else {
                let alertVC = UIAlertController(title: "前往设置中心？", message: "允许使用照相机才能扫码哦", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "同意前往", style: .default, handler: { _ in
                    Permissions.jumpToSystemPrivacySetting()
                }))
                alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                kWindowRootVC?.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    // 绑定数据
    func bindUI() {
        //绑定搜索历史
        if let safeSearchField = self.searchField {
            viewModel = SearchResultViewModel(searchBar: safeSearchField)
            viewModel?.searchUseable
                .do(
                    onNext: { [weak self] key in
                        if key.isEmpty {
                            self?.showHistoy()
                            return
                        }

                        if self?.searchKey == key {
                            return
                        }
                        self?.searchKey = key
                        self?.getData(loadMode: false)
                    })
                .drive(safeSearchField.rx.value)
                .disposed(by: rx.disposeBag)
        }

        //绑定tableView数据源
        self.dataSource = RxTableViewSectionedReloadDataSource(configureCell: { _, tv, _, item -> UITableViewCell in
            let cell = tv.dequeueReusableCell(withIdentifier: SearchVCell.getIdentifier) as? SearchVCell ?? SearchVCell()
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.width = (cell.superview?.width ?? kScreenW) - 20
            cell.layer.cornerRadius = 5
            cell.layer.masksToBounds = true
            cell.searchKey = self.searchKey
            cell.objData = item
            return cell
        })
        //搜索结果 绑定到 tableView数据源
        viewModel?.searchList.asObservable().bind(to: (self.tableview?.rx.items(dataSource: (self.dataSource)!))!).disposed(by: rx.disposeBag)
    }
}
// MARK: - 刷新植入
extension AppSearchNavVC {
    func refreshUI() {
        // 顶部刷新
        let header = MJRefreshNormalHeader { [weak self] in
            self?.refreshEvent()
        }
        header?.setTitle("下拉刷新", for: .idle)
        header?.setTitle("松开刷新", for: .pulling)
        header?.setTitle("正在刷新", for: .refreshing)
        header?.lastUpdatedTimeLabel.isHidden = true
        // 底部刷新
        let footer = MJRefreshAutoNormalFooter { [weak self] in
            self?.loadMore()
        }

        self.tableview?.mj_header = header
        self.tableview?.mj_footer = footer
        self.tableview?.mj_footer.isHidden = true
    }

    func getData(loadMode: Bool) {
        if loadMode {
            self.page += 1
        } else {
            self.page = 1
        }

        viewModel?.getSearchEnd(loadMode: loadMode, pIndex: self.page, pNum: 20, key: self.searchKey, callback: { [weak self]  noMove in
            self?.tableview?.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            self?.tableview?.mj_header.endRefreshing()
            if noMove {
                self?.tableview?.mj_footer.endRefreshingWithNoMoreData()
            } else {
                if  self?.viewModel?.searchList.value[0].items.count < 5 {
                    self?.tableview?.mj_footer.isHidden = true
                } else {
                    self?.tableview?.mj_footer.isHidden = false
                    self?.tableview?.mj_footer.endRefreshing()
                }
            }
        })
    }

    func refreshEvent() {
        if self.searchKey.count == 0 {
            self.tableview?.mj_header.endRefreshing()
            return
        }

        self.page = 1
        self.getData(loadMode: false)
    }
    private func loadMore() {
        if self.searchKey.count == 0 {
            self.tableview?.mj_footer.endRefreshing()
            self.tableview?.mj_footer.endRefreshingWithNoMoreData()
            return
        }

        self.page = 1
        self.getData(loadMode: true)
    }
}

// MARK: - UITableViewDelegate
extension AppSearchNavVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 133
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.view.endEditing(true)
        //取出数据
        let itemData = viewModel?.searchList.value[indexPath.section].items[indexPath.row]
        if let data = itemData {
            // 判断是不是当前App
            if data.app_id == GlobalConfigTool.shared.appId {
                let alertVC = UIAlertController(title: "提示", message: "您已在此App中，无需切换", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                alertVC.show()
                return
            }
            // 判断是不是已经登录了
            if UserUtil.isValid() {
                let alertVC = UIAlertController(title: "退出登录？", message: "切换项目将退出当前账号，确认退出？", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                alertVC.addAction(UIAlertAction(title: "确认", style: .default, handler: {[weak self] _ in
                    self?.signout(finish: { finish in
                        if finish {
                            self?.saveItem(parj: data)
                            let reloadDataVC = RefreshDataVC()
                            reloadDataVC.pObj = itemData
                            VCController.push(reloadDataVC, with: VCAnimationClassic.defaultAnimation())
                        }
                    })
                }))
                alertVC.show()
            } else {
                self.saveItem(parj: data)
                let reloadDataVC = RefreshDataVC()
                reloadDataVC.pObj = itemData
                VCController.push(reloadDataVC, with: VCAnimationClassic.defaultAnimation())
            }
        }
    }
    /// 退出
    func signout(finish:@escaping ((_ success: Bool) -> Void)) {
        if UserUtil.isValid() {
            // 退出登录
            let keychain = Keychain(service: "com.one2much.uuid")
            let uuid = keychain["deviceuuid"] ?? ""
            NetworkUtil.request(target: .setUserOffline(device_id: uuid), success: { _ in
                NetworkUtil.request(target: .userLogout, success: { _ in
                    //不是刷新本单位App 不需要移除用户数据
                    UserUtil.share.removerUser()
                    //移除前一个App的用户信息
                    let appID = getUserDefaults(key: kCurrentAPPID) as? Int
                    removeUserDefaults(key: kAuthorization + "\(appID ?? 0)")
                    finish(true)
                }) { error in
                    finish(false)
                    HUDUtil.msg(msg: "退出账号失败请重试", type: .error)
                    dPrint(error)
                }
            }) { error in
                finish(false)
                HUDUtil.msg(msg: "退出账号失败请重试", type: .error)
                dPrint(error)
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

// MARK: - 空数据展示
extension AppSearchNavVC: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        var text = (YJType.quto.text ?? "？") + "暂未找到您的单位APP，请联系您单位的网管"

        if self.searchKey.count == 0 {
            text = "搜索一个公司试一下"
        }

        let font = UIFont(name: "iconfont", size: 15)
        let textColor = UIColor(hex: 0x606262, alpha: 1)

        let attributes = NSMutableDictionary()
        attributes.setObject(textColor, forKey: NSAttributedStringKey.foregroundColor as NSCopying)
        attributes.setObject(font ?? UIFont.systemFont(ofSize: 15), forKey: NSAttributedStringKey.font as NSCopying)
        let str = NSMutableAttributedString(string: text, attributes: attributes as? [NSAttributedStringKey: Any])
        if !(self.searchKey.count == 0) {
            attributes.setObject(UIColor(hexString: "#3AACF0"), forKey: NSAttributedStringKey.foregroundColor as NSCopying)
            str.setAttributes((attributes as? [NSAttributedStringKey: Any]), range: NSRange(location: 0, length: 1))
        }

        return str
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let text = ""

        let textColor = UIColor.black
        let attributes = NSMutableDictionary()
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraph.alignment = NSTextAlignment.center
        paragraph.lineSpacing = 2.0

        attributes.setObject(textColor, forKey: NSAttributedStringKey.foregroundColor as NSCopying)
        attributes.setObject(paragraph, forKey: NSAttributedStringKey.paragraphStyle as NSCopying)

        return NSMutableAttributedString(string: text, attributes: attributes as? [NSAttributedStringKey: Any])
    }

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        return UIColor.clear
    }

    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        return nil
    }

    func spaceHeight(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return 0
    }

    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool {
        return true
    }

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return false
    }
}
// MARK: - 历史数据  读存
extension AppSearchNavVC {
    func saveItem(parj: Project) {
        DiskCacheHelper.getObj(HistoryKey.HistoryKeyPhone) {[weak self] obj in
            if obj != nil {
                let tmpobj: String = obj as? String ?? ""
                var getObj = ProjectList.deserialize(from: tmpobj) ?? ProjectList(data: [Project]())
                for model in getObj.data {
                    if model.app_id == parj.app_id && model.pid == parj.pid {
                        return
                    }
                }
                getObj.data.append(parj)
                DiskCacheHelper.saveObj(HistoryKey.HistoryKeyPhone, value: getObj.toJSONString())
            } else {
                var getObj = ProjectList(data: [Project]())
                if getObj.data.count == 0 {
                    getObj.data.append(parj)
                    let section = [SectionModel(model: "", items: getObj.data!)]
                    self?.viewModel?.searchList.value = section
                    DiskCacheHelper.saveObj(HistoryKey.HistoryKeyPhone, value: getObj.toJSONString())
                }
            }
        }
    }
    func showHistoy() {
        DiskCacheHelper.getObj(HistoryKey.HistoryKeyPhone) { [weak self] obj in
            if obj != nil {
                let tmpobj = obj as? String ?? ""

                let getObj = ProjectList.deserialize(from: tmpobj) ?? ProjectList(data: [Project]())

                let section = [SectionModel(model: "", items: getObj.data!)]

                self?.viewModel?.searchList.value = section
            }
        }
    }
}
