//
//  PersonalCenterBtn.swift
//  UIMaster
//
//  Created by hobson on 2018/7/18.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

protocol PersonalCenterBtnPtc: AnyObject {
    func didClickItemButton(sender: PersonalCenterBtnView)
}

class PersonalCenterBtnView: UIView {
    var button: UIButton?
    var lable: UILabel?
    var relation: Relation?
    weak var delegate: PersonalCenterBtnPtc?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func setUI(with relation: Relation) {
        self.button = UIButton().then({
            if !(relation.color?.isEmpty ?? true) {
                $0.backgroundColor = UIColor(hexString: relation.color)
            }
            $0.rx.tap
                .do(onNext: {
                    self.delegate?.didClickItemButton(sender: self)
                })
                .asObservable()
                .subscribe()
                .disposed(by: rx.disposeBag)
            $0.width = 50
            $0.left = self.width / 2 - 25
            $0.height = 50
            $0.layer.cornerRadius = 25
            $0.layer.masksToBounds = true
            $0.accessibilityIdentifier = relation.relation_name
        })

        self.lable = UILabel().then({
            $0.font = UIFont.systemFont(ofSize: 15)
            $0.text = relation.relation_name
            $0.width = self.width
            $0.textAlignment = NSTextAlignment.center
            $0.textColor = .black
            $0.top = 70
            $0.height = 15
        })

        if let code = relation.icon {
            self.button?.setYJIconWithCode(iconCode: code, forState: .normal)
        }

        self.addSubview(self.button!)
        self.addSubview(self.lable!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
