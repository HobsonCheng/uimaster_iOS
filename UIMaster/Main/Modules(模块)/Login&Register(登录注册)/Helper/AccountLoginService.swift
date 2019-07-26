//
//  AccountLoginService.swift
//  RxXMLY
//
//  Created by sessionCh on 2018/1/3.
//  Copyright © 2018年 sessionCh. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class AccountLoginService {
    // 单例类
    static let shareInstance = AccountLoginService()
    private init() {}

    // 验证账号是否合法
    func validationAccount(_ account: String) -> Observable<AccountLoginResult> {
        if account.isEmpty || !InputValidator.isValidPhone(phoneNum: account) || !InputValidator.isValidEmail(email: account) {
            return Observable.just(AccountLoginResult.failed(message: "账号有误请重新输入"))
        } else {
            return Observable.just(AccountLoginResult.success(message: "账号合法"))
        }
    }

    // 验证密码是否合法
    func validationPassword(_ passsword: String) -> Observable<AccountLoginResult> {
        if !passsword.isEmpty && passsword.count >= 6 {
            return Observable.just(AccountLoginResult.success(message: "密码合法"))
        } else {
            return Observable.just(AccountLoginResult.failed(message: "密码至少6位"))
        }
    }

    // 登录请求
    func login(account: String, password: String, codeStr: String) -> Observable<AccountLoginResult> {
        if !(account.isEmpty) {
            let obj = NSMutableDictionary()
            obj.setValue(account, forKey: "username")
            obj.setValue(password, forKey: "password")
            obj.setValue(codeStr, forKey: "auth_code")

            return Observable.just(AccountLoginResult.params(paramsObj: obj))
        } else {
            return Observable.just(AccountLoginResult.failed(message: "密码错误"))
        }
    }

    // 登录按钮是否可用
    func loginBtnEnable(account: String, password: String, codeStr: String) -> Observable<Bool> {
        if !InputValidator.isValidPhone(phoneNum: account) && !InputValidator.isValidEmail(email: account) {
            return Observable.just(false)
        } else if codeStr.isEmpty || password.count < 6 {
            return Observable.just(false)
        } else {
            return Observable.just(true)
        }
    }
    //在验证吗是否填写
    func chechText(codeStr: String) -> Observable<Bool> {
        if !codeStr.isEmpty {
            return Observable.just(true)
        } else {
            return Observable.just(false)
        }
    }

    /*
     BQLAuthEngine.single.auth_qq_login(success: { (response) in
     
     dPrint("success")
     
     }) { (error) in
     
     dPrint("error" + error!)
     }
     
     BQLAuthEngine.single.auth_wechat_login(success: { (response) in
     
     dPrint("success")
     
     }) { (error) in
     
     dPrint("error" + error!)
     }
     
     
     
     BQLAuthEngine.single.auth_sina_login(success: { (response) in
     
     dPrint(response!)
     
     }) { (error) in
     
     dPrint("error" + error!)
     }
     
     
     
     
     
     
     
     
     
     
     
     
     */
}
