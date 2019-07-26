//
//  Dsbridge.swift
//  UIMaster
//
//  Created by 希德梅尔 on 2019/7/11.
//  Copyright © 2019 one2much. All rights reserved.
//

import Foundation

typealias JSCallback = (String, Bool) -> Void

class ArticleDetailBridgeApi: NSObject {
    weak var delegate: ArticleDetails?
    
    @objc func showImage(_ arg: [String:Int]) {
        delegate?.showImage(data: arg)
    }

    @objc func gotoPersonalCenter( _ arg: String) {
        delegate?.gotoPC()
    }
}
