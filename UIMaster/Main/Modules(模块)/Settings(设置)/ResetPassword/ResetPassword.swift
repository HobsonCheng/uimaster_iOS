import Eureka
import RxSwift
import UIKit

class ResetPasswordModel: BaseData {
    var events: [String: EventsData]?
    var fields: ResetPasswordFields?
    var status: Int?
    var styles: ResetPasswordStyles?
}
class ResetPasswordFields: BaseData {
}
class ResetPasswordStyles: BaseStyleModel {
    var borderShow: Int?
    var borderColor: String?
    var borderWidth: CGFloat?
}
//  模块通用模板,保持整体完整性，
//  不需要的部分可以先注释掉，之后完成后，再统一删掉
//  可以参考ResetPassword模块，如果涉及到分页显示数据，请参考GroupListTopic模块

class ResetPassword: UIView, PageModuleAble {
    // MARK: - 模块相关的配置属性
    private var bgColor = "255,255,255,1"//
    private var bgImg = ""//
    private var bgImgMode = 0//
    private var borderColor = "230,230,230,1"//
    private var borderShow = 1//
    private var borderWidth: CGFloat = 1//
    private var marginBottom = 5//
    private var marginLeft = 5//
    private var marginRight = 5//
    private var marginTop = 5//
    private var opacity = 1//
    private var radius: CGFloat = 5//
    private var events: [String: EventsData]?
    private var disposeBag = DisposeBag()

    weak var moduleDelegate: ModuleRefreshDelegate?
    ///数据模型
    var styleDic: [String: Any]? {
        didSet {
            if let resetPasswordModel = ResetPasswordModel.deserialize(from: styleDic) {
                //由数据模型给模块配置项赋值
                self.bgColor = resetPasswordModel.styles?.bgColor ?? self.bgColor
                self.bgImg = resetPasswordModel.styles?.bgImg ?? self.bgImg
                self.bgImgMode = resetPasswordModel.styles?.bgImgMode ?? self.bgImgMode
                self.borderColor = resetPasswordModel.styles?.borderColor ?? self.borderColor
                self.borderShow = resetPasswordModel.styles?.borderShow ?? self.borderShow
                self.borderWidth = resetPasswordModel.styles?.borderWidth ?? self.borderWidth
                self.radius = resetPasswordModel.styles?.radius ?? self.radius
                self.events = resetPasswordModel.events

                //渲染UI
                renderUI()
                //获取数据
                reloadViewData()
            }
        }
    }

    // MARK: - 模块特有属性
    private var formVC = BaseFormVC(style: .plain)
    private var topView = UIView()

    // MARK: init方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.rx.notification(Notification.Name(kSaveNotification)).takeUntil(self.rx.deallocated).subscribe(onNext: {
            [weak self] ntf in
            self?.endEditing(true)
            if let moduleId = ntf.object as? String {
                if self?.moduleCode == moduleId {
                    self?.callBackPasswordBack()
                }
            }
        }).disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 网络请求
extension ResetPassword {
    //页面刷新时会调用该方法
    func reloadViewData() {
        //请求M2数据信息
        self.requestResetPasswordData()
    }

    @objc func callBackPasswordBack() {
        let form = formVC.form
        for error in form.validate() {
            HUDUtil.msg(msg: error.msg, type: .error)
            return
        }
        let old = form.rowBy(tag: "oldPwd")?.baseValue as? String ?? ""
        let new = form.rowBy(tag: "newPwd")?.baseValue as? String ?? ""
        NetworkUtil.request(target: .upUserPassword(old_password: old, new_password: new), success: { _ in
            HUDUtil.msg(msg: "更新成功", type: .successful)
        }) { error in
            dPrint(error)
        }
    }
    //获取ResetPassword数据
    private func requestResetPasswordData() {
        //        let params = NSMutableDictionary()
        //      params.setValue(self.pageNum, forKey: "page")//涉及分页需要此字段
        //        params.setValue("20", forKey: "page_context")//涉及分页需要此字段
        //        params.setValue(<#value#>, forKey: <#key#>)
        //
        //        ApiUtil.share.<#api名#>(params: params ) { [weak self] (status, data, _) in
        //            //请求成功
        //            if status == ResponseStatus.success {
        //                //转成对应的数据模型，不分页
        //                self?.itemList = ResetPasswordModel.deserialize(from: data)?.data
        //                //如果数据需要分页，使用下面的代码
        //                let tmpList = ResetPasswordModel.deserialize(from: data)?.data
        //                guard let safeTmpList = tmpList else{
        //                    return
        //                }
        //                if self?.page == 1 {
        //                    self?.itemList = safeTmpList
        //                } else if let safeList = self?.itemList{
        //                    self?.itemList = safeList + safeTmpList
        //                }
        //
        //                //tableview需要刷新数据
        //                //self?.reloadData()
        //                //处理UI
        //                self?.renderItems()
        //            }
        //            //请求完成，回调告知AssembleVC停止刷新
        //            if let safeCB = self?.checkRefreshCB {
        //                safeCB()
        //            }
        //        }
    }
}

// MARK: - UI&事件处理
extension ResetPassword {
    //渲染UI
    private func renderUI() {
        self.rx.tapGesture().subscribe(onNext: { _ in
            self.endEditing(true)
        }).disposed(by: disposeBag)
        let user = UserUtil.share.appUserInfo
        //新建上半部分view

        self.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(147)
        }
        formVC.form
        +++ TextRow("loginID") { row in
            row.title = "账号        "
            row.cell.isUserInteractionEnabled = false
            if user?.login_name == "" || user?.login_name == nil {
                row.value = "还没有登陆"
            } else {
                row.value = user?.login_name
            }
            row.validationOptions = .validatesOnChange//校验时机
            row.cellUpdate({ cell, _ in
                cell.textLabel?.textColor = .gray
                cell.textField.textColor = .gray
                cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
                cell.textField.font = UIFont.systemFont(ofSize: 16)
                cell.textField.textAlignment =  .left
                cell.textField.clearButtonMode =  .whileEditing
            })
        }
        <<< TextRow("oldPwd") { row in
            row.title = "旧密码    "
            row.placeholder = "请输入旧密码"
            let ruleRequiredViaClosure = RuleClosure<String> { rowValue in
                if (rowValue == nil || rowValue!.isEmpty) {
                    return  ValidationError(msg: "请输入旧密码")
                }
                if (rowValue?.count < 6) {
                    return  ValidationError(msg: "密码至少6个字符")
                }
                return nil
            }
            row.add(rule: ruleRequiredViaClosure)
            row.validationOptions = .validatesOnChange//校验时机
            row.cellUpdate({ cell, row in
                cell.textLabel?.textColor = .black
                cell.textField.textColor = .gray
                if !row.isValid {
                    row.cell.textLabel?.textColor = .red
                    row.placeholderColor = .red
                }
                cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
                cell.textField.font = UIFont.systemFont(ofSize: 16)
                cell.textField.textAlignment =  .left
                cell.textField.clearButtonMode =  .whileEditing
                if !row.isValid {
                    row.placeholderColor = .red
                }
            })
        }
        <<< PasswordRow("newPwd") {[weak self]  row in
            row.title = "新密码    "
            row.placeholder = "请输入新密码"
            let ruleRequiredViaClosure = RuleClosure<String> {[weak self] rowValue in
                if (rowValue == nil || rowValue!.isEmpty) {
                    return  ValidationError(msg: "请输入新密码")
                }
                if (rowValue?.count < 6) {
                    return  ValidationError(msg: "密码至少6个字符")
                }
                if rowValue == self?.formVC.form.rowBy(tag: "oldPwd")?.baseValue as? String {
                    HUDUtil.msg(msg: "新密码不能与旧密码相同", type: .error)
                    return ValidationError(msg: "新密码不能与旧密码相同")
                }
                return nil
            }
            row.add(rule: ruleRequiredViaClosure)
            row.validationOptions = .validatesOnBlur//校验时机
            row.cellUpdate({ cell, row in
                cell.textLabel?.textColor = .black
                cell.textField.textColor = .gray
                if !row.isValid {
                    row.cell.textLabel?.textColor = .red
                    row.placeholderColor = .red
                }
                cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
                cell.textField.font = UIFont.systemFont(ofSize: 16)
                cell.textField.textAlignment =  .left
                cell.textField.clearButtonMode =  .whileEditing
            })
        }
        <<< PasswordRow("newPwdConfig") {[weak self]  row in
            row.title = "确认密码"
            row.placeholder = "请再次输入新密码"
            let ruleRequiredViaClosure = RuleClosure<String> {[weak self] rowValue in
                let newPwd = self?.formVC.form.rowBy(tag: "newPwd")?.baseValue as? String
                if (rowValue == nil || rowValue!.isEmpty) {
                    return  ValidationError(msg: "请再次输入新密码")
                }
                if newPwd != rowValue {
                    return  ValidationError(msg: "两次输入的密码不同")
                }
                return nil
            }
            row.add(rule: ruleRequiredViaClosure)
            row.validationOptions = .validatesOnBlur//校验时机
            row.cellUpdate({ cell, row in
                cell.textLabel?.textColor = .black
                cell.textField.textColor = .gray
                if !row.isValid {
                    row.cell.textLabel?.textColor = .red
                    row.placeholderColor = .red
                }
                cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
                cell.textField.font = UIFont.systemFont(ofSize: 16)
                cell.textField.textAlignment =  .left
                cell.textField.clearButtonMode =  .whileEditing
            })
        }
        //text
        let bottomLabel = UILabel()
        topView.addSubview(bottomLabel)
        bottomLabel.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.top).offset(0)
            make.left.equalTo(topView.snp.left).offset(20)
        }
        bottomLabel.font = UIFont.systemFont(ofSize: 14)
        bottomLabel.text = "密码至少6个字符，最好同时包含字母和数字。"
        //text
        let clickLabel = UIButton()
        topView.addSubview(clickLabel)
        clickLabel.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.top).offset(20)
            make.left.equalTo(topView.snp.left).offset(20)
        }
        clickLabel.addTarget(self, action: #selector(touchItem(btn:)), for: .touchUpInside)
        let retrievePasswordEvent = self.events?[kRetrievePassword]
        clickLabel.event = retrievePasswordEvent
        clickLabel.setTitle("忘记旧密码？", for: .normal)
        clickLabel.setYJTitleColor(color: .blue)
        clickLabel.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(formVC.view)
    }
    //加入进去
    override func layoutSubviews() {
        super.layoutSubviews()
        formVC.view.frame = CGRect(x: 0, y: 0, width: self.width, height: 200)
        topView.frame = CGRect(x: 0, y: 200, width: self.width, height: 50)
    }
    // MARK: 事件处理
    @objc func touchItem(btn: UIButton) {
        let result = EventUtil.handleEvents(event: btn.event)
        EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
    }
}
