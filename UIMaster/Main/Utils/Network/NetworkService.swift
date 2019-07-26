//
//  NetService.swift
//  UIMaster
//
//  Created by hobson on 2018/6/26.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Moya
import UIKit

/// 网络服务层
///
/// - getInitiatorByModel: 获取启动器
/// - addGroup: 添加群组
/// - getClassifyList: 获取话题分类
/// - findGlobal: 全局
// swiftlint:disable identifier_name
enum NetworkService {
    case getClassifyList(do_pid:Int64, parent:Int)
    case getRC4Key
    case setUserRemind(remind:Int)
    case getUserRemind

    case getDepartment(dept_id: Int)
    case getDepartmentListAll(parent_id: Int)
    case selectContact
    case addContact(json_string: String)
    case getApplyFriendList(page_index:Int, page_context:Int)

    //邀请 invitation
    case codeUse(code: String)
    case applyForCode(out_time:Int, can_use_num:Int, code_type:Int)

    // 即时通讯
    case addMessage(msg_type:Int, content:String, target_pid:Int64, send_time:String, session:Int64, file_name:String?, client_id:Int64, target:Int64, chat_type:Int)
    case getNewMessage(last_id:Int64)
    case addChatGroup(name:String, notice:String, icon:String, backgroup:String, nick_name_display:Int, join_type:Int, can_share:Int, banned:Int)
    case getChatGroup(group_id:Int64, group_pid:Int64)
    case selectGroupMemberList(group_id:Int64, group_pid:Int64)
    case updateGroupMember(nickname:String, nickname_display:Int, personnel_id:Int, message_free:Int, set_top:Int)
    case delChatGroup(group_id:Int64, group_pid:Int64)
    case selectChatGroupList
    case updateChatGroup(group_id:Int64, group_pid:Int64, name:String, icon:String, notice:String, background:String, nick_name_display:Int, join_type:Int, can_share:Int, banned:Int)
    case updateGroupMemberShields(shields:Int, group_id:Int64, personnel_id:Int)
    case updateGroupMemberAnExcuse(group_id:Int64, personnel_id:Int64, an_excuse:Int)
    case delGroupPersonnel(group_id:Int, group_pid:Int)
    case delGroupPersonnelByCreator(personnel_id:Int, group_id:Int, group_pid:Int)
    case getGroupInvitation(group_id:Int, group_pid:Int, out_day:Int, point_x:Int, point_y:Int)
    case addGroupMember(group_id:Int, group_pid:Int, creator:Int, nickname_display:Int)
    case getOfflineMessage
    case getKey(device_name:String, device_id:String, token:String, develop:Int)
    case confirmReceivedOffLineMessage(msg_ids:String)
    case confirmReceivedWaitMessage(msg_ids:String)
    case confirmReceivedOneMessage(msg_id:String)
    case selectInsertGroup //获取强插群组
    case confirmAndRemoveUnreadMessage(msg_ids:String)//确认收到了未读消息
    case addUnreadMessage(msg_id:String)//添加未读消息
    case selectWaitMessageByUid//获取待确认消息
    case findMessageByID(id:String)//通过通知id拉取消息

    // project
    case getInitiatorByModel(group_id: Int, page: String, code: String)
    case findGlobal(app_id:Int, group_id:Int, client:Int?, project_id:Int?)
    case findPageList(app_id:Int, group_id:Int, client:Int?, project_id:Int?)
    case getPageKeyList(is_adaptive:Int, app_id:Int, group_id:Int)
    case getGroupByModel(group_id:Int, page_index:Int, page_context:Int, code:String, page:String)
    case getHtmlByModel(group_id:Int, page:String, code:String)
    case getAppAbout
    case getArticleByModel(group_id:Int, page: String, code: String, page_index:Int, page_context:Int)
    case getSlideByModel(group_id: Int, page: String, code: String)
    case forceUpdateVersion(app_id:Int, version:String, app_version:String)
    case searchProject(page_index:Int, key:String, page_context:Int)

    // 用户 uc
    case upUserPassword(old_password:String, new_password:String)
    case allRestriction(pid:Int)
    case userRegist(username:String, password:String, zh_name:String, phone_num:String, phone_num_code:String, auth_code:String, code_key:String)
    case userLogin(username:String, password:String, code_key:String, auth_code:String)
    case userLoginByPhone(auth_code:String, phone_number:String)
    case retrievePassword(username:String, auth_code:String, password:String)
    case userLogout
    case getUserAgreement
    case getRegisterAgreement
    case getPhoneEmailAuthCode(auth_type:String, code_key:String, phone_Email_num:String)
    case authCodeKey
    case getAuthCode(auth_type:String, code_key:String)

    //个人中心
    case addBlackUser(black_uid:Int64, black_pid:Int64)
    case addFollower(follow_uid:Int64, follow_pid:Int64)
    case deleteFollower(follow_uid:Int64, follow_pid:Int64)
    case agreeFriend(friend_uid:Int64, friend_pid:Int64)
    case deleteFriend(friend_uid:Int64, friend_pid:Int64, answer:String)
    case addFriend(friend_uid:Int64, friend_pid:Int64, answer:String)
    case getMessagePool(page_context:Int, page_index:Int, user_id:Int64, user_pid:Int64)
    case getFollowerList(user_id:Int64, user_pid:Int64, page_context:Int, page_index:Int)
    case getFanList(user_id:Int64, user_pid:Int64, page_context:Int, page_index:Int)
    case getFriendList(user_id:Int64, user_pid:Int64, page_context:Int, page_index:Int)
    case getDepartmentList(parent_id:Int)
    case getRelationTypeList
    case getInfo(user_id:Int64, user_pid:Int64)
    case updateInfo(email:String, signature:String, birthday:String, gender:Int, zh_name:String, head_portrait:String)
    case getAuthority
    case updateAuthoritySet(friend_apply:Int, group_apply:Int, follow_apply:Int)

    //预约获客
    case cancelSubscribe(form_pid:Int, form_id:Int)
    case cancelOrderSubscribe(order_id:Int, form_pid:Int)
    case confirmSubscribe(order_id:Int)
    case orderSubscribe(order_id:Int, form_pid:Int)
    case getUserSubscribeList(status:String, page_index:Int, page_context:Int)
    case getUserFormList(status:String, page_index:Int, page_context:Int)

    //cms
    case addOpinion(content:String, title:String, attachment_value:String)
    case getCreatedInvitationListByUser(page_index:Int, page_context:Int)
    case getInvitationList(group_id:Int, group_pid:Int, page_index:Int, page_context:Int)
    case getMyGroupList(page_index:Int, page_context:Int)
    case getOtherGroupList(page_index:Int, page_context:Int, user_id:Int64, user_pid:Int64)
    case addGroup(classify_id: Int, name: String, index_pic:String, introduction: String)
    case addInvitation(title:String, summarize:String, content:String, attachment_value:String, group_pid:Int, group_id:Int, can_reply:String, can_replay:String, can_store:String, can_out:String, can_see_reply:String, use_signature:String, attechment:String, pay_type:String)
    case getGroup(group_pid:Int, group_id:Int)
    case getInvitation(group_invitation_id:Int, group_pid:Int)
    case getRepliesByInvitation(parent_pid:Int, parent_id:Int, group_pid:Int, group_invitation_id:Int, page_context:Int, page_index:Int)
    case delGroup(group_pid:Int, group_id:Int)
    case tipOffInvitation(reason:String, group_invitation_id:Int, group_pid:Int)
    case tipOffReply(reason:String, group_reply_id:Int, group_pid:Int)
    case addReply(content:String, group_invitation_id:Int, group_pid:Int, parent_id:Int)
    case applyGroup(group_id:Int, member_id:Int, group_pid:Int)
    case delInvitation(group_invitation_id:Int, group_pid:Int)
    case praiseInvitation(praise:Bool, group_invitation_id:Int, group_pid:Int)
    case praiseReply(praise:Bool, group_reply_id:Int, group_pid:Int)
    case getInvitationTopListByGroup(page_context:Int, page_index:Int, group_pid:Int, cms_group_id:Int)
    case updateGroup(invitation_authority:Int, name:String, introduction:String, group_pid:Int, group_id:Int, can_out:Int, reply_authority:Int, index_pic:String)
    case selectNoticeList
    case setUserOffline(device_id:String)
    // picsave
    case getImgUploadtoken(bucket_type:String)
    // mc
    case getUserNotifyListByUser(page_index:Int, page_context:Int)
    // goodsList
    case selectGoodsAppletList(pageIndex: Int, pageContext: Int, goodsName: String, sort: Int)
}

extension NetworkService: TargetType {
    var baseURL: URL {
        var urlStr = kBaseUrl ?? GlobalConfigTool.shared.global?.host ?? "m3.uidashi.com"
        if !(urlStr.hasPrefix("http://") || urlStr.hasPrefix("https://")) {
            urlStr = "http://" + urlStr
        }
        return URL(string: "\(urlStr)")!
    }

    var path: String {
        switch self {
        case .userLogin(code_key: _):
            return "/userLogin"
        case .userLoginByPhone(auth_code: _, phone_number: _):
            return "/userLoginByPhone"
        case .userLogout:
            return "/userLogout"
        default:
            return "/mt"
        }
    }
    var method: Moya.Method {
        return .post
    }

    var sampleData: Data {
        return "test".utf8Encoded
    }

    var task: Task {
        switch self {
        case let .getInitiatorByModel(group_id: group_id, page: page, code: code):
            return .requestParameters(parameters: ["ac": "getInitiatorByModel", "sn": "project", "model": "Slider", "group_id": group_id, "page": page, "code": code], encoding: URLEncoding.default)
        case let .addGroup(classify_id, name, index_pic, introduction):
            return .requestParameters(parameters: ["ac": "addGroup", "sn": "cms", "classify_id": classify_id, "has_sign_in": "1", "invitation_authority": "5", "reply_authority": "1", "replay_authority": "2", "attachment": "1", "name": name, "index_pic": index_pic, "introduction": introduction], encoding: URLEncoding.default)
        case let .getClassifyList(do_pid, parent):
            return .requestParameters(parameters: ["ac": "getClassifyList", "sn": "cms", "do_pid": do_pid, "parent": parent], encoding: URLEncoding.default)
        case let .findGlobal(app_id, group_id, _, project_id):
            return .requestParameters(parameters: ["ac": "findGlobal", "sn": "project", "app_id": app_id, "group_id": group_id, "client": "1", "project_id": project_id ?? 0], encoding: URLEncoding.default)
        case let .findPageList(app_id, group_id, _, project_id):
            return .requestParameters(parameters: ["ac": "findPageList", "sn": "project", "app_id": app_id, "group_id": group_id, "client": "1", "project_id": project_id ?? 0], encoding: URLEncoding.default)
        case .getRC4Key:
            return .requestParameters(parameters: ["ac": "getKey", "sn": "im"], encoding: URLEncoding.default)
        case let .addMessage(msg_type, content, target_pid, send_time, session, file_name, client_id, target, chat_type):
            return .requestParameters(parameters: ["ac": "addMessage", "sn": "im", "msg_type": msg_type, "content": content, "file_name": file_name ?? "", "target_pid": target_pid, "send_time": send_time, "session": session, "client_id": client_id, "target": target, "chat_type": chat_type], encoding: URLEncoding.default)
        case let .getNewMessage(last_id):
            return .requestParameters(parameters: ["ac": "getNewMessage", "sn": "im", "last_id": last_id], encoding: URLEncoding.default)
        case let .getDepartment(dept_id):
            return .requestParameters(parameters: ["ac": "getDepartment", "sn": "pc", "dept_id": dept_id], encoding: URLEncoding.default)
        case let .getDepartmentList(parent_id):
            return .requestParameters(parameters: ["ac": "getDepartmentList", "sn": "pc", "parent_id": parent_id], encoding: URLEncoding.default)
        case let .getDepartmentListAll(parent_id):
            return .requestParameters(parameters: ["ac": "getDepartmentListAll", "sn": "pc", "parent_id": parent_id], encoding: URLEncoding.default)
        case .selectContact:
            return .requestParameters(parameters: ["ac": "selectContact", "sn": "pc"], encoding: URLEncoding.default)
        case let .addContact(jsonStr):
            return .requestParameters(parameters: ["ac": "addContact", "sn": "pc", "json_string": jsonStr], encoding: URLEncoding.default)
        case let .getApplyFriendList(page_index, page_context):
            return .requestParameters(parameters: ["ac": "getApplyFriendList", "sn": "pc", "page_index": page_index, "page_context": page_context], encoding: URLEncoding.default)
        case let .addChatGroup(name, notice, icon, background, nick_name_display, join_type, can_share, banned):
            return .requestParameters(parameters: ["ac": "addChatGroup", "sn": "im", "name": name, "notice": notice, "icon": icon, "background": background, "nick_name_display": nick_name_display, "join_type": join_type, "can_share": can_share, "banned": banned], encoding: URLEncoding.default)
        case let .getChatGroup(group_id, group_pid):
            return .requestParameters(parameters: ["ac": "getChatGroup", "sn": "im", "group_id": group_id, "group_pid": group_pid], encoding: URLEncoding.default)
        case let .selectGroupMemberList(group_id, group_pid):
            return .requestParameters(parameters: ["ac": "selectGroupMemberList", "sn": "im", "group_id": group_id, "group_pid": group_pid], encoding: URLEncoding.default)
        case let .updateGroupMember(nickname, nickname_display, personnel_id, message_free, set_top):
            return .requestParameters(parameters: ["ac": "updateGroupMember", "sn": "im", "nickname": nickname, "nickname_display": nickname_display, "personnel_id": personnel_id, "message_free": message_free, "set_top": set_top], encoding: URLEncoding.default)
        case let .delChatGroup(group_id, group_pid):
            return .requestParameters(parameters: ["ac": "delChatGroup", "sn": "im", "group_id": group_id, "group_pid": group_pid], encoding: URLEncoding.default)
        case .selectChatGroupList:
            return .requestParameters(parameters: ["ac": "selectChatGroupList", "sn": "im"], encoding: URLEncoding.default)
        case let .updateChatGroup(group_id, group_pid, name, icon, notice, background, nick_name_display, join_type, can_share, banned):
            return .requestParameters(parameters: ["ac": "updateChatGroup", "sn": "im", "group_id": group_id, "group_pid": group_pid, "name": name, "icon": icon, "notice": notice, "background": background, "nick_name_display": nick_name_display, "join_type": join_type, "can_share": can_share, "banned": banned], encoding: URLEncoding.default)
        case let .updateGroupMemberShields(shields, group_id, personnel_id):
            return .requestParameters(parameters: ["ac": "updateGroupMemberShields", "sn": "im", "shields": shields, "group_id": group_id, "personnel_id": personnel_id], encoding: URLEncoding.default)
        case let .updateGroupMemberAnExcuse(group_id, personnel_id, an_excuse):
            return .requestParameters(parameters: ["ac": "updateGroupMemberAnExcuse", "sn": "im", "group_id": group_id, "personnel_id": personnel_id, "an_excuse": an_excuse], encoding: URLEncoding.default)
        case let .delGroupPersonnel(group_id, group_pid):
            return .requestParameters(parameters: ["ac": "delGroupPersonnel", "sn": "im", "group_id": group_id, "group_pid": group_pid], encoding: URLEncoding.default)
        case let .delGroupPersonnelByCreator(personnel_id, group_id, group_pid):
            return .requestParameters(parameters: ["ac": "delGroupPersonnelByCreator", "sn": "im", "personnel_id": personnel_id, "group_id": group_id, "group_pid": group_pid], encoding: URLEncoding.default)
        case let .getGroupInvitation(group_id, group_pid, out_day, point_x, point_y):
            return .requestParameters(parameters: ["ac": "getGroupInvitation", "sn": "im", "group_id": group_id, "group_pid": group_pid, "out_day": out_day, "point_x": point_x, "point_y": point_y], encoding: URLEncoding.default)
        case let .addGroupMember(group_id, group_pid, creator, nickname_display):
            return .requestParameters(parameters: ["ac": "addGroupMember", "sn": "im", "group_id": group_id, "group_pid": group_pid, "creator": creator, "nickname_display": nickname_display], encoding: URLEncoding.default)
        case let .codeUse(code):
            return .requestParameters(parameters: ["ac": "codeUse", "sn": "invitation", "code": code], encoding: URLEncoding.default)
        case let .addBlackUser(black_uid, black_pid):
            return .requestParameters(parameters: ["ac": "addBlackUser", "sn": "pc", "black_uid": black_uid, "black_pid": black_pid], encoding: URLEncoding.default)
        case let .addFollower(follow_uid, follow_pid):
            return .requestParameters(parameters: ["ac": "addFollower", "sn": "pc", "follow_uid": follow_uid, "follow_pid": follow_pid], encoding: URLEncoding.default)
        case let .deleteFollower(follow_uid, follow_pid):
            return .requestParameters(parameters: ["ac": "deleteFollower", "sn": "pc", "follow_uid": follow_uid, "follow_pid": follow_pid], encoding: URLEncoding.default)
        case let .agreeFriend(friend_uid, friend_pid):
            return .requestParameters(parameters: ["ac": "agreeFriend", "sn": "pc", "friend_uid": friend_uid, "friend_pid": friend_pid], encoding: URLEncoding.default)
        case let .deleteFriend(friend_uid, friend_pid, answer):
            return .requestParameters(parameters: ["ac": "deleteFriend", "sn": "pc", "friend_uid": friend_uid, "friend_pid": friend_pid, "answer": answer], encoding: URLEncoding.default)
        case let .addFriend(friend_uid, friend_pid, answer):
            return .requestParameters(parameters: ["ac": "addFriend", "sn": "pc", "friend_uid": friend_uid, "friend_pid": friend_pid, "answer": answer], encoding: URLEncoding.default)
        case let .getMessagePool(page_context, page_index, user_id, user_pid):
            return .requestParameters(parameters: ["ac": "getMessagePool", "sn": "pc", "page_context": page_context, "page_index": page_index, "user_id": user_id, "user_pid": user_pid], encoding: URLEncoding.default)
        case let .getFollowerList(user_id, user_pid, page_context, page_index):
            return .requestParameters(parameters: ["ac": "getFollowerList", "sn": "pc", "user_id": user_id, "user_pid": user_pid, "page_context": page_context, "page_index": page_index], encoding: URLEncoding.default)
        case let .getFanList(user_id, user_pid, page_context, page_index):
            return .requestParameters(parameters: ["ac": "getFanList", "sn": "pc", "user_id": user_id, "user_pid": user_pid, "page_context": page_context, "page_index": page_index], encoding: URLEncoding.default)
        case let .getFriendList(user_id, user_pid, page_context, page_index):
            return .requestParameters(parameters: ["ac": "getFriendList", "sn": "pc", "user_id": user_id, "user_pid": user_pid, "page_context": page_context, "page_index": page_index], encoding: URLEncoding.default)
        case .getRelationTypeList:
            return .requestParameters(parameters: ["ac": "getRelationTypeList", "sn": "pc"], encoding: URLEncoding.default)
        case let .getInfo(user_id, user_pid):
            return .requestParameters(parameters: ["ac": "getInfo", "sn": "pc", "user_id": user_id, "user_pid": user_pid], encoding: URLEncoding.default)
        case let .updateInfo(email, signature, birthday, gender, zh_name, head_portrait):
            return .requestParameters(parameters: ["ac": "updateInfo", "sn": "pc", "email": email, "signature": signature, "birthday": birthday, "gender": gender, "zh_name": zh_name, "head_portrait": head_portrait], encoding: URLEncoding.default)
        case .getAuthority:
            return .requestParameters(parameters: ["ac": "getAuthority", "sn": "pc"], encoding: URLEncoding.default)
        case let .updateAuthoritySet(friend_apply, group_apply, follow_apply):
            return .requestParameters(parameters: ["ac": "updateAuthoritySet", "sn": "pc", "friend_apply": friend_apply, "group_apply": group_apply, "follow_apply": follow_apply], encoding: URLEncoding.default)
        case let .cancelSubscribe(form_pid, form_id):
            return .requestParameters(parameters: ["ac": "cancelSubscribe", "sn": "subscribe", "form_pid": form_pid, "form_id": form_id], encoding: URLEncoding.default)
        case let .cancelOrderSubscribe(order_id, form_pid):
            return .requestParameters(parameters: ["ac": "cancelOrderSubscribe", "sn": "subscribe", "order_id": order_id, "form_pid": form_pid], encoding: URLEncoding.default)
        case let .confirmSubscribe(order_id):
            return .requestParameters(parameters: ["ac": "confirmSubscribe", "sn": "subscribe", "order_id": order_id], encoding: URLEncoding.default)
        case let .orderSubscribe(order_id, form_pid):
            return .requestParameters(parameters: ["ac": "orderSubscribe", "sn": "subscribe", "order_id": order_id, "form_pid": form_pid], encoding: URLEncoding.default)
        case let .getUserSubscribeList(status, page_index, page_context):
            return .requestParameters(parameters: ["ac": "getUserSubscribeList", "sn": "subscribe", "status": status, "page_index": page_index, "page_context": page_context], encoding: URLEncoding.default)
        case let .getUserFormList(status, page_index, page_context):
            return .requestParameters(parameters: ["ac": "getUserFormList", "sn": "subscribe", "status": status, "page_index": page_index, "page_context": page_context], encoding: URLEncoding.default)
        case let .getCreatedInvitationListByUser(page_index, page_context):
            return .requestParameters(parameters: ["ac": "getCreatedInvitationListByUser", "sn": "cms", "page_index": page_index, "page_context": page_context], encoding: URLEncoding.default)
        case let .getInvitationList(group_id, group_pid, page_index, page_context):
            return .requestParameters(parameters: ["ac": "getInvitationList", "sn": "cms", "group_id": group_id, "group_pid": group_pid, "page_index": page_index, "page_context": page_context], encoding: URLEncoding.default)
        case let .getMyGroupList(page_index, page_context):
            return .requestParameters(parameters: ["ac": "getMyGroupList", "sn": "cms", "page_index": page_index, "page_context": page_context], encoding: URLEncoding.default)
        case let .addInvitation(title, summarize, content, attachment_value, group_pid, group_id, can_reply, can_replay, can_store, can_out, can_see_reply, use_signature, attechment, pay_type):
            return .requestParameters(parameters: ["ac": "addInvitation", "sn": "cms", "title": title, "summarize": summarize, "content": content, "attachment_value": attachment_value, "group_pid": group_pid, "group_id": group_id, "can_reply": can_reply, "can_replay": can_replay, "can_store": can_store, "can_out": can_out, "can_see_reply": can_see_reply, "use_signature": use_signature, "attechment": attechment, "pay_type": pay_type], encoding: URLEncoding.default)
        case let .getGroup(group_pid, group_id):
            return .requestParameters(parameters: ["ac": "getGroup", "sn": "cms", "group_pid": group_pid, "group_id": group_id], encoding: URLEncoding.default)
        case let .getInvitation(group_invitation_id, group_pid):
            return .requestParameters(parameters: ["ac": "getInvitation", "sn": "cms", "group_invitation_id": group_invitation_id, "group_pid": group_pid], encoding: URLEncoding.default)
        case let .getRepliesByInvitation(parent_pid, parent_id, group_pid, group_invitation_id, page_context, page_index):
            return .requestParameters(parameters: ["ac": "getRepliesByInvitation", "sn": "cms", "parent_pid": parent_pid, "parent_id": parent_id, "group_pid": group_pid, "group_invitation_id": group_invitation_id, "page_context": page_context, "page_index": page_index], encoding: URLEncoding.default)
        case let .delGroup(group_pid, group_id):
            return .requestParameters(parameters: ["ac": "delGroup", "sn": "cms", "group_pid": group_pid, "group_id": group_id], encoding: URLEncoding.default)
        case let .tipOffInvitation(reason, group_invitation_id, group_pid):
            return .requestParameters(parameters: ["ac": "tipOffInvitation", "sn": "cms", "reason": reason, "group_invitation_id": group_invitation_id, "group_pid": group_pid], encoding: URLEncoding.default)
        case let .tipOffReply(reason, group_reply_id, group_pid):
            return .requestParameters(parameters: ["ac": "tipOffReply", "sn": "cms", "reason": reason, "group_reply_id": group_reply_id, "group_pid": group_pid], encoding: URLEncoding.default)
        case let .addReply(content, group_invitation_id, group_pid, parent_id):
            return .requestParameters(parameters: ["ac": "addReply", "sn": "cms", "content": content, "group_invitation_id": group_invitation_id, "group_pid": group_pid, "parent_id": parent_id], encoding: URLEncoding.default)
        case let .applyGroup(group_id, member_id, group_pid):
            return .requestParameters(parameters: ["ac": "applyGroup", "sn": "cms", "group_id": group_id, "member_id": member_id, "group_pid": group_pid], encoding: URLEncoding.default)
        case let .addOpinion(content, title, attachment_value):
            return .requestParameters(parameters: ["ac": "addOpinion", "sn": "cms", "content": content, "title": title, "attachment_value": attachment_value], encoding: URLEncoding.default)
        case let .delInvitation(group_invitation_id, group_pid):
            return .requestParameters(parameters: ["ac": "delInvitation", "sn": "cms", "group_invitation_id": group_invitation_id, "group_pid": group_pid], encoding: URLEncoding.default)
        case let .praiseInvitation(praise, group_invitation_id, group_pid):
            return .requestParameters(parameters: ["ac": "praiseInvitation", "sn": "cms", "praise": praise, "group_invitation_id": group_invitation_id, "group_pid": group_pid], encoding: URLEncoding.default)
        case let .praiseReply(praise, group_reply_id, group_pid):
            return .requestParameters(parameters: ["ac": "praiseReply", "sn": "cms", "praise": praise, "group_reply_id": group_reply_id, "group_pid": group_pid], encoding: URLEncoding.default)
        case let .getInvitationTopListByGroup(page_context, page_index, group_pid, cms_group_id):
            return .requestParameters(parameters: ["ac": "getInvitationTopListByGroup", "sn": "cms", "page_context": page_context, "page_index": page_index, "group_pid": group_pid, "cms_group_id": cms_group_id], encoding: URLEncoding.default)
        case let .updateGroup(invitation_authority, name, introduction, group_pid, group_id, can_out, reply_authority, index_pic):
            return .requestParameters(parameters: ["ac": "updateGroup", "sn": "cms", "invitation_authority": invitation_authority, "name": name, "introduction": introduction, "group_pid": group_pid, "group_id": group_id, "can_out": can_out, "reply_authority": reply_authority, "index_pic": index_pic], encoding: URLEncoding.default)
        case let .getPageKeyList(is_adaptive, app_id, group_id):
            return .requestParameters(parameters: ["ac": "getPageKeyList", "sn": "project", "is_adaptive": is_adaptive, "app_id": app_id, "group_id": group_id], encoding: URLEncoding.default)
        case let .getGroupByModel(group_id, page_index, page_context, code, page):
            return .requestParameters(parameters: ["ac": "getGroupByModel", "sn": "project", "model": "GroupListTopic", "group_id": group_id, "page_index": page_index, "page_context": page_context, "code": code, "page": page], encoding: URLEncoding.default)
        case .getAppAbout:
            return .requestParameters(parameters: ["ac": "getAppAbout", "sn": "project"], encoding: URLEncoding.default)
        case let .getArticleByModel(group_id, page, code, page_index, page_context):
            return .requestParameters(parameters: ["ac": "getArticleByModel", "sn": "project", "model": "PostList", "group_id": group_id, "page": page, "code": code, "page_index": page_index, "page_context": page_context], encoding: URLEncoding.default)
        case let .getSlideByModel(group_id, page, code):
            return .requestParameters(parameters: ["ac": "getSlideByModel", "sn": "project", "model": "SwipImgArea", "group_id": group_id, "page": page, "code": code], encoding: URLEncoding.default)
        case let .forceUpdateVersion(app_id, version, app_version):
            return .requestParameters(parameters: ["ac": "forceUpdateVersion", "sn": "project", "client": 1, "app_id": app_id, "version": version, "app_version": app_version], encoding: URLEncoding.default)
        case let .searchProject(page_index, key, page_context):
            return .requestParameters(parameters: ["ac": "searchProject", "sn": "project", "page_index": page_index, "key": key, "page_context": page_context], encoding: URLEncoding.default)
        case let .upUserPassword(old_password, new_password):
            return .requestParameters(parameters: ["ac": "upUserPassword", "sn": "uc", "old_password": old_password, "new_password": new_password], encoding: URLEncoding.default)
        case let .allRestriction(pid):
            return .requestParameters(parameters: ["ac": "allRestriction", "sn": "uc", "pid": pid], encoding: URLEncoding.default)
        case let .userRegist(username, password, zh_name, phone_num, phone_num_code, auth_code, code_key):
            return .requestParameters(parameters: ["ac": "userRegist", "sn": "uc", "username": username, "password": password, "zh_name": zh_name, "phone_num": phone_num, "phone_num_code": phone_num_code, "auth_code": auth_code, "code_key": code_key, "auth_code_type": "regist"], encoding: URLEncoding.default)
        case let .userLogin(username, password, code_key, auth_code):
            return .requestParameters(parameters: ["ac": "userLogin", "sn": "uc", "auth_code_type": "login", "username": username, "password": password, "auth_code": auth_code, "code_key": code_key], encoding: URLEncoding.default)
        case .userLogout:
            return .requestParameters(parameters: [:], encoding: URLEncoding.default)
        case let .userLoginByPhone(auth_code, phone_number):
            return .requestParameters(parameters: ["ac": "userLoginByPhone", "sn": "uc", "auth_code": auth_code, "phone_number": phone_number, "auth_code_type": "login"], encoding: URLEncoding.default)
        case let .retrievePassword(username, auth_code, password):
            return .requestParameters(parameters: ["ac": "retrievePassword", "sn": "uc", "username": username, "auth_code": auth_code, "password": password], encoding: URLEncoding.default)
        case .getUserAgreement:
            return .requestParameters(parameters: ["ac": "getUserAgreement", "sn": "uc"], encoding: URLEncoding.default)
        case .getRegisterAgreement:
            return .requestParameters(parameters: ["ac": "getRegisterAgreement", "sn": "uc"], encoding: URLEncoding.default)
        case let .getImgUploadtoken(bucket_type):
            return .requestParameters(parameters: ["ac": "getImgUploadtoken", "sn": "picsave", "bucket_type": bucket_type], encoding: URLEncoding.default)
        case let .applyForCode(can_use_num, out_time, code_type):
            return .requestParameters(parameters: ["ac": "applyForCode", "sn": "invitation", "code_type": code_type, "can_use_num": can_use_num, "out_time": out_time], encoding: URLEncoding.default)
        case let .getUserNotifyListByUser(page_index, page_context):
            return .requestParameters(parameters: ["ac": "getUserNotifyListByUser", "sn": "mc", "page_index": page_index, "page_context": page_context], encoding: URLEncoding.default)
        case let .getKey(device_name, device_id, token, develop):
            return .requestParameters(parameters: ["ac": "getKey", "sn": "im", "device_name": device_name, "device_id": device_id, "token": token, "develop": develop], encoding: URLEncoding.default)
        case .getOfflineMessage:
            return .requestParameters(parameters: ["ac": "getOffLineMessage", "sn": "mc"], encoding: URLEncoding.default)
        case let .confirmReceivedOffLineMessage(msg_ids):
            return .requestParameters(parameters: ["ac": "confirmReceivedOffLineMessage", "sn": "mc", "msg_ids": msg_ids], encoding: URLEncoding.default)
        case let .confirmReceivedOneMessage(msg_id):
            return .requestParameters(parameters: ["ac": "confirmReceivedOneMessage", "sn": "mc", "msg_id": msg_id], encoding: URLEncoding.default)
        case let .setUserOffline(device_id):
            return .requestParameters(parameters: ["ac": "setUserOffline", "sn": "mc", "device_id": device_id], encoding: URLEncoding.default)
        case .selectInsertGroup:
            return .requestParameters(parameters: ["ac": "selectInsertGroup", "sn": "im"], encoding: URLEncoding.default)
        case let .confirmAndRemoveUnreadMessage(msg_ids):
            return .requestParameters(parameters: ["ac": "confirmAndRemoveUnreadMessage", "sn": "mc", "msg_ids": msg_ids], encoding: URLEncoding.default)
        case let .addUnreadMessage(msg_id):
            return .requestParameters(parameters: ["ac": "addUnreadMessage", "sn": "mc", "msg_id": msg_id], encoding: URLEncoding.default)
        case .selectWaitMessageByUid:
            return .requestParameters(parameters: ["ac": "selectWaitMessageByUid", "sn": "mc"], encoding: URLEncoding.default)
        case let .confirmReceivedWaitMessage(msg_ids):
            return .requestParameters(parameters: ["ac": "confirmReceivedWaitMessage", "sn": "mc", "msg_ids": msg_ids], encoding: URLEncoding.default)
        case let .getPhoneEmailAuthCode(auth_type, code_key, phone_Email_num):
            return .requestParameters(parameters: ["ac": "getPhoneEmailAuthCode", "sn": "uc", "auth_type": auth_type, "code_key": code_key, "phone_Email_num": phone_Email_num], encoding: URLEncoding.default)
        case .authCodeKey:
            return .requestParameters(parameters: ["ac": "authCodeKey", "sn": "uc"], encoding: URLEncoding.default)
        case let .getAuthCode(auth_type, code_key):
            return .requestParameters(parameters: ["ac": "getAuthCode", "sn": "uc", "auth_type": auth_type, "code_key": code_key], encoding: URLEncoding.default)
        case let .getOtherGroupList(page_index, page_context, user_id, user_pid):
            return .requestParameters(parameters: ["ac": "getMyGroupList", "sn": "cms", "page_index": page_index, "page_context": page_context, "user_id": user_id, "user_pid": user_pid], encoding: URLEncoding.default)
        case let .findMessageByID(id):
            return .requestParameters(parameters: ["ac": "findMessageById", "sn": "mc", "id": id], encoding: URLEncoding.default)
        case .selectNoticeList:
            return .requestParameters(parameters: ["ac": "selectNoticeList", "sn": "cms"], encoding: URLEncoding.default)
        case .setUserRemind(let remind):
            return .requestParameters(parameters: ["ac": "setUserRemind", "sn": "mc", "remind": remind], encoding: URLEncoding.default)
        case .getUserRemind:
            return .requestParameters(parameters: ["ac": "getUserRemind", "sn": "mc"], encoding: URLEncoding.default)
        case let .getHtmlByModel(group_id, page, code):
            return .requestParameters(parameters: ["ac": "getHtmlByModel", "sn": "project", "model": "BuiltInWeb", "group_id": group_id, "code": code, "page": page], encoding: URLEncoding.default)
        case let .selectGoodsAppletList(pageIndex, pageContext, goodsName, sort):
            return .requestParameters(parameters: ["ac": "selectGoodsAppletList", "sn": "good", "page_index": pageIndex, "page_context": pageContext, "goods_name": goodsName, "sort": sort], encoding: URLEncoding.default)
        }
    }

    var headers: [String: String]? {
        return ["X-API-VERSION": "1.0", "Authorization-M3": ((getUserDefaults(key: kAuthorization + "\(GlobalConfigTool.shared.appId ?? 0)") as? String) ?? "")]
    }
}

// MARK: - Helpers
private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
