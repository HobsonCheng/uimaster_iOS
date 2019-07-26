//
//  CommentModel.swift
//  UIMaster
//
//  Created by hobson on 2018/8/3.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Foundation

class CommentModel: BaseData {
    var events: [String: EventsData]?
    var fields: CommentFields?
    var styles: CommentStyles?
}
class CommentData: BaseModel {
    var comment: String?
    var replies: [Dictionary<String, String>]?
}
class CommentFields: BaseData {
    var more: Int?
    var replyButton: Int?
    var transmitButton: Int?
    var likeButton: Int?
    var limit: Int?
}
class CommentStyles: BaseStyleModel {
    var borderWidth: Int?
    var branchesNumber: Int?
    var opacity: Int?
    var splitterType: String?
    var bgColorReply: String?
    var bgImgReply: String??
    var bgImgModeReply: Int?
    var borderShow: Int?
    var opacityReply: Int?
    var replyStyle: Int?
    var splitterWidth: Int?
    var splitterColor: String?
    var borderColor: String?
    var commentStyle: Int?
}
