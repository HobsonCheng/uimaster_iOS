//
//  YJDocument.swift
//  UIMaster
//
//  Created by hobson on 2018/10/29.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit

class YJDocument: UIDocument {
    var data: NSData?
    var imgData: NSData?

    //处理文件上传
    override func contents(forType typeName: String) throws -> Any {
        if typeName == "public.png" {
            return imgData ?? NSData()
        } else {
            return Data()
        }
    }

    //处理文件下载
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let userContent = contents as? NSData {
            data = userContent
        }
    }
}
