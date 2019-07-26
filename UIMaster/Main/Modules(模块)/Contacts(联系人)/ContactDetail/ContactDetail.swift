//
//  ContactDetail.swift
//  UIMaster
//
//  Created by hobson on 2018/10/16.
//  Copyright © 2018 one2much. All rights reserved.
//

import Kingfisher
import UIKit

class ContactDetailConfigModel: BaseData {
    var events: [String: EventsData]?
}

class ContactDetail: BaseNameVC, PageModuleAble, UIShareAble {
    @IBOutlet weak var phoneNumLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!

    weak var moduleDelegate: ModuleRefreshDelegate?
    var model: ContactDetailConfigModel?
    var styleDic: [String: Any]?
    var moduleParams: [String: Any]? {
        didSet {
            self.contactData = moduleParams?[ContactPersonData.getClassName] as? ContactPersonData
        }
    }
    var contactData: ContactPersonData? {
        didSet {
            self.phoneNumLabel.text = contactData?.telephone ?? "暂无电话号码"
            self.nameLabel.text = contactData?.full_name ?? "暂无昵称"
            self.placeholderLabel.text = contactData?.full_name?.first?.description ?? "无"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.placeholderLabel.layer.cornerRadius = 5
        self.placeholderLabel.layer.masksToBounds = true
    }

    @IBAction private func sendSMS(_ sender: Any) {
        guard let phone = contactData?.telephone else {
            HUDUtil.msg(msg: "号码为空", type: .error)
            return
        }
        DeviceTool.sendSMS(with: phone)
    }
    @IBAction private func makePhoneCall(_ sender: Any) {
        guard let phone = contactData?.telephone else {
            HUDUtil.msg(msg: "号码为空", type: .error)
            return
        }
        DeviceTool.makePhoneCall(with: phone)
    }

    @IBAction private func inviteOthers(_ sender: Any) {
    }

    @objc func gotoBack() {
        VCController.pop(with: VCAnimationClassic.defaultAnimation())
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction private func shareAppToOther(_ sender: Any) {
        NetworkUtil.request(target: .applyForCode(out_time: 10, can_use_num: 10, code_type: 0), success: { [weak self] json in
            let model = InviteModel.deserialize(from: json)?.data
            let logo = ImageCache.default.retrieveImageInDiskCache(forKey: kLogoCacheKey)
            let image = QRCodeUtil.shared.createCenterImageQRCode(byImage: logo, withStr: model?.url ?? "")
            guard let safeImage = image else {
                HUDUtil.msg(msg: "生成二维码失败", type: .error)
                return
            }
            self?.shareToOthers(text: "\(UserUtil.share.appUserInfo?.zh_name ?? "")邀请您使用APP", imageName: nil, orImage: safeImage, linkStr: model?.url)
        }) { error in
            dPrint(error)
        }
    }
}
