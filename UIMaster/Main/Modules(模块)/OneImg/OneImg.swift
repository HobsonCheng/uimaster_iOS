//
//  OneImg.swift
//  UIDS
//
//  Created by one2much on 2018/1/10.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

//class OneImgMode: ConfigModel {
//    var imgList: [PageInfo]?
//
//}
class OneImgConfigModel: BaseData {
    var styles: OneImgStyle?
    var fields: OneImgFields?
}
class OneImgFields: BaseData {
    var image: String?
}
class OneImgStyle: BaseStyleModel {
}

class OneImg: UIView, PageModuleAble {
    weak var moduleDelegate: ModuleRefreshDelegate?
    private var imageStr = ""
    private var radius: CGFloat = 0

    var imgView: UIImageView?
    var styleDic: [String: Any]? {
        didSet {
            if let model = OneImgConfigModel.deserialize(from: styleDic) {
                self.backgroundColor = model.styles?.bgColor?.toColor() ?? .clear
                if self.imgView == nil {
                    genderView()
                }
                self.imageStr = model.fields?.image ?? ""
                self.radius = model.styles?.radius ?? 0
            }
        }
    }

//    override var model: BaseData?{
//        didSet{
//            if let model = model as? OneImgConfigModel{
//                self.backgroundColor = model.styles?.bgColor?.toColor() ?? .clear
//                self.imgView?.sd_setImage(with: URL.init(string: model.fields?.image ?? ""), completed: nil)
//            }
//
//        }
//    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.genderView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: 创建页面
    private func genderView() {
        self.imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height))
        self.addSubview(self.imgView!)
        self.imgView?.contentMode = .scaleAspectFill
        self.imgView?.layer.cornerRadius = self.radius
        self.imgView?.layer.masksToBounds = true
        imgView?.snp.makeConstraints({ make in
            make.edges.equalTo(self)
        })
        self.imgView?.kf.setImage(with: URL(string: imageStr))
    }

//    public func setUrl(url: NSString){
//        if url.hasPrefix("http") {
//            self.imgView?.sd_setImage(with: URL(string: url as String))
//        }else{
//            if let image = UIImage.init(named: url as String) {
//                self.imgView?.image = image
//            }else{
//                self.imgView?.image = UIImage.init(contentsOfFile: url as String)
//            }
//        }
//    }
}
