//
//  Contact.swift
//  UIMaster
//
//  Created by package on 2018/8/24.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

class ContactModel: BaseData {
    var events: [String: EventsData]?
    var status: Int?
    var styles: ContactStyles?
}
class ContactStyles: BaseStyleModel {
}
class ContactDataModel: BaseModel {
    var data: [ContactApartmentData]?
}
// swiftlint:disable identifier_name
class ContactApartmentData: BaseData {
    var id: Int?
    var pid: Int?
    var name: String?
    var parent_id: Int?
    var phone: String?
    var address: String?
    var position_x: Int?
    var position_y: Int?
    var zip_code: Int?
    var add_time: String?
    var update_time: String?
    var child_num: Int?
    var url: String?
}
// swiftlint:enable identifier_name

class ContactList: BaseTableView, PageModuleAble {
    var events: [String: EventsData]?
    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let model = ContactModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.events = model.events
                //渲染UI
                renderUI()
                //获取数据
                reloadViewData()
            }
        }
    }
    weak var moduleDelegate: ModuleRefreshDelegate?
    var moduleParams: [String: Any]? {
        didSet {
            self.parentData = moduleParams?[ContactApartmentData.getClassName] as? ContactApartmentData
        }
    }

    // MARK: - 模块特有属性
    private var itemList: [ContactApartmentData]?//保存M2请求回来的数据
    //    private var pageNum: Int = 1//如果涉及到数据分页，需要此变量
    var parentData: ContactApartmentData?
    var heightDic: [Int: CGFloat]?
    var spacing: CGFloat = 10
    // MARK: init方法
    init(frame: CGRect) {
        super.init(frame: frame, style: .plain)
        self.delegate = self
        self.dataSource = self
        self.tableFooterView = UIView()
        self.register(UINib(nibName: "ContactsCell", bundle: nil), forCellReuseIdentifier: "contactCell")
        self.register(UINib(nibName: "ContactsNoInfoCell", bundle: nil), forCellReuseIdentifier: "contactsNoInfoCell")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 网络请求
extension ContactList {
    //页面刷新时会调用该方法
    func reloadViewData() {
        //        //加载更多时，分页数加1，不需要分页可以去掉下面这行
        //        self.pageNum = isLoadMore ? self.pageNum + 1 : 1
        //请求M2数据信息
        self.requestDepartmentList()
    }
    //获取部门
    func requestDepartmentList() {
        NetworkUtil.request(
            target: .getDepartment(dept_id: parentData?.id ?? 0),
            success: { [weak self] json in
                self?.mj_header.endRefreshing()
                //如果数据需要分页，使用下面的代码
                let tmpList = ContactDataModel.deserialize(from: json)?.data
                guard let safeTmpList = tmpList else {
                    return
                }
                self?.itemList = safeTmpList
                //tableView需要刷新数据
                self?.reloadData()
            }
        ) { error in
            HUDUtil.msg(msg: "获取列表失败", type: .error)
            dPrint(error)
        }
    }
}
// MARK: - UI&事件处理
extension ContactList {
    //渲染UI
    private func renderUI() {
        //        self.config()
        self.configRefresh()
        self.tableFooterView = UIView()
        self.separatorStyle = .none
        self.backgroundColor = UIColor(hexString: "#eeeeee")
        if let footer = self.mj_footer {
            footer.isHidden = true
        }
    }
}

// MARK: - 代理方法
/**
 1.协议的采纳放到该扩展上。
 2.代理方法统一放到这里，不同的代理用//MARK: 分开
 */
extension ContactList: UITableViewDelegate & UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = itemList?.count ?? 0
        return count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let model = self.itemList?[indexPath.row] {
            if (model.child_num ?? 0) <= 0 {
                return
            }
        }
        guard let singleEvent = self.events?[kSingleEvent] else {
            return
        }
        if let safeData = self.itemList?[indexPath.row] {
            singleEvent.attachment = [ContactApartmentData.getClassName: safeData]
        }
        let result = EventUtil.handleEvents(event: singleEvent)
        EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = self.itemList?[indexPath.row]
        let trimPhone = model?.phone?.trim()
        let trimAddress = model?.address?.trim()
        if (trimPhone?.isEmpty ?? true) && (trimAddress?.isEmpty ?? true) {
            return 80 + spacing
        } else {
            return 100 + spacing
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.itemList?[indexPath.row]
        let trimPhone = model?.phone?.trim()
        let trimAddress = model?.address?.trim()
        let contactsCell: UITableViewCell?

        if (trimPhone?.isEmpty ?? true) && (trimAddress?.isEmpty ?? true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactsNoInfoCell") as? ContactsNoInfoCell
            cell?.departmentName.text = model?.name ?? "部门"
            cell?.departmentInto.text = model?.url
            cell?.spacing = spacing
            contactsCell = cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell") as? ContactsCell
            let name = model?.name ?? "部门"
            cell?.sectionNameLabel.text = name
            let phone = (trimPhone?.isEmpty ?? true) ? "暂无电话" : trimPhone
            phone == "暂无电话" ? cell?.telBtn.isHidden = true : nil
            cell?.telNumLabel.text = phone

            let address = (trimAddress?.isEmpty ?? true) ? "暂无地址" : trimAddress
            cell?.locationBtn.setTitle(address, for: .normal)
            cell?.locationBtn.contentHorizontalAlignment = .left
            cell?.locationIconBtn.isHidden = address == "暂无地址"
            cell?.mapUrl = model?.url
            cell?.sectionIcon.setTitle(name[0], for: .normal)
            cell?.spacing = spacing
            contactsCell = cell
        }
        if (model?.child_num ?? 0) <= 0 {
            contactsCell?.accessoryType = .none
        }
        contactsCell?.selectionStyle = .none
        return contactsCell ?? UITableViewCell()
        //        if indexPath.row == 0{
        //            var cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell") as? ContactsCell
        //            if cell == nil{
        //                cell = Bundle.main.loadNibNamed("headAll", owner: nil, options: nil)?[0] as? ContactsCell
        //            }
        //            return cell ?? UITableViewCell()
        //        }else if indexPath.row == 1{
        //            var cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell") as? ContactsCell
        //            if cell == nil{
        //                cell = Bundle.main.loadNibNamed("locationAll", owner: nil, options: nil)?[1] as? ContactsCell
        //            }
        //            return cell ?? UITableViewCell()
        //        }else{
        //            var cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell") as? ContactsCell
        //            if cell == nil{
        //                cell = Bundle.main.loadNibNamed("callUs", owner: nil, options: nil)?[2] as? ContactsCell
        //            }
        //            return cell ?? UITableViewCell()
        //        }
    }
}
