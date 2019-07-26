//
//  DepartMentDetailVC.swift
//  UIMaster
//
//  Created by hobson on 2018/10/7.
//  Copyright © 2018 one2much. All rights reserved.
//

import RxSwift
import UIKit

class DepartmentDetailVC: BaseNameVC, PageModuleAble {
    private var headPortrait = ""
    private var name = "暂无"
    private var address = "暂无"
    private var phone = "暂无"

    var styleDic: [String: Any]? {
        didSet {
        }
    }

    weak var moduleDelegate: ModuleRefreshDelegate?
    var moduleParams: [String: Any]? {
        didSet {
            if let model = moduleParams?[OrgnizationStructData.getClassName] as? OrgnizationStructData {
                self.headPortrait = model.head_portrait ?? ""
                self.name = model.name ?? "暂无"
                self.address = model.address ?? "暂无"
                self.phone = model.phone ?? "暂无"
                renderUI()
            }
        }
    }
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func renderUI() {
        //1.顶部信息条
        let infoBar = UIView()
        self.view.addSubview(infoBar)
        infoBar.snp.makeConstraints { make in
            make.left.right.equalTo(10)
            make.height.equalTo(60)
            make.top.equalTo(20)
        }
        //头像
        let imageView = UIImageView()
        infoBar.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }
        imageView.cornerRadius = 25
        imageView.maskToBounds = true
        imageView.kf.setImage(with: URL(string: self.headPortrait), placeholder: R.image.defaultPortrait(), options: nil, progressBlock: nil, completionHandler: nil)
        //名称
        let nameLabel = UILabel()
        nameLabel.text = self.name
        nameLabel.font = UIFont.systemFont(ofSize: 18)
        nameLabel.textColor = UIColor(hexString: "#101010")
        infoBar.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(10)
            make.height.equalTo(19)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }

        //2.定位按钮
        let locateBtn = UIButton()
        let addressLabel = UILabel()
        self.view.addSubview(locateBtn)
        self.view.addSubview(addressLabel)
        locateBtn.isHidden = true
        locateBtn.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.right.equalToSuperview().offset(-40)
            make.centerY.equalTo(addressLabel.snp.centerY)
        }
        locateBtn.setBackgroundImage(R.image.sharemore_location(), for: .normal)
        //地址
        addressLabel.text = "地址：\(self.address)"
        addressLabel.font = UIFont.systemFont(ofSize: 17)
        addressLabel.textColor = UIColor(hexString: "#101010")
        addressLabel.snp.makeConstraints { make in
            make.left.equalTo(infoBar.snp.left).offset(16)
            make.right.equalTo(locateBtn.snp.left).offset(-10)
            make.top.equalTo(infoBar.snp.bottom).offset(25)
            make.height.equalTo(16)
        }

        //3. 电话号码
        let phoneBar = UIView()
        self.view.addSubview(phoneBar)
        phoneBar.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(60)
            make.top.equalTo(addressLabel.snp.bottom).offset(25)
        }
        // 电话
        let phoneLabel = UILabel()
        phoneBar.addSubview(phoneLabel)
        phoneLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        phoneLabel.text = "电话号码:"
        phoneLabel.font = UIFont.systemFont(ofSize: 16)
        phoneLabel.textColor = UIColor(hexString: "#101010")
        // 电话号码
        let phoneNumLabel = UILabel()
        phoneBar.addSubview(phoneNumLabel)
        phoneNumLabel.snp.makeConstraints { make in
            make.left.equalTo(phoneLabel.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        phoneNumLabel.text = self.phone
        phoneNumLabel.font = UIFont.systemFont(ofSize: 17)
        phoneNumLabel.textColor = UIColor(hexString: "#74A7F7")
        // 发信息按钮
        let smsBtn = UIButton()
        phoneBar.addSubview(smsBtn)
        smsBtn.setBackgroundImage(R.image.message(), for: .normal)
        let separatorView = UIView()
        phoneBar.addSubview(separatorView)
        separatorView.backgroundColor = .lightGray
        let phoneBtn = UIButton()
        phoneBar.addSubview(phoneBtn)
        phoneBtn.setBackgroundImage(R.image.call(), for: .normal)
        smsBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        separatorView.snp.makeConstraints { make in
            make.right.equalTo(smsBtn.snp.left).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(1)
        }
        phoneBtn.snp.makeConstraints { make in
            make.right.equalTo(separatorView.snp.left).offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }
        smsBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                DeviceTool.sendSMS(with: self?.phone ?? "")
            })
            .disposed(by: disposeBag)
        phoneBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                DeviceTool.makePhoneCall(with: self?.phone ?? "")
            })
            .disposed(by: disposeBag)
        //3. 发短信电话
        //        let sendSMSBtn = UIButton.init()
        //        self.view.addSubview(sendSMSBtn)
        //        sendSMSBtn.snp.makeConstraints { (make) in
        //            make.left.equalTo(25)
        //            make.right.equalTo(-25)
        //            make.height.equalTo(50)
        //            make.bottom.equalToSuperview().offset(-7)
        //        }
        //        sendSMSBtn.setTitle("发送短信", for: .normal)
        //        sendSMSBtn.setTitleColor(UIColor.init(hexString: "#101010"), for: .normal)
        //        sendSMSBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        //        //3. 打电话
        //        let phoneCallBtn = UIButton.init()
        //        self.view.addSubview(phoneCallBtn)
        //        phoneCallBtn.snp.makeConstraints { (make) in
        //            make.left.equalTo(25)
        //            make.right.equalTo(-25)
        //            make.height.equalTo(50)
        //            make.bottom.equalTo(sendSMSBtn.snp.top)
        //        }
        //        phoneCallBtn.setTitle("发送短信", for: .normal)
        //        phoneCallBtn.setTitleColor(UIColor.init(hexString: "#101010"), for: .normal)
        //        phoneCallBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    }
}
