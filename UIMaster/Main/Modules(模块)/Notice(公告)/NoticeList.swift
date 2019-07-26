//
//  Notice.swift
//  UIMaster
//
//  Created by hobson on 2019/1/22.
//  Copyright © 2019 one2much. All rights reserved.
//

import UIKit

// swiftlint:disable identifier_name
class NoticeModel: BaseModel {
    var data: [NoticeData]?
}

class NoticeData: BaseData {
    var id: Int?
    var pid: Int?
    var invitation_id: Int?
    var title: String?
    var content: String?
    var message_id: String?
    var add_time: String?
    var update_time: String?
    var status: Int?
}

// swiftlint:enable identifier_name
class NoticeList: BaseNameVC, PageModuleAble {
    weak var moduleDelegate: ModuleRefreshDelegate?

    var moduleParams: [String: Any]? {
        didSet {
            reloadViewData()
        }
    }
    var styleDic: [String: Any]? {
        didSet {
            self.view.height = 44
            let styleModel = BaseConfigModel.deserialize(from: styleDic)
            self.events = styleModel?.events
            renderUI()
        }
    }

    // MARK: 私有属性
    private var noticeArr: [NoticeData] = []
    private var events: [String: EventsData]?
    // 定时器
    private lazy var timer: SwiftTimer = {
        SwiftTimer(interval: .seconds(2), repeats: true, leeway: .seconds(0), queue: .global(), handler: { [weak self] _ in
            DispatchQueue.main.async {
                self?.autoScroll()
            }
        })
    }()
    let scrollView = UIScrollView(frame: .zero)

    // MARK: 初始化方法
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.rx.notification(Notification.Name("noticeRefresh"))
            .takeUntil(self.rx.deallocated)
            .subscribe(onNext: { [weak self] _ in
                self?.reloadViewData()
            })
            .disposed(by: rx.disposeBag)
    }
}

// MARK: - UI处理
extension NoticeList {
    func renderUI() {
        self.view.backgroundColor = .white
        //1. 创建公告label
        let tipLabel = UILabel(frame: CGRect.zero)
        tipLabel.backgroundColor = UIColor(hexString: "f4666b")
        tipLabel.textColor = .white
        tipLabel.text = "公告"
        tipLabel.textAlignment = .center
        tipLabel.layer.cornerRadius = 3
        tipLabel.maskToBounds = true
        self.view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.equalTo(44)
            make.height.equalTo(24)
            make.left.equalTo(20)
        }
        //2. 创建scrollView
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.left.equalTo(tipLabel.snp.right).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalToSuperview()
        }
        //3. 设置公告信息
        setNoticeInfo()
        //4.开启定时器
        timer.start()
    }

    /// 设置公告信息
    private func setNoticeInfo() {
        scrollView.removeAllSubviews()
        let height = self.view.height
        // 没有数据时，显示暂无公告
        if noticeArr.isEmpty {
            let notice = NoticeData()
            notice.title = "暂无公告"
            setContent(index: 0, notice: notice)
            // 循环创建信息的label 添加到scrollView
            scrollView.contentSize = CGSize(width: 0, height: height)
            return
        }
        // 有数据，显示数据
        noticeArr.append(noticeArr.first!)
        // 循环创建信息的label 添加到scrollView
        scrollView.contentSize = CGSize(width: 0, height: noticeArr.count * Int(height))
        for (index, notice) in noticeArr.enumerated() {
            setContent(index: index, notice: notice)
        }
    }

    private func setContent(index: Int, notice: NoticeData) {
        let height = self.view.height
        let label = UILabel(frame: .zero)
        label.text = notice.title ?? "暂无"
        label.textColor = .gray
        scrollView.addSubview(label)
        label.snp.makeConstraints { make in
            make.width.height.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(CGFloat(index) * height)
        }
        if notice.id == nil {
            return
        }
        label.rx.tapGesture()
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                let topic = TopicData()
                topic.id = notice.invitation_id
                topic.group_pid = notice.pid
                let events = self?.events?[kOneEvent]
                events?.attachment[TopicData.getClassName] = topic
                events?.attachment["hideModule"] = Comment.getClassName
                let result = EventUtil.handleEvents(event: events)
                EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
            })
            .disposed(by: rx.disposeBag)
    }

    /// 自动轮播
    private func autoScroll() {
        if noticeArr.count == 1 {
            return
        }
        var currentPoint = scrollView.contentOffset
        currentPoint.y += scrollView.height
        if currentPoint.y + scrollView.height > scrollView.contentSize.height {
            currentPoint.y = 0
            scrollView.setContentOffset(currentPoint, animated: false)
            timer.fire()
        } else {
            scrollView.setContentOffset(currentPoint, animated: true)
        }
    }
}

// MARK: - 网络请求
extension NoticeList {
    func reloadViewData() {
        self.requestNoticeData()
    }

    func requestNoticeData() {
        NetworkUtil.request(
            target: .selectNoticeList,
            success: { [weak self] json in
                self?.noticeArr = NoticeModel.deserialize(from: json)?.data ?? []
                self?.setNoticeInfo()
            }
        ) { msg in
            HUDUtil.msg(msg: msg, type: .error)
        }
    }
}

extension NoticeList: UIScrollViewDelegate {
    // MARK: ScrollView Begin Drag
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer.suspend()
    }

    // MARK: ScrollView End Drag
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.timer.start()
        }
    }
}
