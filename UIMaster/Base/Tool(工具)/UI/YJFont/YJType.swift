//
//  YJType.swift
//  UIMaster
//
//  Created by hobson on 2019/7/10.
//  Copyright © 2019 one2much. All rights reserved.
//

import Foundation

enum YJType: Int {
    static var count: Int {
        return kYJIcons.count
    }
    static func getIconText(iconCode: String) -> String {
        let index = iconCode.index(iconCode.startIndex, offsetBy: 2)
        let endIndex = iconCode.index(of: ";") ?? iconCode.endIndex
        let subString = iconCode[index..<endIndex]
        let str = String(subString)
        guard let num = Int(str, radix: 16) else {
            return ""
        }
        if let scalar = UnicodeScalar(num) {
            let value = String(scalar)
            return value
        }
        return ""
    }
    var text: String? {
        return kYJIcons[rawValue]
    }
    // swiftlint:disable identifier_name
    case forwarBox, //转发
    flower0Pot, //花盆
    volume0, //消息
    home0, //首页
    account, //account
    template, //模板
    personalCenter, //个人中心
    wifi, //信号
    Line3across, //三横
    emoj, //表情2
    guid, //其它_引导
    circle0, //圆
    selected0, //单选选中
    follow, //关注
    message0, //消息
    articles, //文章列表
    work0bench, //工作台
    users, //群组
    bluetooth, //蓝牙
    album, //相册
    appointment, //预约
    settingFundation, //基本设置
    funs2, //粉丝
    edit, //评论
    password2, //密码
    comment, //评论
    users0, //用户群
    home, //首页
    QQ0, //qq
    managePage, //管理页面
    forward, //前进
    page0Manage, //页面管理
    downArrow, //箭头
    grabOrder, //抢单icon
    release, //发布
    grabOrder2, //抢单
    circle0_2, //引导页滑动圆圈
    at, //艾特
    profile0, //基本信息
    weibo0, //微博
    profile, //基本信息
    signal, //信号
    delete, //删除
    news, //资讯
    at3, //艾特
    praise, //点赞
    checked0, //选中
    release0, //发布
    nineBox, //九宫格
    cart, //cart
    settingMenu, //菜单设置
    news2, //资讯
    locate, //定位
    add, //添加
    generateAlbum, //生成相册
    choose0, //单选
    choose0No, //单选_不可选
    charege, //充电
    project0Mange, //项目管理
    menuOff0, //左
    work0Order, //工单
    follow2, //关注
    comment2, //评论 copy
    uploadImage, //上传图片
    box0, //方块
    project0Manage, //项目管理
    YJvor, //粉丝
    home0_2, //home_fill_
    market, //商店
    praised, //点赞
    profile0_2, //基本信息
    users2, //用户组
    edit2, //编辑
    wechat0, //微信
    projectManage, //项目管理
    lauch, //启动
    follow3, //关注
    module, //模板
    funs, //粉丝
    nextArrow, //箭头
    authCode, //验证码
    delete0, //删除
    battery0, //电池1
    settingGloble, //全局设置
    projects0, //项目
    follow4, //关注
    at2, //艾特
    users0_2, //群组
    praise2, //点赞
    slideShow, //轮播图
    weibo, //微博-登录
    password, //password
    setting0SideBar, //侧栏_全局设置
    forwardBox, //转发
    module0Manage, //模块管理
    searchEarth, //地球
    down0, //下
    users3, //群组
    project0, //项目管理
    forward2, //转发
    publish, //发布
    QRCode, //二维码
    comment3, //评论
    QQ, //qq登录
    wechat, //微信登录
    eGrab0Order, //e抢单
    generate, //生成
    appointment2, //预约
    user, //用户名
    setting0, //设置
    appointment3, //预约
    close0, //关闭
    user0, //用户组
    menuSideBar, //侧边栏菜单
    pageManage, //页面管理
    users4, //群组
    searchBar, //搜索框
    topic, //话题
    menu0Show, //不用
    launchPage, //APP启动页
    home2, //首页
    nine0Box, //九宫格
    menuOn, //菜单展开
    menuOff, //菜单收起
    back0forward, //后退撤销
    praised0, //点赞
    person, //观演人
    notebook, //笔记本_1
    release2, //发布
    linesVertical, //三横
    checkedNo, //未勾选40
    checkedBox, //已勾选40
    grab0Order, //抢单
    grabOrder3, //抢单 (2)
    clear, //清除
    search, //搜索
    quto, //问号
    report, //举报
    authPic, //图片验证码
    authCode2, //验证码2
    back, //返回
    upArrow, //上
    add0, //加号无边框
    addImage, //添加图片
    gift0, //福利空心
    gitf1, //福利实心
    phone, //手机号
    apartment, //单位名称
    registTime//注册时间
}
let kYJIcons = [
    "\u{e634}",
    "\u{e62d}",
    "\u{e61a}",
    "\u{e68d}",
    "\u{e6b8}",
    "\u{e68e}",
    "\u{e60b}",
    "\u{e695}",
    "\u{e623}",
    "\u{e627}",
    "\u{ea21}",
    "\u{e626}",
    "\u{e651}",
    "\u{e643}",
    "\u{e681}",
    "\u{e605}",
    "\u{e60d}",
    "\u{e644}",
    "\u{e6ae}",
    "\u{e64c}",
    "\u{e645}",
    "\u{e61e}",
    "\u{e646}",
    "\u{e638}",
    "\u{e606}",
    "\u{e63e}",
    "\u{e618}",
    "\u{e617}",
    "\u{e629}",
    "\u{e62b}",
    "\u{e608}",
    "\u{e61d}",
    "\u{e631}",
    "\u{e6cb}",
    "\u{e647}",
    "\u{e661}",
    "\u{e6ce}",
    "\u{e633}",
    "\u{e603}",
    "\u{e637}",
    "\u{e703}",
    "\u{e614}",
    "\u{e600}",
    "\u{e648}",
    "\u{e650}",
    "\u{e64a}",
    "\u{e7eb}",
    "\u{e64b}",
    "\u{e6f5}",
    "\u{e68f}",
    "\u{e613}",
    "\u{e64d}",
    "\u{e7dc}",
    "\u{e65d}",
    "\u{e625}",
    "\u{e62c}",
    "\u{e62f}",
    "\u{e60a}",
    "\u{e639}",
    "\u{e616}",
    "\u{e60e}",
    "\u{e6ee}",
    "\u{e640}",
    "\u{e63b}",
    "\u{e620}",
    "\u{e658}",
    "\u{e675}",
    "\u{e7d8}",
    "\u{e61f}",
    "\u{e64e}",
    "\u{e7ac}",
    "\u{e619}",
    "\u{e607}",
    "\u{e659}",
    "\u{e604}",
    "\u{e612}",
    "\u{e64f}",
    "\u{e641}",
    "\u{e652}",
    "\u{e632}",
    "\u{e660}",
    "\u{e68a}",
    "\u{e615}",
    "\u{e65c}",
    "\u{e662}",
    "\u{e653}",
    "\u{e69b}",
    "\u{e654}",
    "\u{e683}",
    "\u{e699}",
    "\u{e67c}",
    "\u{e82b}",
    "\u{e663}",
    "\u{e636}",
    "\u{e73e}",
    "\u{e655}",
    "\u{e7a8}",
    "\u{e8d7}",
    "\u{e624}",
    "\u{e673}",
    "\u{e656}",
    "\u{e609}",
    "\u{e642}",
    "\u{e61b}",
    "\u{e62a}",
    "\u{e630}",
    "\u{e601}",
    "\u{e65e}",
    "\u{e621}",
    "\u{e649}",
    "\u{e657}",
    "\u{e63d}",
    "\u{e61c}",
    "\u{e622}",
    "\u{e60c}",
    "\u{e65a}",
    "\u{e67b}",
    "\u{e635}",
    "\u{e628}",
    "\u{e63a}",
    "\u{e62e}",
    "\u{e63c}",
    "\u{e60f}",
    "\u{e610}",
    "\u{e602}",
    "\u{e65b}",
    "\u{e63f}",
    "\u{e685}",
    "\u{e65f}",
    "\u{e611}",
    "\u{e666}",
    "\u{e667}",
    "\u{e664}",
    "\u{e665}",
    "\u{ea22}",
    "\u{e6c6}",
    "\u{e72d}",
    "\u{e668}",
    "\u{e755}",
    "\u{e669}",
    "\u{e679}",
    "\u{e66a}",
    "\u{e81a}",
    "\u{e66f}",
    "\u{e690}",
    "\u{e66b}",
    "\u{e69e}",
    "\u{ea99}",
    "\u{e701}"
]
