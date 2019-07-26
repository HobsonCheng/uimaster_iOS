//
//  InformationFlowModel.swift
//  UIMaster
//
//  Created by hobson on 2018/7/24.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit
// swiftlint:disable identifier_name
//数据源
class InformationFlowDataModel: BaseModel {
    var data: [InformationFlowData]!
}
class InformationFlowData: BaseData {
    var pid: Int?
    var feed_type: Int?
    var object: [String: Any]?
    var message_time: String?
}
//样式
class InformationFlowModel: BaseData {
    var fields: InformationFlowFields?
    var styles: InformationFlowStyles?
    var events: [String: EventsData]?
}
class InformationFlowFields: BaseData {
    var forward: Int?
    var groupListAdminMessage: Int?
    var messageListAdminHead: Int?
    var groupListGroupHead: Int?
    var groupListOptionsMenu: Int?
    var articlesListAdminHead: Int?
    var articlesListTime: Int?
    var messageListReplyButton: Int?
    var messageListTime: Int?
    var adminMessageArticlesList: Int?
    var groupListAdminHead: Int?
    var groupListAdminNickName: Int?
    var browsingVolume: Int?
    var groupListAbstract: Int?
    var like: Int?
    var optionsMenuArticlesList: Int?
    var messageListAdminNickName: Int?
    var articlesListAdminNickName: Int?
    var articlesListKind: Int?
    var groupListOtherText: Int?
    var messageListTitle: Int?
    var articlesListAbstract: Int?
    var groupListGroupNickName: Int?
    var groupListTime: Int?
    var articlesListOtherText: Int?
    var collection: Int?
    var comment: Int?
    var optionsMenu: Int?
    var saySomethingTitle: Int?
}
class InformationFlowStyles: BaseStyleModel {
    var opacityArticlesList: Int?
    var opacityMessageList: Int?
    var bgImgSaySomething: String?
    var bgImgSys: String?
    var borderShow: Int?
    var articlesList: Int?
    var bgImgMessageList: String?
    var opacitySaySomething: Int?
    var groupListStyle: Int?
    var lineHeight: Int?
    var opacitySys: Int?
    var optionsButtonStyle: Int?
    var saySomething: Int?
    var bgColorSys: String?
    var bgImgModeSaySomething: Int?
    var bgImgModeSys: Int?
    var bgImgModeArticlesList: Int?
    var bgColorMessageList: String?
    var Style: Int?
    var bgColorSaySomething: String?
    var borderColor: String?
    var borderWidth: Int?
    var iconTitle: String?
    var opacity: Int?
    var titleTitle: String?
    var bgColorArticlesList: String?
    var bgImgModeMessageList: Int?
    var bgImgArticlesList: String?
    var heightSpacing: CGFloat?
}
