////
////  WSUtil.swift
////  UIDS
////
////  Created by one2much on 2018/1/25.
////  Copyright © 2018年 one2much. All rights reserved.
////
//
//import UIKit
//import Starscream
//
//import SwiftProtobuf
//
//class NoticObj {
//
//    init() {}
//
//    var id: Int!
//    var pid: Int!
//    var uid: Int!
//    var notifyId: Int!
//    var targetGroup: Int!
//    var target: Int!
//    var targetType: Int!
//    var read: Bool!
//    var content: String!
//    var addTime: String!
//
//}
//
//protocol WSUtilDelegate: class {
//
//    /**websocket 连接成功*/
//    func websocketDidConnect(sock: WSUtil)
//    /**websocket 连接失败*/
//    func websocketDidDisconnect(socket: WSUtil, error: NSError?)
//    /**websocket 接受文字信息*/
//    func websocketDidReceiveMessage(socket: WSUtil, text: String)
//    /**websocket 接受二进制信息*/
//    func  websocketDidReceiveData(socket: WSUtil, data: NSData)
//    /**返回 订单信息*/
//    func  callBackOrderStaus(order: NoticObj?, cancel: Bool)
//
//}
//
//class WSUtil {
//
//    weak var delegate: WSUtilDelegate?
//
//    private var socket: WebSocket!
//    // MARK: - 单利创建
//    static let manger: WSUtil = {
//        return WSUtil()
//    }()
//
//    class func share() -> WSUtil {
//        return manger
//    }
//
//    let wsUrl = "ws://121.42.154.36:12131/socket"
//
//    //创建链接
//    func connectSever() {
//
//        self.socket = WebSocket(url: URL(string: wsUrl)!)
//        socket.delegate = self
//        socket.connect()
//    }
//
//    //发送信息
//    func sendProtoObj(data: Data) {
//        self.socket.write(data: data)
//    }
//
//    //断开链接
//    func disconnect() {
//        self.socket.disconnect()
//    }
//}
//
////open api
//extension WSUtil {
//
//    private func convertData<T: SwiftProtobuf.Message>(data: Data) -> T {
//        return try! T(serializedData: data)
//    }
//
//    func SnoticeModel(buf: Data, cancel: Bool) {
//        let snoticeModel = try?ProtosBody_user_notice(serializedData: buf)
//        if snoticeModel == nil {
//            return
//        }
//
//        let getModel = NoticObj()
//        getModel.id = snoticeModel?.id.hashValue
//        getModel.pid = snoticeModel?.pid.hashValue
//        getModel.uid = snoticeModel?.uid.hashValue
//        getModel.notifyId = snoticeModel?.notifyID.hashValue
//        getModel.targetGroup = snoticeModel?.targetGroup.hashValue
//        getModel.target = snoticeModel?.target.hashValue
//        getModel.targetType = snoticeModel?.targetType.hashValue
//        getModel.read = snoticeModel?.read
//        getModel.content = snoticeModel?.content
//        getModel.addTime = snoticeModel?.addTime
//
//        self.delegate?.callBackOrderStaus(order: getModel, cancel: cancel)
//    }
//
//    func getCReust(modelInfo: Int32) -> Data {
//        var cReust = ProtosBody_RESULT()
//        cReust.id = modelInfo
//        cReust.result = true
//        return try!cReust.serializedData(partial: true)
//    }
//
//    func SLoginModel(modelInfo: Data) {
//        let slogin = try!ProtosBody_RESULT(serializedData: modelInfo)
//        dPrint(slogin)
//    }
//
//    open func getLoginBuff() -> Data {
//        var cLogin = ProtosBody_Login()
//        let userinfo = UserUtil.share.appUserInfo
//        if userinfo != nil {
//            cLogin.pid = Int32.init(truncatingIfNeeded: (userinfo?.pid)!)
//            cLogin.uid = Int32.init(truncatingIfNeeded: (userinfo?.uid)!)
//            if let safeKey = getUserDefaults(key: kAuthorization) as? String{
//                 cLogin.token = safeKey
//            }
//
//
//            return try!cLogin.serializedData(partial: true)
//        } else {
//            return Data()
//        }
//    }
//
//    open func sendWSMsg(functype: ProtosBody_notice_funtion?, model: Any?) {
//
//        var binary = Data()
//        switch functype?.rawValue {
//        case ProtosBody_notice_funtion.cregister.rawValue?:
//            binary = self.getLoginBuff()
//            break
//        case ProtosBody_notice_funtion.sregister.rawValue?:
//
//            break
//        case ProtosBody_notice_funtion.snotice.rawValue?:
//
//            break
//        case ProtosBody_notice_funtion.cnotice.rawValue?:
//            binary = self.getCReust(modelInfo: model as! Int32)
//            break
//        case ProtosBody_notice_funtion.scancel.rawValue?:
//
//            break
//        case ProtosBody_notice_funtion.ccancel.rawValue?:
//
//            break
//        default:
//            break
//        }
//
//        let headData = Data.init(bytes: [0x1, 0x2, 0x3, 0x4])
//        let glData = Data.init(bytes: [0x1])
//        let funtionData = Data.init(bytes: (self.intToBytes(value: (functype?.rawValue)!)))
//        let funtionLengthData = Data.init(bytes: (self.intToBytes(value: (binary.count))))
//
//        let sendData = headData+glData+funtionData+funtionLengthData+binary
//
//        self.sendProtoObj(data: sendData)
//    }
//
//    func intToBytes(value: Int) -> [UInt8] {
//
//        var bytes = [UInt8]()
//        bytes.append((UInt8((value>>24) & 0xFF)))
//        bytes.append(UInt8((value>>16) & 0xFF))
//        bytes.append(UInt8((value>>8) & 0xFF))
//        bytes.append(UInt8((value) & 0xFF))
//
//        return bytes
//    }
//    func BytesToInt(bytes: [UInt8]) -> Int {
//
//        var value: Int
//        let offset = 0
//
//        let bytes1 = (bytes[offset] & 0xFF)<<24
//        let bytes2 = (bytes[offset+1] & 0xFF)<<16
//        let bytes3 = (bytes[offset+2] & 0xFF)<<8
//        let bytes4 = (bytes[offset+3] & 0xFF)
//
//        value = Int(bytes1|bytes2|bytes3|bytes4)
//
//        return value
//    }
//
//    func getMsg(evt: Data) {
//
//        //xxxx x xxxx xxxx ---
//        let start = 5
//        let modelData = 13
//        let funtionTypeData = NSData.init(data: evt).subdata(with: NSRange.init(location: start, length: 4))
//        let funtionType = self.BytesToInt(bytes: [UInt8](funtionTypeData))
//
//        let tmpdata = NSData.init(data: evt)
//        let modelInfo = tmpdata.subdata(with: NSRange.init(location: modelData, length: tmpdata.length - modelData))
//
//        switch funtionType {
//        case ProtosBody_notice_funtion.cregister.rawValue:
//
//            break
//        case ProtosBody_notice_funtion.sregister.rawValue:
//            self.SLoginModel(modelInfo: modelInfo)
//            break
//        case ProtosBody_notice_funtion.snotice.rawValue:
//            self.SnoticeModel(buf: modelInfo, cancel: false)
//            break
//        case ProtosBody_notice_funtion.cnotice.rawValue:
//
//            break
//        case ProtosBody_notice_funtion.scancel.rawValue:
//            self.SnoticeModel(buf: modelInfo, cancel: true)
//            break
//        case ProtosBody_notice_funtion.ccancel.rawValue:
//
//            break
//        default:
//            break
//        }
//    }
//}
//
////socket 协议代理
//extension WSUtil: WebSocketDelegate {
//
//    //连接成功了
//    func websocketDidConnect(socket: WebSocketClient) {
//        dPrint("成功链接")
//        self.sendWSMsg(functype: ProtosBody_notice_funtion.cregister, model: nil)
//        delegate?.websocketDidConnect(sock: self)
//    }
//    //连接失败了
//    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
//        dPrint("断开链接")
////        delegate?.websocketDidDisconnect(socket: self, error: error! as NSError)
//    }
//
//    //接受到消息了
//    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
//        dPrint("我收到了消息(string)\(text)")
//
//        delegate?.websocketDidReceiveMessage(socket: self, text: text)
//    }
//    //data数据
//    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
//        dPrint("我收到了消息(data)\(data)")
//        self.getMsg(evt: data)
//        delegate?.websocketDidReceiveData(socket: self, data: data as NSData)
//    }
//
//}
