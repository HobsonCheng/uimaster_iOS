//
//  String+Chat.swift
//  UIMaster
//
//  Created by hobson on 2018/10/11.
//  Copyright © 2018 one2much. All rights reserved.
//

import Foundation

extension String {
    var rc4EncodeStr: String {
        guard let key = getUserDefaults(key: kRC4Key) as? String, key != "" else {
            HUDUtil.msg(msg: "解密key为空", type: .error)
            return ""
        }
        return RC4Tool.encryptRC4(with: self, key: key)
    }
    var rc4DecodeStr: String {
        guard let key = getUserDefaults(key: kRC4Key) as? String, key != "" else {
            HUDUtil.msg(msg: "解密key为空", type: .error)
            return ""
        }
        return RC4Tool.decryptRC4(with: self, key: key)
    }
//    var base64Encode
    var base64EncodeStr: String {
        let data = self.data(using: String.Encoding.utf8)
        let str = data?.base64EncodedString()
        return str ?? ""
    }
    var base64DecodeStr: String {
        let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) ?? Data()
        let str = String(data: data, encoding: String.Encoding.utf8)
        return str ?? ""
    }
}
