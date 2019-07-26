//
//  RetrievePasswordService.swift
//  UIMaster
//
//  Created by gongcz on 2018/7/20.
//  Copyright © 2018年 one2much. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class RetrievePasswordService {
    /// 登录按钮是否可点击驱动
    let loginBtnEnable: Driver<Bool>
    /// 登录结果驱动
    let loginResult: Driver<Bool>
    /// 获取验证码是否可点击驱动
    let getCodeBtEnable: Driver<Bool>
    /// 获取验证码结果驱动
    let getCodeResult: Driver<NSMutableDictionary>

    init(input: (userName: UITextField, phoneCodeNum: UITextField, pwd: UITextField, loginButton: UIButton, getCodeBt: UIButton), codekey: String?) {
        // 账号
        let accountDriver = input.userName.rx.text.orEmpty.asDriver()
        // 手机验证码
        let phoneCodeDriver = input.phoneCodeNum.rx.text.orEmpty.asDriver()
        // 新密码
        let passwordDriver = input.pwd.rx.text.orEmpty.asDriver()
        // 登录按钮
        let loginButtonDriver = input.loginButton.rx.tap.asDriver()
        // 获取验证码按钮
        let getCodeBtDriver = input.getCodeBt.rx.tap.asDriver()
        // 账号和手机验证码
        let accountAndPassword = Driver.combineLatest(accountDriver, phoneCodeDriver, passwordDriver) {
            ($0, $1, $2)
        }

        loginBtnEnable = accountAndPassword.flatMap({ user, phoneCode, pwd in
            //处理逻辑
            if user.isEmpty || (!InputValidator.isValidPhone(phoneNum: user) && !InputValidator.isValidEmail(email: user)) || phoneCode.isEmpty || pwd.count < 6 {
                return Observable.just(false).asDriver(onErrorJustReturn: false)
            }
            return Observable.just(true).asDriver(onErrorJustReturn: false)
        })

        getCodeBtEnable = accountAndPassword.flatMap({ user, _, _ in
            //处理逻辑
            if user.isEmpty || (!InputValidator.isValidPhone(phoneNum: user) && !InputValidator.isValidEmail(email: user)) {
                return Observable.just(false).asDriver(onErrorJustReturn: false)
            }
            return Observable.just(true).asDriver(onErrorJustReturn: false)
        })

        loginResult = loginButtonDriver.withLatestFrom(accountAndPassword).flatMapLatest({ user, phoneCode, pwd in
            NetworkUtil.request(
                target: .retrievePassword(username: user, auth_code: phoneCode, password: pwd),
                success: { _ in
                    HUDUtil.msg(msg: "重置密码成功", type: .successful)

                    //                saveUserDefaults(key: kAuthorization, value: UserInfoModel.deserialize(from: data)?.data?.Authorization ?? "")

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        VCController.pop(with: VCAnimationClassic.defaultAnimation())
                    }
                }
            ) { error in
                dPrint(error)
            }
            return Observable.just(false).asDriver(onErrorJustReturn: false)
        })

        getCodeResult = getCodeBtDriver.withLatestFrom(accountAndPassword).flatMapLatest({ user, _, _ in
            let dic = NSMutableDictionary()
            dic.setValue(user, forKey: "phone_Email_num")
            //            dic.setValue(code, forKey: "auth_code")

            return Observable.just(dic).asDriver(onErrorJustReturn: NSMutableDictionary())
        })
    }
}
