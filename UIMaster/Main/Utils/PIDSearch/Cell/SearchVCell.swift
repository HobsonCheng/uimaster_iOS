//
//  SearchVCell.swift
//  UIDS
//
//  Created by one2much on 2018/2/1.
//  Copyright © 2018年 one2much. All rights reserved.
//

import RxSwift
import UIKit
class SearchVCell: UITableViewCell {
    var appNameLabel: UILabel? //应用名称
    var bossNameLabel: UILabel?//创建者名
    var phoneNumLabel: UILabel?//创建者手机号
    var registerNameLabel: UILabel?//
    var addItemLabel: UILabel?//添加时间
    var iconImg: UIImageView?//App图标

    var searchKey: String = ""//搜索键

    var disposeBag = DisposeBag()//释放

    var objData: Project? {
        didSet {
             guard let projectModel = objData else {
                return
            }

            let pname = projectModel.name

            //            let reg = "(?<=<em>).*?(?=</em>)"

            guard var pnameStr = pname else {
                return
            }
            //            let list = Util.regexGetSub(pattern: reg, str: pnameStr)

            pnameStr = pnameStr.replacingOccurrences(of: "<em>", with: "")
            pnameStr = pnameStr.replacingOccurrences(of: "</em>", with: "")

            //            appNameLabel?.diverseStringOriginalStr(original: pnameStr, conversionStrArr: list, withFont: UIFont.systemFont(ofSize: 18), withColor: UIColor(hexString: "#51b0ff"))
            appNameLabel?.text = pnameStr
            pnameStr = projectModel.pname

            pnameStr = pnameStr.replacingOccurrences(of: "<em>", with: "")
            pnameStr = pnameStr.replacingOccurrences(of: "</em>", with: "")

            bossNameLabel?.setYJText(prefixText: " ", icon: .apartment, postfixText: "  \(pnameStr)", size: 15)
            let phoneStr = projectModel.register_phone == "" ? "暂无" : projectModel.register_phone
            phoneNumLabel?.setYJText(prefixText: " ", icon: .phone, postfixText: "  \(phoneStr ??? "暂无")", size: 15)

            registerNameLabel?.setYJText(prefixText: " ", icon: .user, postfixText: "  \(projectModel.register_name ??? "暂无")", size: 15)
            addItemLabel?.setYJText(prefixText: " ", icon: YJType.registTime, postfixText: "  \(projectModel.add_time.split(separator: " ")[0])", size: 15)

            iconImg?.kf.setImage(with: URL(string: projectModel.icon), placeholder: R.image.logo()!, options: nil, progressBlock: nil, completionHandler: nil)
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        let bgView = UIView()
        bgView.layer.cornerRadius = 10
        bgView.backgroundColor = .white
        self.addSubview(bgView)
        bgView.snp.makeConstraints({ make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(125)
        })

        appNameLabel = UILabel()
        bgView.addSubview(appNameLabel!)

        bossNameLabel = UILabel()
        bgView.addSubview(bossNameLabel!)

        phoneNumLabel = UILabel()
        bgView.addSubview(phoneNumLabel!)

        registerNameLabel = UILabel()
        bgView.addSubview(registerNameLabel!)

        addItemLabel = UILabel()
        bgView.addSubview(addItemLabel!)

        iconImg = UIImageView()
        iconImg!.layer.masksToBounds = true
        iconImg!.layer.cornerRadius = 8
        bgView.addSubview(iconImg!)

        let moreBtn = UIButton()
        moreBtn.setImage(R.image.screenAdd(), for: .normal)
        bgView.addSubview(moreBtn)
        moreBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(30)
            make.bottom.equalToSuperview().offset(-10)
        }
        moreBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            let pid = self?.objData?.pid ?? 0
            let appID = self?.objData?.app_id ?? 0
            var name = self?.objData?.name ?? ""
            name = name.replacingOccurrences(of: "<em>", with: "")
            name = name.replacingOccurrences(of: "</em>", with: "")
//            name = name.addingPercentEncoding(withAllowedCharacters: .letters) ?? ""
            let icon = self?.objData?.icon ?? ""
            if let safeData = self?.objData {
                self?.saveItem(parj: safeData)
            }
            AppUtil.addToScreen(appID: appID, pid: pid, name: name, icon: icon)
        }).disposed(by: disposeBag)

        self.appNameLabel?.font = UIFont.systemFont(ofSize: 18)
        self.bossNameLabel?.font = UIFont.systemFont(ofSize: 15)
        self.phoneNumLabel?.font = self.bossNameLabel?.font
        self.registerNameLabel?.font = self.bossNameLabel?.font
        self.addItemLabel?.font = self.bossNameLabel?.font

        self.appNameLabel?.snp.makeConstraints({ make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(15)
        })

        self.iconImg?.snp.makeConstraints({ make in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo((self.appNameLabel?.snp.top)!).offset(25)
            make.width.equalTo(80)
            make.height.equalTo(80)
        })

        self.bossNameLabel?.snp.makeConstraints { make in
            make.left.equalTo(iconImg!.snp.right).offset(5)
            make.top.equalTo((iconImg?.snp.top)!)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(20)
        }

        self.phoneNumLabel?.snp.makeConstraints({ make in
            make.left.equalTo(bossNameLabel!.snp.left)
            make.top.equalTo(bossNameLabel!.snp.bottom).offset(0)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(20)
        })

        self.registerNameLabel?.snp.makeConstraints({ make in
            make.left.equalTo(bossNameLabel!.snp.left)
            make.top.equalTo(phoneNumLabel!.snp.bottom).offset(0)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(20)
        })

        self.addItemLabel?.snp.makeConstraints({ make in
            make.left.equalTo(bossNameLabel!.snp.left)
            make.top.equalTo(registerNameLabel!.snp.bottom).offset(0)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(20)
        })
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func saveItem(parj: Project) {
        DiskCacheHelper.getObj(HistoryKey.HistoryKeyPhone) { obj in
            if obj != nil {
                guard let tmpobj = obj as? String else {
                    return
                }
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
                getObj.data.append(parj)
                DiskCacheHelper.saveObj(HistoryKey.HistoryKeyPhone, value: getObj.toJSONString())
            }
        }
    }
}
