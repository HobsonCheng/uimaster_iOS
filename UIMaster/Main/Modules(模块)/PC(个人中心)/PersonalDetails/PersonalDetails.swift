import Eureka
import RxSwift
import UIKit

class PersonalDetailsModel: BaseData {
    var styles: PersonalDetailsStyles?
    var events: [String: EventsData]?
    var fields: PersonalDetailsFields?
}

class PersonalDetailsStyles: BaseStyleModel {
    var borderColor: String?
    var borderShow: Int?
    var borderWidth: Int?
}

class PersonalDetailsFields: BaseData {
    var nick: Int?
    var number: Int?
    var sex: Int?
    var birthday: Int?
    var email: Int?
    var head: Int?
    var info: Int?
}

//  模块通用模板,保持整体完整性，
//  不需要的部分可以先注释掉，之后完成后，再统一删掉
//  可以参考PersonalDetailst模块，如果涉及到分页显示数据，请参考GroupListTopic模块

class PersonalDetails: UIView, PageModuleAble {
    // MARK: 模块相关的配置属性
    private var birthday = 1//生日
    private var borderColorStr = "188,0,0,1"//边框 颜色
    private var borderShow = 1//边框 是否显示
    private var borderWidthInt = 0//边框 宽度
    private var email = 1//邮箱
    private var head = 1//头像
    private var info = 1//个性签名
    private var nick = 1//昵称
    private var number = 1//手机号码
    private var radius: CGFloat = 15//圆角
    private var sex = 1//性别
    private var bgColor = "255,255,255,1"//背景颜色
    private var bgImg = ""//背景图片

    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let personalDetailsEditModel = PersonalDetailsModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.birthday = personalDetailsEditModel.fields?.birthday ?? self.birthday
                self.bgColor = personalDetailsEditModel.styles?.bgColor ?? self.bgColor
                self.bgImg = personalDetailsEditModel.styles?.bgImg ?? self.bgImg
                self.borderColorStr = personalDetailsEditModel.styles?.borderColor ?? self.borderColorStr
                self.borderShow = personalDetailsEditModel.styles?.borderShow ?? self.borderShow
                self.radius = personalDetailsEditModel.styles?.radius ?? self.radius
                self.borderWidthInt = personalDetailsEditModel.styles?.borderWidth ?? self.borderWidthInt
                self.email = personalDetailsEditModel.fields?.email ?? self.email
                self.head = personalDetailsEditModel.fields?.head ?? self.head
                self.info = personalDetailsEditModel.fields?.info ?? self.info
                self.nick = personalDetailsEditModel.fields?.nick ?? self.nick
                self.number = personalDetailsEditModel.fields?.number ?? self.number
//                self.radius = personalDetailsEditModel.styles?.radius ?? self.radius
                self.sex = personalDetailsEditModel.fields?.sex ?? self.sex

                //渲染UI
                renderUI()
            }
        }
    }
    weak var moduleDelegate: ModuleRefreshDelegate?

    //模块特有属性
    private var formVC = BaseFormVC()
    private var uploadImage: UIImage?
    private var imgUrl: String?
    private var topImage = UIButton()
    private var disposeBag = DisposeBag()

    // MARK: init方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.rx.notification(Notification.Name(kUpdatePersonalInfoNotification))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                self?.endEditing(true)
                self?.updateInfo()
            })
            .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //对象被销毁时调用
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 网络请求
extension PersonalDetails {
//    //页面刷新时会调用该方法
//    func reloadViewData() {
//        //加载更多时，分页数加1，不需要分页可以去掉下面这行
//        self.pageNum = isLoadMore ? self.pageNum + 1 : 1
//    }

    @objc func updateInfo() {
        let form = formVC.form
        let portrait = self.imgUrl ?? ""
        let nickName = form.rowBy(tag: "nickName")?.baseValue as? String
        if nickName?.isEmpty ?? true {
            HUDUtil.msg(msg: "用户名不能为空", type: .error)
            return
        }
        let birthday = form.rowBy(tag: "birthday")?.baseValue as? String ?? ""
        let signature = form.rowBy(tag: "info")?.baseValue as? String ?? ""
        let email = form.rowBy(tag: "email")?.baseValue as? String ?? ""
        var sex: Int = 0
        if let gender = form.rowBy(tag: "sex")?.baseValue as? String {
            if gender == "女" {
                sex = 1
            } else {
                sex = 0
            }
        }

        NetworkUtil.request(
            target: .updateInfo(email: email.trim(), signature: signature.trim(), birthday: birthday, gender: sex, zh_name: nickName!.trim(), head_portrait: portrait),
            success: { json in
                //更新用户信息
                UserUtil.share.saveUser(userInfo: json)
                let user = UserUtil.share.appUserInfo
                HUDUtil.msg(msg: "更新成功", type: .successful)
                DatabaseTool.shared.modifyContacts(uid: user?.uid ?? 0, pid: user?.pid ?? 0, avatar: portrait, nickname: nickName ?? "", type: 0, message: nil)
                NotificationCenter.default.post(name: Notification.Name(kPersonalInfoChangeNotification), object: nil)
            }
        ) { error in
            HUDUtil.msg(msg: "更新失败", type: .error)
            dPrint(error)
        }
    }
}

// MARK: - UI&事件处理
extension PersonalDetails {
    //渲染UI
    private func renderUI() {
        self.layer.cornerRadius = self.radius
        self.layer.masksToBounds = true
        let user = UserUtil.share.appUserInfo
        //日期转换用
        let formatter = DateFormatter()
        //新建上半部分view
        let topView = UIView()
        topView.backgroundColor = self.bgColor.toColor()
        self.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(147)
        }
        //pic
        topView.addSubview(topImage)
        topImage.snp.makeConstraints { make in
            make.top.equalTo(30)
            make.centerX.equalTo(topView.snp.centerX)
            make.width.equalTo(72)
            make.height.equalTo(72)
        }
        topImage.addTarget(self, action: #selector(touchItem(btn:)), for: .touchUpInside)
        if UserUtil.share.appUserInfo?.head_portrait?.isEmpty ?? true {
            topImage.setBackgroundImage(R.image.defaultPortrait()!, for: .normal)
        } else {
            topImage.kf.setBackgroundImage(with: URL(string: UserUtil.share.appUserInfo?.head_portrait ?? ""), for: .normal, placeholder: R.image.defaultPortrait()!, options: nil, progressBlock: nil, completionHandler: nil)
        }
        topImage.layer.cornerRadius = 36
        topImage.layer.masksToBounds = true
        //text
        let topLabel = UILabel()
        topView.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.top.equalTo(topImage.snp.bottom).offset(15)
            make.centerX.equalTo(topView.snp.centerX)
        }
        topLabel.font = UIFont.systemFont(ofSize: 18)
        topLabel.text = "更换头像"

        formVC.form
            +++ TextRow("nickName") { [weak self] row in
                row.title = "昵称"
                row.value = user?.zh_name ?? "无昵称"
                row.hidden = Condition.function([""], { _ -> Bool in
                    self?.nick == 0
                })

                row.cellUpdate({ cell, row in
                    row.cell.textLabel?.textColor = .gray
                    row.cell.detailTextLabel?.textColor = .black
                })
                row.onChange({ textRow in
                    if (textRow.value?.trim().count ?? 0) >= 15 {
                        row.value = textRow.value?.subStr(from: 0, length: 15)
                        row.cell.update()
                    }
                })
            }
            <<< LabelRow("sex") { [weak self] row in
                row.title = "性别"
                let genderArr = [["男", "女"]]
                var pickerViewSelectedValue = (column: 0, row: 0)
                if user?.gender == 1 {
                    pickerViewSelectedValue = (column: 0, row: 1)
                }
                let genderName = genderArr[pickerViewSelectedValue.column]
                let value = genderName[pickerViewSelectedValue.row]
                row.value = value
                let alert = UIAlertController(style: .alert, title: "", message: "请选择您的性别")

                alert.addPickerView(values: genderArr, initialSelection: pickerViewSelectedValue) { _, _, index, _ in
                    let genderName = genderArr[index.column]
                    let value = genderName[index.row]
                    row.value = value
                    row.cell.update()
                }
                alert.addAction(title: "完成", style: .cancel, handler: nil)
                let pickerViewController = alert.value(forKey: "contentViewController") as? PickerViewViewController
                pickerViewController?.preferredContentSize.height = 100
                row.onCellSelection({ _, _ in
                    alert.show()
                })
                row.hidden = Condition.function([""], { _ -> Bool in
                    self?.sex == 0
                })
                row.cellUpdate({ cell, row in
                    row.cell.textLabel?.textColor = .gray
                    row.cell.detailTextLabel?.textColor = .black
                })
            }

            <<< LabelRow("birthday") { [weak self] row in
                //初始化
                row.title = "生日"
                formatter.dateFormat = "yyyy-MM-dd"
                if !(user?.birthday?.split(separator: " ").isEmpty ?? true) {
                    user?.birthday = String(user?.birthday?.split(separator: " ")[0] ?? "")
                }
                var date: Date?
                if user?.birthday?.isEmpty ?? true {
                    row.value = formatter.string(from: Date())
                } else {
                    date = formatter.date(from: user?.birthday ?? "")
                    row.value = formatter.string(from: date ?? Date())
                }
                //选值
                let minData = formatter.date(from: "1900-01-01")
                let alert = UIAlertController(title: "选择日期", message: "请选择您的出生日期", preferredStyle: .alert)
                alert.addDatePicker(mode: .date, date: date, minimumDate: minData, maximumDate: Date(), action: { date in
                    row.value = formatter.string(from: date)
                    row.updateCell()
                })
                alert.preferredContentSize.height = 100
                alert.addAction(title: "完成", style: .cancel, handler: nil)
                row.onCellSelection({ _, _ in
                    alert.show()
                })
                row.hidden = Condition.function([""], { _ -> Bool in
                    self?.birthday == 0
                })
                row.cellUpdate({ cell, row in
                    row.cell.textLabel?.textColor = .gray
                    row.cell.detailTextLabel?.textColor = .black
                })
            }
//            DateRow("birthday"){[weak self] row in
//                row.title = "生日"
//                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
//                if user?.birthday == "" || user?.birthday == nil {
//                    row.value = formatter.date( from: "2001-01-01 00:00:00 +0000")
//                } else {
//                    row.value = formatter.date(from: user?.birthday ?? "2000-01-01 00:00:00")
//                }
//                row.hidden = Condition.function([""], { (form) -> Bool in
//                    return self?.birthday == 0
//                })
//                row.cellUpdate({ (cell, row) in
//                    row.cell.textLabel?.textColor = .gray
//                    row.cell.detailTextLabel?.textColor = .black
//                })
//            }
            <<< TextRow("info") { [weak self] row in
                row.title = "个性签名"
                if user?.signature?.isEmpty ?? true {
                    row.placeholder = "请填写"
                } else {
                    row.value = user?.signature
                }
                row.onCellSelection({ _, _ in
                })
                row.hidden = Condition.function([""], { _ -> Bool in
                    self?.info == 0
                })
                row.cellUpdate({ cell, row in
                    row.cell.textLabel?.textColor = .gray
                    row.cell.detailTextLabel?.textColor = .black
                })
                row.onChange({ textRow in
                    if (textRow.value?.trim().count ?? 0) >= 40 {
                        row.value = textRow.value?.subStr(from: 0, length: 40)
                        row.cell.update()
                    }
                })
            }
//            <<< TextRow("phoneNum"){ row in
//                row.title = "手机号码"
//                row.value = "请填写"
//                row.onCellSelection({ (cell, row) in
//
//                })
//                row.hidden = Condition.function([""], { (form) -> Bool in
//                    return self.number == 0
//                })
//                row.cellUpdate({ (cell, row) in
//                    row.cell.textLabel?.textColor = .gray
//                    row.cell.detailTextLabel?.textColor = .black
//                })
//            }
            <<< EmailRow("email") { [weak self] row in
                row.title = "邮箱"
                if user?.email?.isEmpty ?? true {
                    row.placeholder = "请填写"
                } else {
                    row.value = user?.email
                }

                row.onCellSelection({ _, _ in
                })
                row.hidden = Condition.function([""], { _ -> Bool in
                    self?.email == 0
                })
                row.cellUpdate({ cell, row in
                    row.cell.textLabel?.textColor = .gray
                    row.cell.detailTextLabel?.textColor = .black
                })
                row.onChange({ textRow in
                    if (textRow.value?.trim().count ?? 0) >= 30 {
                        row.value = textRow.value?.subStr(from: 0, length: 30)
                        row.cell.update()
                    }
                })
            }
        self.addSubview(formVC.view)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        formVC.view.frame = CGRect(x: 0, y: 150, width: self.width, height: 500)
    }

    // MARK: 事件处理
    @objc func touchItem(btn: UIButton) {
        let alertVC = UIAlertController(title: "上传图片", message: nil, preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "拍照", style: .default, handler: { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                picker.allowsEditing = true
                kWindowRootVC?.present(picker, animated: true, completion: nil)
            } else {
                HUDUtil.msg(msg: "您的设备好像不支持照相机~~", type: .info)
            }
        }))
        alertVC.addAction(UIAlertAction(title: "相册选取", style: .default, handler: { _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            kWindowRootVC?.present(picker, animated: true, completion: nil)
        }))
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        kWindowRootVC?.present(alertVC, animated: true, completion: nil)
    }

    // MARK: 上传图片
    func uplaodImage() {
        //图片为空返回
        guard let safeImage = self.uploadImage else {
            HUDUtil.msg(msg: "图片数据为空", type: .error)
            return
        }
        let handler = HUDUtil.upLoadProgres()
        //上传七牛云
        UploadImageTool.uploadImage(
            image: safeImage,
            progress: { url, progress in
                DispatchQueue.main.async {
                    handler(CGFloat(progress))
//                HUDUtil.upLoadProgres(progressNum: CGFloat(progress))
                }
            },
            success: { url in
                self.imgUrl = url
                self.topImage.kf.setBackgroundImage(with: URL(string: url), for: .normal, placeholder: UIImage(named: "defaultPortrait"), options: nil, progressBlock: nil, completionHandler: nil)
                dPrint("url:\(url)")
            }
        ) { errorMsg in
            HUDUtil.msg(msg: errorMsg, type: .error)
        }
    }
}

// MARK: - 代理方法
/**
 1.协议的采纳放到该扩展上。
 2.代理方法统一放到这里，不同的代理用//MARK: 分开
 */
extension PersonalDetails: UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: 选取图片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            dPrint("No image found")
            return
        }
        self.uploadImage = image
        uplaodImage()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
