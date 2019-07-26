//
//  String+Encrypt.swift
//  UIMaster
//
//  Created by hobson on 2018/11/9.
//  Copyright © 2018 one2much. All rights reserved.
//

import Foundation

extension String {
    func getSHA1() -> String? {
        //UnsafeRawPointer
        let data = self.data(using: String.Encoding.utf8)!
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))

        let newData = NSData(data: data)
        CC_SHA1(newData.bytes, CC_LONG(data.count), &digest)
        let output = NSMutableString(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        for byte in digest {
            output.appendFormat("%02x", byte)
        }
        return output as String
    }

    func getMD5() -> String? {
        let cStr = self.cString(using: String.Encoding.utf8)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(cStr!, (CC_LONG)(strlen(cStr!)), buffer)
        let md5String = NSMutableString()
        for idx in 0 ..< 16 {
            md5String.appendFormat("%02x", buffer[idx])
        }
        free(buffer)
        return md5String as String
    }
}
