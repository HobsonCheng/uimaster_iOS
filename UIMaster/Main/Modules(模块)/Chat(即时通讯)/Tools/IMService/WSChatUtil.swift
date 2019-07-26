////
////  WSChatUtil.swift
////  UIMaster
////
////  Created by hobson on 2019/1/5.
////  Copyright © 2019 one2much. All rights reserved.
////
//
//import Foundation
//import Starscream
//import SwiftyJSON
//
//fileprivate struct WSLoginModel{
//    var token: String
//    var deviceName: String
//    var deviceID: String
//    var client: Int
//}
//fileprivate struct WSRequest{
//    var type: Int
//    var value: String
//    var no: Int
//    var ver: Int
//    var flag: Int
//}
//class WSChatUtil{
//    let login = 1000
//    let loginError = 1001
//    let no = 1
//    let flag = 0
//    let ver = 0
//    let client = 2
//    let hear = 99
//    let receiveHear = 199
//    let error = 2000
//    let notice = 2001
//    let sendNotice = 2002
//    /// 长连webSocket
//    fileprivate lazy var webSocket: WebSocket? = {
//        guard let url = URL(string: "ws://im.uidashi.com/mc") else {
//            HUDUtil.debugMsg(msg: "长连host有误", type: .error)
//            return nil
//        }
//        return WebSocket.init(url: url)
//    }()
//}
//extension WSChatUtil{
//    fileprivate func send(msg:String){
//        
//    }
//}
//extension WSChatUtil: WebSocketDelegate{
//    func websocketDidConnect(socket: WebSocketClient) {
//        dPrint("长连成功")
//    }
//    
//    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
//        dPrint("长连失败")
//    }
//    
//    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
//        dPrint("长连收到消息")
//    }
//    
//    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
//        dPrint("长连收到数据")
//    }
//    
//    
//}
