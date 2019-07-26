//
//  RegVCService.swift
//  UIDS
//
//  Created by one2much on 2018/1/19.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

//注册发起
class RegVCService {
    let loginBtnEnable: Driver<Bool>
    let loginResult: Driver<Bool>

    init(input: (userName: UITextField, pwd: UITextField, pwd2: UITextField, nickName: UITextField, codeNum: UITextField?, regButton: UIButton, smsInput: UITextField), codekey: String) {
        let accountDriver = input.userName.rx.text.orEmpty.asDriver()
        let passwordDriver = input.pwd.rx.text.orEmpty.asDriver()
        let password2Driver = input.pwd2.rx.text.orEmpty.asDriver()
        let nickNameDriver = input.nickName.rx.text.orEmpty.asDriver()
//        let codeDriver = input.codeNum.rx.text.orEmpty.asDriver()
        let regButtonDriver = input.regButton.rx.tap.asDriver()

        let smsInputDriver = input.smsInput.rx.text.orEmpty.asDriver()

        let accountAndPassword = Driver.combineLatest(accountDriver, passwordDriver, password2Driver, nickNameDriver, smsInputDriver) {
            ($0, $1, $2, $3, $4)
        }

        loginBtnEnable = accountAndPassword.flatMap({ user, pwd, pwd2, nick, code in
            if user.isEmpty || pwd.isEmpty || pwd2.isEmpty || nick.isEmpty || code.isEmpty {
                return Observable.just(false).asDriver(onErrorJustReturn: false)
            } else if !InputValidator.isValidPhone(phoneNum: user) && !InputValidator.isValidEmail(email: user) {
                return Observable.just(false).asDriver(onErrorJustReturn: false)
            } else if pwd.count < 6 || pwd2.count < 6 || pwd != pwd2 {
                return Observable.just(false).asDriver(onErrorJustReturn: false)
            } else {
                return Observable.just(true).asDriver(onErrorJustReturn: false)
            }
//            if AllRestrictionHandler.shared.ucSetCofig?.project_set?.regist_auth_code_type == 1 {
//                //处理逻辑
//                if user.isEmpty || pwd.isEmpty || pwd2.isEmpty || nick.isEmpty {
//                    return Observable.just(false).asDriver(onErrorJustReturn: false)
//                }
//            } else {
//                //处理逻辑
//                if user.isEmpty || pwd.isEmpty || pwd2.isEmpty || nick.isEmpty {
//                    return Observable.just(false).asDriver(onErrorJustReturn: false)
//                }
//            }
//
//            if pwd != pwd2 {
//                return Observable.just(false).asDriver(onErrorJustReturn: false)
//            }
//
//            return Observable.just(true).asDriver(onErrorJustReturn: false)
        })

        loginResult = regButtonDriver.withLatestFrom(accountAndPassword).flatMapLatest({ user, pwd, _, nick, smscode in
            NetworkUtil.request(
                target: .userRegist(username: user, password: pwd, zh_name: nick, phone_num: user, phone_num_code: smscode, auth_code: smscode, code_key: codekey),
                success: { json in
                    HUDUtil.msg(msg: "注册成功", type: .successful)

                    UserUtil.share.saveUser(userInfo: json)

                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        VCController.pop(with: VCAnimationClassic.defaultAnimation())
                    }
                }
            ) { error in
                dPrint(error)
            }
            return Observable.just(false).asDriver(onErrorJustReturn: false)
        })
    }
}
