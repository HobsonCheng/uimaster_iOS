//
//  PPAddressBookHandle.swift
//  PPGetAddressBookSwift
//
//  Created by AndyPang on 16/9/16.
//  Copyright © 2016年 AndyPang. All rights reserved.
//

import AddressBook
import Contacts
import UIKit

/// 一个联系人信息模型的闭包
 typealias PPPersonModelClosure = (_ model: PPPersonModel) -> Void
/// 授权失败的闭包
 typealias AuthorizationFailure = () -> Void

class PPAddressBookHandle {
    static var shared = PPAddressBookHandle()

    private init() { }

    func requestAuthorizationWithSuccessClosure(success: @escaping () -> Void) {
        if #available(iOS 9.0, *) {
            if CNContactStore.authorizationStatus(for: CNEntityType.contacts) == CNAuthorizationStatus.authorized {
                return
            }
            contactStore.requestAccess(for: .contacts, completionHandler: { granted, _ in
                if granted {
                    success()
                    dPrint("授权成功")
                } else {
                    dPrint("授权失败")
                    let alertVC = UIAlertController(title: "提示", message: "请在iPhone的“设置-隐私-通讯录”选项中，允许单位APP访问您的通讯录", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "前往设置", style: .default, handler: { _ in
                        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                    }))
                    alertVC.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: nil))
                    alertVC.show()
                }
            })
        } else {
            // 1.获取授权的状态
            let status = ABAddressBookGetAuthorizationStatus()
            // 2.判断授权状态,如果是未决定状态,才需要请求
            if status == ABAuthorizationStatus.notDetermined {
                // 3.创建通讯录进行授权
                ABAddressBookRequestAccessWithCompletion(addressBook, { granted, _ in
                    if granted {
                        success()
                        dPrint("授权成功")
                    } else {
                        dPrint("授权失败")
                    }
                })
            }
        }
    }

    func getAddressBookDataSource(personModel success: PPPersonModelClosure, authorizationFailure failure: AuthorizationFailure) {
        if #available(iOS 9.0, *) {
            // iOS9 之后
            getDataSourceFrom_IOS9_Later(personModel: success, authorizationFailure: failure)
        } else {
            HUDUtil.msg(msg: "暂不支持 iOS 9.0 以下的设备，请升级系统", type: .error)
        }
//        else {
//            // iOS9 之前
//            getDataSourceFrom_IOS9_Ago(personModel: success, authorizationFailure: failure)
//        }

    }

//    // MARK: - IOS9之前获取通讯录的函数
//    @available(iOS, introduced: 8.0, deprecated: 9.0)
//    private func getDataSourceFrom_IOS9_Ago(personModel success: PPPersonModelClosure, authorizationFailure failure: AuthorizationFailure) {
//
//        // 1.获取授状态
//        let status = ABAddressBookGetAuthorizationStatus()
//
//        // 2.如果没有授权,先执行授权失败的闭包后return
//        if status != ABAuthorizationStatus.authorized {
//            failure()
//            return
//        }
//
//        // 3.创建通信录对象
//        //let addressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
//
//        // 4.按照按姓名属性的排序规则从通信录对象中请求所有的联系人
//        let recordRef = ABAddressBookCopyDefaultSource(addressBook).takeRetainedValue()
//        let allPeopleArray = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, recordRef,ABPersonGetSortOrdering()).takeRetainedValue() as Array
//
//        // 5.遍历所有联系人
//        for personInfo in allPeopleArray {
//
//            let model = PPPersonModel()
//
//            // 5.1 获取到联系人
//            let person = personInfo as ABRecord
//
//            // 5.2 获取联系人全名
//            let name = ABRecordCopyCompositeName(person)?.takeRetainedValue() as String? ?? "无名氏"
//            model.name = name
//
//            // 5.3 获取头像数据
//            let imageData = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail)?.takeRetainedValue() as NSData? ?? NSData.init()
//            model.headerImage = UIImage.init(data: imageData as Data)
//
//            // 5.4 遍历每个人的电话号码
//            let phones = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue();
//            let phoneCount = ABMultiValueGetCount(phones)
//            for i in 0..<phoneCount {
//                // 获取号码
//                let phoneValue = ABMultiValueCopyValueAtIndex(phones, i)?.takeRetainedValue() as! String? ?? ""
//                let mobile = removeSpecialSubString(string: phoneValue)
//                model.mobileArray.append(mobile)
//
//            }
//
//            success(model)
//
//        }
//
//    }

    // MARK: - IOS9之后获取通讯录的函数
    @available(iOS 9.0, *)
    private func getDataSourceFrom_IOS9_Later(personModel success: PPPersonModelClosure, authorizationFailure failure: AuthorizationFailure) {
        // 1.获取授权状态
        let status = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        // 2.如果没有授权,先执行授权失败的闭包后return
        if status != CNAuthorizationStatus.authorized {
            failure()
            return
        }

        // 3.获取联系人
        // 3.1.创建联系人仓库
        //let store = CNContactStore.init();

        // 3.2.创建联系人的请求对象
        // keys决定能获取联系人哪些信息,例:姓名,电话,头像等
        let fetchKeys = [CNContactFormatter.descriptorForRequiredKeys(for: CNContactFormatterStyle.fullName), CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey, CNContactPostalAddressesKey] as? [CNKeyDescriptor] ?? []
        let fetchRequest = CNContactFetchRequest(keysToFetch: fetchKeys)

        // 3.请求获取联系人
        var contacts = [CNContact]()
        do {
            try contactStore.enumerateContacts(with: fetchRequest, usingBlock: {  contact, _ -> Void in
                contacts.append(contact)
            })
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        // 3.1遍历联系人
        for contact in contacts {
            // 创建联系人模型
            let model = PPPersonModel()

            // 获取联系人全名
            model.name = CNContactFormatter.string(from: contact, style: CNContactFormatterStyle.fullName) ?? "无名氏"

            // 获取头像
            let imageData = contact.thumbnailImageData ?? NSData() as Data
            model.headerImage = UIImage(data: imageData)

            // 遍历一个人的所有电话号码
            for labelValue in contact.phoneNumbers {
                let phoneNumber = labelValue.value
                let label = labelValue.label ?? ""
//                    CNLabeledValue<NSCopying & NSSecureCoding>.localizedString(forLabel: labelValue.label ?? "")
                model.mobileDic[label] = phoneNumber.stringValue
            }
            // 遍历一个人的所有地址
            for labelValue in contact.postalAddresses {
                let address = labelValue.value
                let label = labelValue.label ?? ""
//                    CNLabeledValue<NSCopying & NSSecureCoding>.localizedString(forLabel: labelValue.label ?? "")
                if #available(iOS 10.3, *) {
                    model.addressDic[label] = address.country + address.state + address.city + address.subLocality + address.street + address.postalCode
                } else {
                    model.addressDic[label] = address.country + address.state + address.city + address.street + address.postalCode
                }
            }

            // 将联系人模型回调出去
            success(model)
        }
    }

    /**
     过滤指定字符串(可自定义添加自己过滤的字符串)
     */
    func removeSpecialSubString(string: String) -> String {
        let resultString = string.replacingOccurrences(of: "+86", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: " ", with: "")

        return resultString
    }

    // MARK: - lazy
    @available(iOS 9.0, *)
    lazy var contactStore: CNContactStore = {
        let contactStore = CNContactStore()
        return contactStore
    }()

    @available(iOS, introduced: 8.0, deprecated: 9.0)
    lazy var addressBook: ABAddressBook = {
        let addressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        return addressBook
    }()
}
