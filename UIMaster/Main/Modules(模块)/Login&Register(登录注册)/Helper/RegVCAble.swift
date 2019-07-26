//
//  RegVCAble.swift
//  UIDS
//
//  Created by one2much on 2018/1/18.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Foundation
import NSObject_Rx
import RxCocoa
import RxSwift
import Then
import UIKit

//import Font_Awesome_Swift

//用于确认密码
private var pwd: String?

// MARK: 注册扩展 那边太拥挤了
extension AccountLoginable where Self: UIView {//协议扩展
    // MARK: - 注册按钮
    func initRegBtnView(onNext: @escaping (_ event: Bool) -> Void) -> (UIView, UIButton) {
        // 创建
        let btnView = UIView().then {
            $0.backgroundColor = kThemeWhiteColor
        }
        let regBtn = UIButton().then {
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = Metric.cornerRadius
            $0.titleLabel?.font = Metric.loginBtnFontSize
            $0.setTitleColor(kThemeWhiteColor, for: .normal)
            $0.setTitle(Metric.regBtnTitle, for: .normal)
            $0.backgroundColor = kNaviBarBackGroundColor
            $0.rx
                .tap
                .do(onNext: {
                    onNext(true)
                })
                .subscribe()
                .disposed(by: rx.disposeBag)
        }
        // 添加
        btnView.addSubview(regBtn)
        // 布局
        regBtn.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalToSuperview()
        }
        return (btnView, regBtn)
    }

    // MARK: - 账号输入框
    func initOtherField(type: Int?, titleStr: String?, otherField: UITextField? = nil, onNext: @escaping () -> Void) -> UITextField {
        let field = UITextField().then {
            $0.layer.masksToBounds = true
            $0.layer.borderColor = kThemeGainsboroColor.cgColor
            $0.layer.borderWidth = Metric.borderWidth
            $0.layer.cornerRadius = Metric.cornerRadius
            $0.borderStyle = .none
            $0.leftViewMode = .always
            $0.leftView = self.otherLeftView(type: type, titleStr: titleStr)
            if type == 1 {
                if AllRestrictionHandler.shared.ucSetConfig?.project_set?.regist_type == 2 {//条件注册
                    //                    let bytes = Util.strToByte(str: (AllRestrictionHandler.shared.ucSetCofig.project_set?.regist_condition)!)
                    //                    if (bytes[0] == "1") && (bytes[1] == "1") {
                    //                        $0.placeholder = "请输入手机号/邮箱号"
                    //                    }else if bytes[0] == "1" {
                    $0.placeholder = "请输入\(titleStr ?? "")"
                    //                    }else if bytes[1] == "1" {
                    //                        $0.placeholder = "请输入邮箱号"
                    //                    }
                } else {
                    $0.placeholder = "请输入\(titleStr ?? "")"
                }
            } else {
                if titleStr == "确认密码" {
                    $0.placeholder = titleStr ?? "确认密码"
                }
                $0.placeholder = "请输入\(titleStr ?? "")"
            }
            if type == 2 {//密码
                $0.isSecureTextEntry = true
            }
        }

        // 输入内容 校验
        let fieldObservable = field.rx.text.skip(1).throttle(0.1, scheduler: MainScheduler.instance).map { (input: String?) -> Bool in
            guard let input = input else {
                return false
            }
            dPrint("\(input)")
            if type == 1 {
                if InputValidator.isValidEmail(email: input) || InputValidator.isValidPhone(phoneNum: input) {
                    return true
                } else {
                    return false
                }
            } else if type == 2 {
                if input.count < 6 {
                    return false
                } else if let safeField = otherField {
                    if safeField.text == input {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return true
                }
            } else {
                return !input.isEmpty
            }

            //            if type == 1 {
            //                if AllRestrictionHandler.shared.ucSetCofig?.project_set?.regist_type == 2 {//条件注册
            ////                    let bytes = Util.strToByte(str: (AllRestrictionHandler.shared.ucSetCofig.project_set?.regist_condition)!)
            //
            ////                    if (bytes[0] == "1") && (bytes[1] == "1") {
            ////                        return InputValidator.isValidPhone(phoneNum: input) || InputValidator.isValidEmail(email: input)
            ////                    }else if bytes[0] == "1" {
            //                        return InputValidator.isValidPhone(phoneNum: input)
            ////                    }else if bytes[1] == "1" {
            ////                        return InputValidator.isValidEmail(email: input)
            ////                    }
            //
            ////                    return !input.isEmpty
            //                } else {
            //                    return !input.isEmpty
            //                }
            //            } else if type == 2 {
            //                if let safeField = otherField{
            //                    return safeField.text == input && input.count >= 6
            //                }else{
            //                   return input.count >= 6
            //                }
            //                //FIXME: 根据json判断
            ////                return InputValidator.isvalidationPassword(password: input)
            //            } else {
            //                return !input.isEmpty
            //            }
        }

        fieldObservable
            .map { (valid: Bool) -> UIColor in
                let color = valid ? kThemeGainsboroColor : kThemeOrangeRedColor
                return color
            }
            .subscribe(onNext: { color in
                DispatchQueue.main.async {
                    field.layer.borderColor = color.cgColor
                }
            })
            .disposed(by: rx.disposeBag)
        return field
    }

    // MARK: - 账号输入框 左视图
    private func otherLeftView(type: Int?, titleStr: String?) -> UIView {
        let leftView = UIView().then {
            $0.frame = CGRect(x: 0, y: 0, width: 40, height: 44)
        }

        let tipLab = UILabel().then {
            $0.textAlignment = .center
            $0.font = Metric.fontSize
            $0.textColor = kThemeTitielColor
            if type == 1 {//用户名
                $0.setYJIcon(icon: .account, iconSize: 18)
            } else if type == 2 {//密码
                $0.setYJIcon(icon: .password, iconSize: 18)
            } else if type == 3 {//昵称
                $0.setYJIcon(icon: .person, iconSize: 20)
            }
        }
        // 添加
        leftView.addSubview(tipLab)
        tipLab.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(MetricGlobal.margin)
            make.right.equalToSuperview().offset(-MetricGlobal.margin)
            make.width.equalTo(Metric.tipBtnWidth)
        }
        return leftView
    }
}
