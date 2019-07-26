//
//  MainTabBarItem.swift
//  UIDS
//
//  Created by one2much on 2018/2/11.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

class MainTabBarItem: UIControl {
    var itemData: TabbarItems
    let imgView: UIImageView
    let titleLabel: UILabel
    var index: Int?
    //属性观察器
    var currentSelectState = false {
        didSet {
            let appID = GlobalConfigTool.shared.appId ?? 0
            if currentSelectState {
                //选中
                let path = SandboxTool.getFilePath(of: "tabBar_icon_\((index ?? 1) + 1)_sel@2x.png", in: .applicationSupport, subPathStr: "com.one2much.app\(appID)")
                imgView.image = UIImage.getImage(in: path)
                titleLabel.textColor = itemData.styles?.colorSelected?.toColor() ?? UIColor.black
                titleLabel.font = UIFont.systemFont(ofSize: itemData.styles?.fontSizeSelected ?? 14)
            } else {
                //没选中
                let path = SandboxTool.getFilePath(of: "tabBar_icon_\((index ?? 1) + 1)@2x.png", in: .applicationSupport, subPathStr: "com.one2much.app\(appID)")
                imgView.image = UIImage.getImage(in: path)
                titleLabel.textColor = itemData.styles?.color?.toColor() ?? UIColor.white
                titleLabel.font = UIFont.systemFont(ofSize: itemData.styles?.fontSize ?? 14)
            }
        }
    }

    init(frame: CGRect, itemData: TabbarItems, itemIndex: Int) {
        self.itemData = itemData
        self.index = itemIndex
        let appID = GlobalConfigTool.shared.appId ?? 0
        //布局使用的参数
        var defaultLabelH: CGFloat = 20.0 //文字的高度
        var imgTop: CGFloat = 3
        var imgWidth: CGFloat = 25
        //中间的按钮的布局参数做特殊处理
        if itemData.fields?.title?.isEmpty ?? false {
            imgWidth = 50
            defaultLabelH = 0
        }
        if itemData.styles?.tabBarStyle == 1 {
            imgTop = -20
            imgWidth = 50
        }
        let imgLeft: CGFloat = (frame.size.width - imgWidth) / 2
        let imgHeight: CGFloat = frame.size.height - defaultLabelH - imgTop
        //创建图片
        imgView = UIImageView().then({
            $0.frame = CGRect(x: imgLeft, y: imgTop, width: imgWidth, height: imgHeight)
            //没被选中
            $0.image = UIImage.getImage(in: SandboxTool.getFilePath(of: "tabBar_icon_\(itemIndex + 1)@2x.png", in: .applicationSupport, subPathStr: "com.one2much.app\(appID)"))
            $0.contentMode = UIViewContentMode.scaleAspectFit
        })

        //创建title
        titleLabel = UILabel().then({
            $0.frame = CGRect(x: 0, y: frame.height - defaultLabelH, width: frame.size.width, height: defaultLabelH)
            $0.text = itemData.fields?.title
            $0.textAlignment = NSTextAlignment.center
            $0.font = UIFont.systemFont(ofSize: itemData.styles?.fontSize ?? 14)
            $0.textColor = itemData.styles?.color?.toColor() ?? .white
        })

        super.init(frame: frame)
        self.addSubview(imgView)
        self.addSubview(titleLabel)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        longPressGesture.minimumPressDuration = 3.5
        self.addGestureRecognizer(longPressGesture)
    }

    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            SuspensionUtil.shared.showSuspensionButton(show: true)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
