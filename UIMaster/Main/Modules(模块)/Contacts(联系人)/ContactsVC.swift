//
//  ContactsVC.swift
//  UIMaster
//
//  Created by hobson on 2018/10/8.
//  Copyright © 2018 one2much. All rights reserved.
//

import SwiftyJSON
import UIKit

class ContactsVC: BaseNameVC, PageModuleAble {
    // MARK: 模块相关的配置属性
    private var controlNumberInfinite = 1//限制条数 是否
    private var more = 0//更多 是否
    private var bgImgModeTitle = 0//标题栏背景 平铺
    private var borderShow = 1//边框是否显示
    private var fontSizeName: CGFloat = 9//群名称 大小
    private var fontSizeTitleMore: CGFloat = 9//标题栏更多文字 大小
    private var marginBottom = 0//下边距
    private var textAlignName = 0//群名称 位置
    private var bgImgTitle = ""//标题栏背景 图片
    private var borderColor = "224,255,35,1"//边框 颜色
    private var colorTime = "16,213,60,1"//时间 颜色
    private var heightTitle: CGFloat = 37//标题栏高度
    private var radius = 0//圆角
    private var textAlignTime = 1//时间 位置
    private var textAlignTitle = 0//标题栏文字 位置
    private var bgColorTitle = "202,203,206,1"//标题栏背景颜色
    private var colorAbstract = "42,42,42,1"//群简介 颜色
    private var heightList: CGFloat = 60//列表行高
    private var splitterColorTitle = "232,232,232,1"//标题栏分割线颜色
    private var textAlignAbstract = 0//群简介 位置
    private var barsNumber = 7//展示条数
    private var colorTitle = "10,22,156,1"//标题栏文字 颜色
    private var colorTitleMore = "44,187,60,1"//标题栏更多文字 颜色
    private var fontSizeTitle: CGFloat = 14//标题栏文字大小
    private var showShape = 2//群头像形状 1方2圆
    private var bgImgModeList = 0//列表背景 平铺
    private var borderWidth = 0//边框粗细
    private var marginLeft = 1//左边距
    private var marginRight = 1//右边距
    private var splitterShowList = 1//分割线是否显示
    private var splitterWidthList: CGFloat = 4//分割线宽度
    private var bgImgList = ""//列表背景图片
    private var fontSizeTime: CGFloat = 17//时间 大小
    private var marginTop = 1//上边距
    private var splitterColorList = "21,160,27,1"//分割线颜色
    private var splitterWidthTitle: CGFloat = 0//标题栏分割线宽度
    private var fontSizeAbstract: CGFloat = 14//群简介 大小
    private var cornerRadius: CGFloat = 0
    //    private var height = 230//高度
    private var splitterShowTitle = 1//标题栏分割线是否显示
    private var textAlignTitleMore = 1//标题栏更多文字 位置
    private var bgColorList = "252,33,179,1"//列表背景 颜色
    private var colorName = "23,235,234,1"//群名称颜色
    private var events: [String: EventsData]?

    weak var moduleDelegate: ModuleRefreshDelegate?
    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let addressBookModel = AddressBookModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.controlNumberInfinite = addressBookModel.fields?.controlNumberInfinite ?? self.controlNumberInfinite
                self.more = addressBookModel.fields?.more ?? self.more
                self.cornerRadius = addressBookModel.styles?.radius ?? self.cornerRadius
                self.bgImgModeTitle = addressBookModel.styles?.bgImgModeTitle ?? self.bgImgModeTitle
                self.fontSizeName = addressBookModel.styles?.fontSizeName ?? self.fontSizeName
                self.fontSizeTitleMore = addressBookModel.styles?.fontSizeTitleMore ?? self.fontSizeTitleMore
                self.textAlignName = addressBookModel.styles?.textAlignName ?? self.textAlignName
                self.bgImgTitle = addressBookModel.styles?.bgImgTitle ?? self.bgImgTitle
                self.borderColor = addressBookModel.styles?.borderColor ?? self.borderColor
                self.colorTime = addressBookModel.styles?.colorTime ?? self.colorTime
                self.heightTitle = addressBookModel.styles?.heightTitle ?? self.heightTitle
                ////                self.textAlignTime = addressBookModel.styles?.textAlignTime ?? self.textAlignTime
                //                self.textAlignTitle = addressBookModel.styles?.textAlignTitle ?? self.textAlignTitle
                self.bgColorTitle = addressBookModel.styles?.bgColorTitle ?? self.bgColorTitle
                self.colorAbstract = addressBookModel.styles?.colorAbstract ?? self.colorAbstract
                self.heightList = addressBookModel.styles?.heightList ?? self.heightList
                self.splitterColorTitle = addressBookModel.styles?.splitterColorTitle ?? self.splitterColorTitle
                self.textAlignAbstract = addressBookModel.styles?.textAlignAbstract ?? self.textAlignAbstract
                self.barsNumber = addressBookModel.styles?.barsNumber ?? self.barsNumber
                self.colorTitle = addressBookModel.styles?.colorTitle ?? self.colorTitle
                self.colorTitleMore = addressBookModel.styles?.colorTitleMore ?? self.colorTitleMore
                self.fontSizeTitle = addressBookModel.styles?.fontSizeTitle ?? self.fontSizeTitle
                self.showShape = addressBookModel.styles?.showShape ?? self.showShape
                //                self.splitterTypeList = addressBookModel.styles?.splitterTypeList ?? self.splitterTypeList
                self.bgImgModeList = addressBookModel.styles?.bgImgModeList ?? self.bgImgModeList
                self.splitterShowList = addressBookModel.styles?.splitterShowList ?? self.splitterShowList
                self.splitterWidthList = addressBookModel.styles?.splitterWidthList ?? self.splitterWidthList
                self.bgImgList = addressBookModel.styles?.bgImgList ?? self.bgImgList
                self.fontSizeTime = addressBookModel.styles?.fontSizeTime ?? self.fontSizeTime
                self.splitterColorList = addressBookModel.styles?.splitterColorList ?? self.splitterColorList
                //                self.splitterTypeTitle = addressBookModel.styles?.splitterTypeTitle ?? self.splitterTypeTitle
                self.splitterWidthTitle = addressBookModel.styles?.splitterWidthTitle ?? self.splitterWidthTitle
                self.fontSizeAbstract = addressBookModel.styles?.fontSizeAbstract ?? self.fontSizeAbstract
                self.splitterShowTitle = addressBookModel.styles?.splitterShowTitle ?? self.splitterShowTitle
                //                self.textAlignTitleMore = addressBookModel.styles?.textAlignTitleMore ?? self.textAlignTitleMore
                self.bgColorList = addressBookModel.styles?.bgColorList ?? self.bgColorList
                self.colorName = addressBookModel.styles?.colorName ?? self.colorName
                self.events = addressBookModel.events
                self.moduleDelegate?.setfullPageTableModule(table: listTableView)
            }
        }
    }

    lazy var listTableView: BaseTableView! = {
        let table = BaseTableView(frame: self.view.bounds, style: .plain)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.configRefresh()
        table.parentVC = self
        table.mj_footer.isHidden = true
        self.view.addSubview(table)
        table.snp.makeConstraints({ make in
            make.top.left.right.bottom.equalToSuperview()
        })
        return table
    }()

    lazy var footerView: UIView! = { [weak self] in
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self?.view.width ?? kScreenW, height: 80))
        view.addSubview(totalNumberLabel)
        view.addSubview(localNumberLabel)
        view.addSubview(addressBookNumberLabel)
        totalNumberLabel.snp.makeConstraints({ make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(18)
        })
        localNumberLabel.snp.makeConstraints({ make in
            make.top.equalTo(totalNumberLabel.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(18)
        })
        addressBookNumberLabel.snp.makeConstraints({ make in
            make.top.equalTo(localNumberLabel.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(18)
        })
        return view
    }()

    var totalNumberLabel: UILabel! = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(hexString: "#666666")
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    var localNumberLabel: UILabel! = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(hexString: "#666666")
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    var addressBookNumberLabel: UILabel! = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(hexString: "#666666")
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    var footerLineHeightConstraint: NSLayoutConstraint! {
        didSet { footerLineHeightConstraint.constant = 0.5 }
    }
    fileprivate var sortedkeys = [String]()  //UITableView 右侧索引栏的 value
    fileprivate var itemList: [ContactPersonData]?
    fileprivate var itemDic: [String: [ContactPersonData]]?
    lazy var badgeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.backgroundColor = .red
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.listTableView.register(ContactFriendCell.getNib(), forCellReuseIdentifier: ContactFriendCell.getIdentifier)
        self.listTableView.estimatedRowHeight = 54
        self.listTableView.sectionIndexColor = UIColor.darkGray
        self.listTableView.tableFooterView = self.footerView
        self.intigrateContactList()
        self.listTableView.reloadData()
        NotificationCenter.default.rx.notification(Notification.Name(kPersonalInfoChangeNotification)).takeUntil(self.rx.deallocated).subscribe(onNext: {
            [weak self] _ in
            self?.requestContacts()
        }).disposed(by: rx.disposeBag)
        //获取授权
        PPAddressBookHandle.shared.requestAuthorizationWithSuccessClosure {}
        self.moduleDelegate?.assemble(with: self)
        getCacheJson(key: ContactsVC.getClassName) { [weak self] json in
            let modelArr = ContactPersonModel.deserialize(from: json)?.data
            self?.itemList = modelArr
            self?.intigrateContactList()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.reloadViewData()
        }
    }

    deinit {
        dPrint("deinit")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard UserUtil.isValid() else { return }
        renderBadge()
    }

    func intigrateContactList() {
        // 清空之前的记录
        self.sortedkeys = []
        self.itemDic = [:]

        //创建群聊和公众帐号的数据
        let topArray = [ ContactPersonData(), ContactPersonData()]
        //添加 key
        self.sortedkeys.append("")
        self.itemDic = ["": topArray]

        //解析联系人数据
        let total = itemList?.count ?? 0
        var phone = 0
        self.totalNumberLabel.text = "共\(total)位联系人"
        for item in itemList ?? [] {
            if item.user_id == 0 || item.user_id == nil {
                phone += 1
            }
        }
        self.localNumberLabel.text = "含本地联系人\(total - phone)位"
        self.addressBookNumberLabel.text = "手机联系人\(phone)位"

        var contactDic = Dictionary<String, Array<ContactPersonData>>()
        for model in (self.itemList ?? []) {
            guard let name = model.full_name else { return }
            var firstLetter = getFirstLetterFromString(aString: name)
            firstLetter = firstLetter.isSpecialCharactor() ? "#" : firstLetter
            if contactDic[firstLetter] != nil {
                contactDic[firstLetter]?.append(model)
            } else {
                var tempArray = Array<ContactPersonData>()
                tempArray.append(model)
                contactDic[firstLetter] = tempArray
            }
        }
        let sortedKeys = Array(contactDic.keys).sorted(by: <)
        self.sortedkeys.append(contentsOf: sortedKeys)
        for (key, value) in contactDic {
            self.itemDic![key] = value
        }

        self.listTableView.reloadData()
    }

    func getFirstLetterFromString(aString: String) -> (String) {
        if aString == "" { return "#" }
        // 注意,这里一定要转换成可变字符串
        let mutableString = NSMutableString(string: aString)
        // 将中文转换成带声调的拼音
        CFStringTransform(mutableString as CFMutableString, nil, kCFStringTransformToLatin, false)
        // 去掉声调(用此方法大大提高遍历的速度)
        let pinyinString = mutableString.folding(options: String.CompareOptions.diacriticInsensitive, locale: NSLocale.current)
        // 将拼音首字母装换成大写
        let strPinYin = polyphoneStringHandle(nameString: aString, pinyinString: pinyinString).uppercased()
        // 截取大写首字母
        let firstString = strPinYin.subStr(from: 0, length: 1)
        // 判断姓名首位是否为大写字母
        let regexA = "^[A-Z]$"
        let predA = NSPredicate(format: "SELF MATCHES %@", regexA)
        return predA.evaluate(with: firstString) ? firstString : "#"
    }

    func polyphoneStringHandle(nameString: String, pinyinString: String) -> String {
        if nameString.hasPrefix("长") { return "chang" }
        if nameString.hasPrefix("沈") { return "shen" }
        if nameString.hasPrefix("厦") { return "xia" }
        if nameString.hasPrefix("地") { return "di" }
        if nameString.hasPrefix("重") { return "chong" }

        return pinyinString
    }
}
// MARK: - 发送请求
extension ContactsVC {
    func reloadViewData() {
        requestContacts()
    }

    func requestContacts() {
        NetworkUtil.request(target: NetworkService.selectContact, success: {[weak self] json in
            self?.cacheJson(key: ContactsVC.getClassName, json: json)
            self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
            let modelArr = ContactPersonModel.deserialize(from: json)?.data
            self?.itemList = modelArr
            self?.intigrateContactList()
        }) { [weak self] error in
            self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
            dPrint(error)
        }
    }

    func addContacts() {
        HUDUtil.loadingHUD(title: "同步中...")
        PPGetAddressBook.getOriginalAddressBook(addressBookArray: { modelArr in
            var jsonStr = "["
            for personInfo in modelArr {
                //拼接姓名
                jsonStr += "{\"full_name\":\"\(personInfo.name)\","
                //拼接头像
                //                personInfo.headerImag
                jsonStr += "\"head_portrait\":\"\("")\","
                //拼接电话
                jsonStr += "\"telephone\":["
                for (label, num) in personInfo.mobileDic {
                    jsonStr += "{\"telephone\":\"\(num)\","
                    jsonStr += "\"name\":\"\(label)\"},"
                }
                if jsonStr.last == "," {
                    jsonStr.removeLast()
                }
                jsonStr += "],"
                //拼接地址
                jsonStr += "\"address\":["
                for (label, address) in personInfo.addressDic {
                    jsonStr += "{\"address\":\"\(address.replacingOccurrences(of: "\n", with: "-"))\","
                    jsonStr += "\"name\":\"\(label)\"},"
                }
                if jsonStr.last == "," {
                    jsonStr.removeLast()
                }
                jsonStr += "]},"
            }
            //结束
            if jsonStr.last == "," {
                jsonStr.removeLast()
            }

            jsonStr += "]"
            NetworkUtil.request(target: NetworkService.addContact(json_string: jsonStr), success: { _ in
                HUDUtil.stopLoadingHUD(ok: true, callback: nil, hint: "同步成功")
                self.reloadViewData()
            }) { error in
                HUDUtil.stopLoadingHUD(ok: false, callback: nil, hint: "同步失败")
                dPrint(error)
            }
        }) {
            HUDUtil.stopLoadingHUD(callback: nil)
            let alertVC = UIAlertController(title: "提示", message: "请在iPhone的“设置-隐私-通讯录”选项中，允许单位APP访问您的通讯录", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "前往设置", style: .default, handler: { _ in
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            }))
            alertVC.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: nil))
            alertVC.show()
        }
    }

    func renderBadge() {
//        DatabaseTool.shared.queryNotification(action: NotificationActionType.applyForFriend) { [weak self] (notificationArr) in
//            var badgeCount = 0
//            for notification in notificationArr{
//                if notification.unread == 1{
//                    badgeCount += 1
//                }
//            }
//            self?.badgeLabel.text = "\(badgeCount)  "
//            self?.listTableView.layoutIfNeeded()
//        }
        NetworkUtil.request(target: NetworkService.getApplyFriendList(page_index: 1, page_context: 100), success: {[weak self] json in
            let count = UserListModel.deserialize(from: json)?.data?.count ?? 0
            self?.badgeLabel.isHidden = count == 0 ? true : false
            let countText = count > 99 ? "99+" :"\(count)"
            DispatchQueue.main.async {
                self?.badgeLabel.text = "\(countText)  "
                self?.listTableView.layoutIfNeeded()
            }
        }) { error in
            dPrint(error)
        }
    }
}

// MARK: - @protocol UITableViewDelegate
extension ContactsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = indexPath.section
        let row = indexPath.row

        if section == 0 {
            if row == 0 {
                let event = self.events?["apply"]
                let result = EventUtil.handleEvents(event: event)
                EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
//                let vc = FriendApplyVC.init()
//                VCController.push(vc, with: VCAnimationClassic.defaultAnimation())
            } else {
                addContacts()
            }
        } else {
            let key = self.sortedkeys[indexPath.section]
            let dataArray = self.itemDic![key]!
            let model = dataArray[indexPath.row]
            if model.user_id == 0 || model.user_id == nil {
                let event = self.events?[kContact]
                event?.attachment = [ContactPersonData.getClassName: model]
                let result = EventUtil.handleEvents(event: event)
                EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
            } else {
                let event = self.events?[kHeadEvent]
                event?.attachment = ["PCTuple": (model.user_id, model.user_pid)]
                let result = EventUtil.handleEvents(event: event)
                EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
            }
        }
    }
}

// MARK: - @protocol UITableViewDataSource
extension ContactsVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sortedkeys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key: String = self.sortedkeys[section]
        let itemArray = self.itemDic?[key] ?? []
        return itemArray.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.listTableView.estimatedRowHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.000_001
        } else {
            return 30
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell()
            if indexPath.row == 0 {
                cell.textLabel?.text = "好友申请"
                cell.addSubview(badgeLabel)
                badgeLabel.snp.makeConstraints { make in
                    make.right.equalTo(-60)
                    make.centerY.equalToSuperview()
                    make.height.equalTo(20)
                    make.width.greaterThanOrEqualTo(20)
                }
                cell.bottomLine(style: .leftGap(margin: 10), color: .lightGray)
                renderBadge()
            } else {
                cell.textLabel?.text = "同步手机联系人"
                cell.bottomLine(style: .full, color: .lightGray)
            }
            cell.accessoryType = .disclosureIndicator
            return cell
        }

        let cell: ContactFriendCell = tableView.dequeueReusableCell(withIdentifier: ContactFriendCell.getIdentifier) as? ContactFriendCell ?? ContactFriendCell()
        cell.bottomLine(style: .leftGap(margin: 0), color: .lightGray)
        //判断一下数组越界问题
        guard indexPath.section < self.sortedkeys.count else { return cell }
        let key: String = self.sortedkeys[indexPath.section]
        let dataArray = self.itemDic![key]!
        cell.setCellContnet(dataArray[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        let label = UILabel()
        label.text = "    " + self.sortedkeys[section]
        label.font = UIFont.systemFont(ofSize: 14)
        label.backgroundColor = .white
        return label
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        guard let _ = self.itemDic else {
            return []
        }
        let titles: [String] = self.sortedkeys
        return titles
    }
}
