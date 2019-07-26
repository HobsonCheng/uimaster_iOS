import Foundation

class RC4Tool {
    /// RC4加密
    ///
    /// - Parameters:
    ///   - content: 加密内容
    ///   - key: 加密key
    /// - Returns: 加密后的结果
    static func encryptRC4(with content: String?, key: String) -> String {
        guard let safeContent = content else {
            return ""
        }
        let secretData: [UInt8] = Array(safeContent.utf8)
        let keyData: [UInt8] = Array(key.utf8)
        let messageLen = secretData.count
        var longData: [UInt8] = [UInt8](repeating: 0, count: messageLen)

        for idx in 0..<messageLen {
            longData[idx] = secretData[idx % secretData.count]
        }
        //加密
        var enCry = RC4.shared
        enCry.initialize(keyData)
        enCry.encrypt(&longData)

        let str = Data(bytes: longData).base64EncodedString()
        return str
    }
    /// RC4解密
    ///
    /// - Parameter key: RC4加密key
    /// - Returns: 解密后的结果
    static func decryptRC4(with content: String, key: String) -> String {
        let keyData: [UInt8] = Array(key.utf8)
        let encrptData = Data(base64Encoded: content, options: .ignoreUnknownCharacters)
        guard let safeData = encrptData else {
            return ""
        }
        var encrptArray = Array(safeData)
        var deCry = RC4.shared
        deCry.initialize(keyData)
        deCry.encrypt(&encrptArray)
        let originDate = Data(bytes: encrptArray)
        let str = String(data: originDate, encoding: .utf8)
        return str ?? ""
    }
}

struct RC4 {
    static let shared = RC4()

    var state: [UInt8]
    var uintOne: UInt8 = 0
    var uintTwo: UInt8 = 0

    private init() {
        state = [UInt8](repeating: 0, count: 256)
    }

    mutating
    func initialize(_ key: [UInt8]) {
        for index in 0..<256 {
            state[index] = UInt8(index)
        }

        var temp: UInt8 = 0
        for index in 0..<256 {
            let kTemp: UInt8 = key[index % key.count]
            let sTemp: UInt8 = state[index]
            temp = temp &+ sTemp &+ kTemp
            swapByIndex(index, y: Int(temp))
        }
    }

    mutating
    func swapByIndex(_ x: Int, y: Int) {
        let stateFirst: UInt8 = state[x]
        let stateSecond: UInt8 = state[y]
        state[x] = stateSecond
        state[y] = stateFirst
    }

    mutating
    func next() -> UInt8 {
        uintOne = uintOne &+ 1
        uintTwo = uintTwo &+ state[Int(uintOne)]
        swapByIndex(Int(uintOne), y: Int(uintTwo))
        return state[Int(state[Int(uintOne)] &+ state[Int(uintTwo)]) & 0xFF]
    }

    mutating
    func encrypt(_ data: inout [UInt8]) {
        let cnt = data.count
        for idx in 0..<cnt {
            data[idx] = data[idx] ^ next()
        }
    }
}
