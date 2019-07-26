//
//  PhoneService.swift
//  UIDS
//
//  Created by one2much on 2018/1/19.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class PhoneService {
    /// 登录按钮是否可点击驱动
    let loginBtnEnable: Driver<Bool>
    /// 登录结果驱动
    let loginResult: Driver<Bool>
    /// 获取验证码是否可点击驱动
    let getCodeBtEnable: Driver<Bool>
    /// 获取验证码结果驱动
    let getCodeResult: Driver<NSMutableDictionary>

    init(input: (userName: UITextField, codeNum: UITextField?, phoneCodeNum: UITextField, loginButton: UIButton, getCodeBt: UIButton), codekey: String?) {
        // 账号
        let accountDriver = input.userName.rx.text.orEmpty.asDriver()
        // 图片验证码（快捷登陆和注册都不需要了）
//        let codeDriver = input.codeNum.rx.text.orEmpty.asDriver()
        // 手机验证码
        let phoneCodeDriver = input.phoneCodeNum.rx.text.orEmpty.asDriver()
        // 登录按钮
        let loginButtonDriver = input.loginButton.rx.tap.asDriver()
        // 获取验证码按钮
        let getCodeBtDriver = input.getCodeBt.rx.tap.asDriver()
        // 账号和手机验证码
        let accountAndPassword = Driver.combineLatest(accountDriver, phoneCodeDriver) {
            ($0, $1)
        }

        loginBtnEnable = accountAndPassword.flatMap({ user, phoneCode in
            //处理逻辑
            if user.isEmpty || (!InputValidator.isValidPhone(phoneNum: user) && !InputValidator.isValidEmail(email: user)) || phoneCode.isEmpty {
                return Observable.just(false).asDriver(onErrorJustReturn: false)
            }
            return Observable.just(true).asDriver(onErrorJustReturn: false)
        })

        getCodeBtEnable = accountAndPassword.flatMap({ user, _ in
            //处理逻辑
            if user.isEmpty || (!InputValidator.isValidPhone(phoneNum: user) && !InputValidator.isValidEmail(email: user)) {
                return Observable.just(false).asDriver(onErrorJustReturn: false)
            }
            return Observable.just(true).asDriver(onErrorJustReturn: false)
        })

//        let isQuickLogin = (codekey.length == 0)
        loginResult = loginButtonDriver.withLatestFrom(accountAndPassword).flatMapLatest({ user, phoneCode in
            NetworkUtil.request(
                target: .userLoginByPhone(auth_code: phoneCode, phone_number: user),
                success: { json in
                    HUDUtil.msg(msg: "登录成功", type: .successful)
                    //保存authorization
                    let model = UserInfoModel.deserialize(from: json)?.data
                    let authorization = model?.authorization ?? ""
                    saveUserDefaults(key: kAuthorization + "\(GlobalConfigTool.shared.appId ?? 0)", value: authorization)

                    //获取聊天RC4加密key
                    NetworkUtil.request(
                        target: NetworkService.getRC4Key,
                        success: { data in
                            let key = RC4KeyModel.deserialize(from: data)?.data?.key ?? ""
                            saveUserDefaults(key: kRC4Key, value: key)
                        }, failure: nil)

                    //获取完整个人信息
                    NetworkUtil.request(
                        target: .getInfo(user_id: model?.uid ?? 0, user_pid: model?.pid ?? 0),
                        success: { json in
                            UserUtil.share.saveUser(userInfo: json)
                            DispatchQueue.global().sync {
                                DatabaseTool.shared.createUserDatabase()
                                NotificationCenter.default.post(name: Notification.Name(kChatSessionListDataChange), object: nil)
                            }
                            //开启聊天
                            UIApplication.shared.registerForRemoteNotifications()
                        }) { error in
                        dPrint(error)
                    }
                    NotificationCenter.default.post(name: Notification.Name(kPersonalInfoChangeNotification), object: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        _ = VCController.pop(with: VCAnimationBottom.defaultAnimation())
                    }
                }
            ) { error in
                dPrint(error)
            }
            return Observable.just(false).asDriver(onErrorJustReturn: false)
        })

        getCodeResult = getCodeBtDriver.withLatestFrom(accountAndPassword).flatMapLatest({ user, _ in
            let dic = NSMutableDictionary()
            dic.setValue(user, forKey: "phone_Email_num")
//            dic.setValue(code, forKey: "auth_code")

            return Observable.just(dic).asDriver(onErrorJustReturn: NSMutableDictionary())
        })
    }
}
