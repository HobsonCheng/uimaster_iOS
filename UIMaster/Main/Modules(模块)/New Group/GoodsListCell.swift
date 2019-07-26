//
//  GoodsListCell.swift
//  UIMaster
//
//  Created by 希德梅尔 on 2019/7/16.
//  Copyright © 2019 one2much. All rights reserved.
//

import UIKit

class GoodsListCell: UICollectionViewCell {
    weak var moduleDelegate: ModuleRefreshDelegate?

    private var goodsIcon: UIImageView? //商品图片
    private var goodsName: UILabel? //商品名称
    private var goodsBeforePrice: UILabel? //商品之前的价格
    private var goodsCurrentPrice: UILabel? //商品现在的价格
    private var goodsbuyNum: UILabel? //购买的数量

    override init(frame: CGRect) {
        super.init(frame: frame)

        goodsIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: self.width, height: 175))
        goodsIcon?.layer.masksToBounds = true

        goodsName = UILabel(frame: CGRect(x: 0, y: goodsIcon?.bottom ?? 0, width: self.frame.width, height: 50))
        goodsName?.textAlignment = NSTextAlignment.center
        goodsName?.numberOfLines = 0
        goodsName?.font = UIFont.systemFont(ofSize: 17)

        goodsCurrentPrice = UILabel(frame: CGRect(x: 0, y: goodsName?.bottom ?? 0, width: self.frame.width / 2, height: 25))
        goodsCurrentPrice?.textAlignment = NSTextAlignment.center
        goodsCurrentPrice?.font = UIFont.systemFont(ofSize: 17)
        goodsCurrentPrice?.textColor = UIColor.red

        goodsbuyNum = UILabel(frame: CGRect(x: self.frame.width / 2, y: goodsName?.bottom ?? 0, width: self.frame.width / 2, height: 25))
        goodsbuyNum?.textAlignment = NSTextAlignment.center
        goodsbuyNum?.font = UIFont.systemFont(ofSize: 12)
        goodsbuyNum?.textColor = UIColor(hexString: "#777777")

        self.addSubview(goodsIcon!)
        self.addSubview(goodsName!)
        self.addSubview(goodsCurrentPrice!)
        self.addSubview(goodsbuyNum!)
    }
    func rederGoodsCell(cellStyle: [String: String]){
//        goodsIcon?.image = cellStyle["normalIcon"]
        goodsName?.text = cellStyle["title"]
        goodsCurrentPrice?.text =  cellStyle["price"]
        goodsbuyNum?.text = cellStyle["time"]
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
