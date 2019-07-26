//
//  MD5Tool.swift
//  UIMaster
//
//  Created by hobson on 2018/11/9.
//  Copyright © 2018 one2much. All rights reserved.
//

import Foundation

extension String {
    var MD5Str: String {
        if let data = data(using: .utf8) {
            let message = data.withUnsafeBytes { bytes -> [UInt8] in
                Array(UnsafeBufferPointer(start: bytes, count: data.count))
            }

            let MD5Calculator = MD5(message)
            let MD5Data = MD5Calculator.calculate()

            let MD5String = NSMutableString()
            for ch in MD5Data {
                MD5String.appendFormat("%02x", ch)
            }
            return MD5String as String
        } else {
            return self
        }
    }

    var sha256Str: String {
        if let stringData = self.data(using: .utf8) {
            return hexStringFromData(input: digest(input: stringData as NSData))
        }
        return ""
    }

    func toDate(formatter: String) -> Date {
        let fmt = DateFormatter()
        fmt.dateFormat = formatter
        let date = fmt.date(from: self)
        return date ?? Date()
    }
    /// 是否包含特殊文字
    ///
    /// - Returns: 是否包含特殊文字除了汉字和字母数字
    func isSpecialCharactor() -> Bool {
        let pattern = "[^\\w\\d]"
        let regular = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let results = regular?.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
        if !(results?.isEmpty ?? true) { return true }
        return false
    }

    /// 去除空格
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespaces)
    }
}

private func digest(input: NSData) -> NSData {
    let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
    var hash = [UInt8](repeating: 0, count: digestLength)
    CC_SHA256(input.bytes, UInt32(input.length), &hash)
    return NSData(bytes: hash, length: digestLength)
}

private  func hexStringFromData(input: NSData) -> String {
    var bytes = [UInt8](repeating: 0, count: input.length)
    input.getBytes(&bytes, length: input.length)

    var hexString = ""
    for byte in bytes {
        hexString += String(format: "%02x", UInt8(byte))
    }

    return hexString
}

/** array of bytes, little-endian representation */
func arrayOfBytes<T>(_ value: T, length: Int? = nil) -> [UInt8] {
    let totalBytes = length ?? (MemoryLayout<T>.size * 8)

    let valuePointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    valuePointer.pointee = value

    let bytes = valuePointer.withMemoryRebound(to: UInt8.self, capacity: totalBytes) { bytesPointer -> [UInt8] in
        var bytes = [UInt8](repeating: 0, count: totalBytes)
        for index in 0..<min(MemoryLayout<T>.size, totalBytes) {
            bytes[totalBytes - 1 - index] = (bytesPointer + index).pointee
        }
        return bytes
    }

    #if swift(>=4.1)
    valuePointer.deinitialize(count: 1)
    valuePointer.deallocate()
    #else
    valuePointer.deinitialize()
    valuePointer.deallocate(capacity: 1)
    #endif

    return bytes
}

extension Int {
    /** Array of bytes with optional padding (little-endian) */
    func bytes(_ totalBytes: Int = MemoryLayout<Int>.size) -> [UInt8] {
        return arrayOfBytes(self, length: totalBytes)
    }
}

protocol HashProtocol {
    var message: [UInt8] { get }

    /** Common part for hash calculation. Prepare header data. */
    func prepare(_ len: Int) -> [UInt8]
}

extension HashProtocol {
    func prepare(_ len: Int) -> [UInt8] {
        var tmpMessage = message

        // Step 1. Append Padding Bits
        tmpMessage.append(0x80) // append one bit (UInt8 with one bit) to message

        // append "0" bit until message length in bits ≡ 448 (mod 512)
        var msgLength = tmpMessage.count
        var counter = 0

        while msgLength % len != (len - 8) {
            counter += 1
            msgLength += 1
        }

        tmpMessage += [UInt8](repeating: 0, count: counter)
        return tmpMessage
    }
}

func toUInt32Array(_ slice: ArraySlice<UInt8>) -> Array<UInt32> {
    var result = Array<UInt32>()
    result.reserveCapacity(16)

    for idx in stride(from: slice.startIndex, to: slice.endIndex, by: MemoryLayout<UInt32>.size) {
        let d0 = UInt32(slice[idx.advanced(by: 3)]) << 24
        let d1 = UInt32(slice[idx.advanced(by: 2)]) << 16
        let d2 = UInt32(slice[idx.advanced(by: 1)]) << 8
        let d3 = UInt32(slice[idx])
        let val: UInt32 = d0 | d1 | d2 | d3

        result.append(val)
    }
    return result
}

struct BytesIterator: IteratorProtocol {
    let chunkSize: Int
    let data: [UInt8]

    init(chunkSize: Int, data: [UInt8]) {
        self.chunkSize = chunkSize
        self.data = data
    }

    var offset = 0

    mutating func next() -> ArraySlice<UInt8>? {
        let end = min(chunkSize, data.count - offset)
        let result = data[offset..<offset + end]
        offset += result.count
        return !result.isEmpty ? result : nil
    }
}

struct BytesSequence: Sequence {
    let chunkSize: Int
    let data: [UInt8]

    func makeIterator() -> BytesIterator {
        return BytesIterator(chunkSize: chunkSize, data: data)
    }
}

func rotateLeft(_ value: UInt32, bits: UInt32) -> UInt32 {
    return ((value << bits) & 0xFFFFFFFF) | (value >> (32 - bits))
}

class MD5: HashProtocol {
    static let size = 16 // 128 / 8
    let message: [UInt8]

    init (_ message: [UInt8]) {
        self.message = message
    }

    /** specifies the per-round shift amounts */
    private let shifts: [UInt32] = [7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
                                    5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
                                    4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
                                    6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21]

    /** binary integer part of the sines of integers (Radians) */
    private let sines: [UInt32] = [0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
                                   0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
                                   0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
                                   0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
                                   0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
                                   0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
                                   0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
                                   0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
                                   0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
                                   0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
                                   0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x4881d05,
                                   0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
                                   0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
                                   0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
                                   0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
                                   0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391]

    private let hashes: [UInt32] = [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476]

    func calculate() -> [UInt8] {
        var tmpMessage = prepare(64)
        tmpMessage.reserveCapacity(tmpMessage.count + 4)
        // hash values
        var value1 = hashes
        // Step 2. Append Length a 64-bit representation of lengthInBits
        let lengthInBits = (message.count * 8)
        let lengthBytes = lengthInBits.bytes(64 / 8)
        tmpMessage += lengthBytes.reversed()

        // Process the message in successive 512-bit chunks:
        let chunkSizeBytes = 512 / 8 // 64

        for chunk in BytesSequence(chunkSize: chunkSizeBytes, data: tmpMessage) {
            // break chunk into sixteen 32-bit words M[j], 0 ≤ j ≤ 15
            var value0 = toUInt32Array(chunk)
            assert(value0.count == 16, "Invalid array")

            // Initialize hash value for this chunk:
            var value2: UInt32 = value1[0]
            var value3: UInt32 = value1[1]
            var value4: UInt32 = value1[2]
            var value5: UInt32 = value1[3]

            var dTemp: UInt32 = 0

            // Main loop
            for value6 in 0 ..< sines.count {
                var value7 = 0
                var value8: UInt32 = 0

                switch value6 {
                case 0...15:
                    value8 = (value3 & value4) | ((~value3) & value5)
                    value7 = value6
                case 16...31:
                    value8 = (value5 & value3) | (~value5 & value4)
                    value7 = (5 * value6 + 1) % 16
                case 32...47:
                    value8 = value3 ^ value4 ^ value5
                    value7 = (3 * value6 + 5) % 16
                case 48...63:
                    value8 = value4 ^ (value3 | (~value5))
                    value7 = (7 * value6) % 16
                default:
                    break
                }
                dTemp = value5
                value5 = value4
                value4 = value3
                value3 = value3 &+ rotateLeft((value2 &+ value8 &+ sines[value6] &+ value0[value7]), bits: shifts[value6])
                value2 = dTemp
            }

            value1[0] = value1[0] &+ value2
            value1[1] = value1[1] &+ value3
            value1[2] = value1[2] &+ value4
            value1[3] = value1[3] &+ value5
        }

        var result = [UInt8]()
        result.reserveCapacity(value1.count / 4)

        value1.forEach {
            let itemLE = $0.littleEndian
            result += [UInt8(itemLE & 0xff), UInt8((itemLE >> 8) & 0xff), UInt8((itemLE >> 16) & 0xff), UInt8((itemLE >> 24) & 0xff)]
        }
        return result
    }
}
