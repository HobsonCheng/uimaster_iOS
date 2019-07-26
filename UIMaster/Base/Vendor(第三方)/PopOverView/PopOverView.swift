//
//  PopOverView.swift
//  UIMaster
//
//  Created by gongcz on 2018/5/5.
//  Copyright © 2018年 one2much. All rights reserved.
//

import SnapKit
import UIKit

enum CPAlignStyle: Int {
    case left = 0// top-left
    case center  // top-center
    case right  // top-right

    case leftTop
    case leftCenter
    case leftBottom

    case rightTop
    case rightCener
    case rightBottom
}
@objc protocol PopOverViewDelegate: NSObjectProtocol {
    @objc optional func popOverViewDidShow(_ pView: PopOverView?)
    @objc optional func popOverViewDidDismiss(_ pView: PopOverView?)
    // for normal use
    // 普通用法（点击菜单）的回调
    func popOverView(_ pView: PopOverView?, didClickMenuIndex index: Int)
}

// 配置类
class PopOverVieConfiguration: NSObject {
    var showSpace: Float = 3.0
    // 视图出现时与目标view的间隙
    var triAngelHeight: Float = 8.0
    // 小三角的高度
    var triAngelWidth: Float = 10.0
    // 小三角的宽度
    var containerViewCornerRadius: Float = 6.0
    // 弹出视图背景的圆角半径
    var roundMargin: Float = 10.0
    // 调整弹出视图背景四周的空隙
    var isShouldDismissOnTouchOutside = true
    // 点击空白区域是否消失（默认YES）
    var isNeedAnimate = true
    // 开始和消失动画(默认YES)
    // 普通用法配置
    var defaultRowHeight: Float = 35.0
    // row高度
    var selectColor: UIColor = .lightGray
    var fontSize: CGFloat = 15
    var tableBackgroundColor: UIColor? = .clear
    var separatorColor: UIColor? = UIColor(white: 1, alpha: 0.4)
    var textColor: UIColor? = .white
    var textAlignment: NSTextAlignment = .left
    var font: UIFont? = UIFont.systemFont(ofSize: 14.0)
    var separatorStyle: UITableViewCellSeparatorStyle? = .singleLine
    var alignStyle: CPAlignStyle = .center
}

class PopOverCell: UITableViewCell {
    var iconImgV = UIImageView()
    var titleLbl = UILabel()
    var hasLayout = false
    fileprivate var imgWidth: CGFloat = 25
    fileprivate var type = 1 {
        didSet {
            configSubviews(type: type)
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleLbl.numberOfLines = 1
        iconImgV.contentMode = .scaleAspectFit
        contentView.addSubview(iconImgV)
        contentView.addSubview(titleLbl)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configSubviews(type: Int) {
        addConstraintToIconImgV(type: type)
        addConstraintToTitleLbl(type: type)
    }

    func addConstraintToIconImgV(type: Int) {
        guard type != 2 else { return }
        iconImgV.translatesAutoresizingMaskIntoConstraints = false
        //4左图右文 3左文右图
        iconImgV.snp.makeConstraints { make in
            if type == 4 || type == 1 {
                make.left.equalToSuperview().offset(10)
            }
            if type == 3 {
                make.right.equalToSuperview().offset(-10)
            }
            make.centerY.equalToSuperview()
            make.width.equalTo(imgWidth)
            make.height.equalTo(imgWidth)
        }
    }

    func addConstraintToTitleLbl(type: Int) {
        guard type != 1 else { return }
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            if type == 4 {
                make.left.equalTo(iconImgV.snp.right).offset(10)
                make.right.equalToSuperview().offset(-10)
            } else if type == 3 {
                make.right.equalTo(iconImgV.snp.left).offset(-10)
                make.left.equalToSuperview().offset(10)
            } else if type == 2 {
                make.left.equalToSuperview().offset(10)
                make.right.equalTo(-10)
            }
            make.height.equalTo(imgWidth)
        }
    }
}

// custom containerView
class PopOverContainerView: UIView {
    lazy var popLayer: CAShapeLayer = {
        let popLayer = CAShapeLayer()
        self.layer.addSublayer(popLayer)
        return popLayer
    }()
    var apexOftriangelX: CGFloat = 0 {
        didSet {
            setLayerFrame(frame)
        }
    }
    var layerColor: UIColor? {
        didSet {
            setLayerFrame(frame)
        }
    }
    var config: PopOverVieConfiguration?
    override var frame: CGRect {
        didSet {
            setLayerFrame(frame)
        }
    }
    init(config: PopOverVieConfiguration?) {
        super.init(frame: .zero)

        // monitor frame property
//        addObserver(self as NSObject, forKeyPath: "frame", options: [], context: nil)
        self.config = config
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
//        guard let keyPath = keyPath else { return }
//        guard let object = object as AnyObject? else { return }
//        if (keyPath == "frame") {
//            if let someValue = object.value(forKeyPath: keyPath) as AnyObject? {
//                let newFrame: CGRect = someValue.cgRectValue ?? .zero
//                setLayerFrame(newFrame)
//            }
//        }
//    }

    func setLayerFrame(_ frame: CGRect) {
        var apexOfTriangelX: CGFloat
        if apexOftriangelX == 0 {
            apexOfTriangelX = frame.size.width - 60
        } else {
            apexOfTriangelX = apexOftriangelX
        }
        // triangel must between left corner and right corner
        let containerViewCornerRadius = CGFloat(config?.containerViewCornerRadius ?? 0)
        let triAngelWidth = CGFloat(config?.triAngelWidth ?? 0)
        let triAngelHeight = CGFloat(config?.triAngelHeight ?? 0)
        if apexOfTriangelX > frame.size.width - containerViewCornerRadius {
            apexOfTriangelX = frame.size.width - containerViewCornerRadius - 0.5 * triAngelWidth
        } else if apexOfTriangelX < containerViewCornerRadius {
            apexOfTriangelX = containerViewCornerRadius + 0.5 * triAngelWidth
        }
        let point0 = CGPoint(x: apexOfTriangelX, y: 0)
        let point1 = CGPoint(x: apexOfTriangelX - 0.5 * triAngelWidth, y: triAngelHeight)
        let point2 = CGPoint(x: containerViewCornerRadius, y: triAngelHeight)
        let point2Center = CGPoint(x: containerViewCornerRadius, y: triAngelHeight + containerViewCornerRadius)
        let point3 = CGPoint(x: 0, y: frame.size.height - containerViewCornerRadius)
        let point3Center = CGPoint(x: containerViewCornerRadius, y: frame.size.height - containerViewCornerRadius)
        let point4 = CGPoint(x: frame.size.width - containerViewCornerRadius, y: frame.size.height)
        let point4Center = CGPoint(x: frame.size.width - containerViewCornerRadius, y: frame.size.height - containerViewCornerRadius)
        let point5 = CGPoint(x: frame.size.width, y: triAngelHeight + containerViewCornerRadius)
        let point5Center = CGPoint(x: frame.size.width - containerViewCornerRadius, y: triAngelHeight + containerViewCornerRadius)
        let point6 = CGPoint(x: CGFloat(apexOfTriangelX + 0.5 * triAngelWidth), y: triAngelHeight)
        let path = UIBezierPath()
        path.move(to: point0)
        path.addLine(to: point1)
        path.addLine(to: point2)
        path.addArc(withCenter: point2Center, radius: containerViewCornerRadius, startAngle: 3 * .pi / 2, endAngle: .pi, clockwise: false)
        path.addLine(to: point3)
        path.addArc(withCenter: point3Center, radius: containerViewCornerRadius, startAngle: .pi, endAngle: .pi / 2, clockwise: false)
        path.addLine(to: point4)
        path.addArc(withCenter: point4Center, radius: containerViewCornerRadius, startAngle: .pi / 2, endAngle: 0, clockwise: false)
        path.addLine(to: point5)
        path.addArc(withCenter: point5Center, radius: containerViewCornerRadius, startAngle: 0, endAngle: 3 * .pi / 2, clockwise: false)
        path.addLine(to: point6)
        path.close()
        popLayer.path = path.cgPath
        popLayer.fillColor = config?.tableBackgroundColor?.cgColor
    }
}

class PopOverView: UIView, UITableViewDelegate, UITableViewDataSource {
    var showType: Int = 1
    var config: PopOverVieConfiguration?
    weak var delegate: PopOverViewDelegate?
    // you can set custom view or custom viewController
    // 设置内容之前，先配置参数
    var content: UIView?
    // 保存cell上的点击事件
    var events = [EventsData]()

    var contentViewController: UIViewController? {
        didSet {
            content = contentViewController?.view
        }
    }
    var containerbackgroundColor: UIColor? {
        didSet {
            containerView.layerColor = containerbackgroundColor
        }
    }

    // MARK: - lazy
    fileprivate lazy var containerView: PopOverContainerView = {
        let containerView = PopOverContainerView(config: config)
        addSubview(containerView)
        return containerView
    }()

    fileprivate lazy var table: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.backgroundColor = config?.tableBackgroundColor
        table.separatorColor = config?.separatorColor
        table.rowHeight = CGFloat(config?.defaultRowHeight ?? 35.0)
        table.separatorStyle = config?.separatorStyle ?? .singleLine
        table.layer.cornerRadius = CGFloat(config?.containerViewCornerRadius ?? 0)
        table.layer.masksToBounds = true
        table.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        return table
    }()

    fileprivate var titleMenus: [String]?
    fileprivate var titleInfoes: [Dictionary<String, Any>]?
    fileprivate var alignStyle: CPAlignStyle = .left
    fileprivate weak var showFrom: UIView?

    class func popOverView() -> Self {
        return self.init()
    }

    required init() {
        super.init(frame: .zero)
//        initDefaultConfig()
        self.backgroundColor = UIColor.black.withAlphaComponent(0.2) //.clear
        NotificationCenter.default.addObserver(self, selector: #selector(self.cpScreenOrientationChange), name: .UIDeviceOrientationDidChange, object: nil)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initDefaultConfig()
        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)//.clear
//        NotificationCenter.default.addObserver(self, selector: #selector(self.cpScreenOrientationChange), name: .UIDeviceOrientationDidChange, object: nil)
    }
    convenience init(bounds: CGRect, config: PopOverVieConfiguration?) {
        self.init(frame: bounds)
        if config == nil {
//            initDefaultConfig()
        } else {
            self.config = config
        }
        table.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        table.delegate = self
        table.dataSource = self
        content = table
        refreshContainerFrame()
        table.isScrollEnabled = false
        //让线头不留白
        table.separatorInset = .zero
        table.layoutMargins = .zero
        NotificationCenter.default.addObserver(self, selector: #selector(self.cpScreenOrientationChange), name: .UIDeviceOrientationDidChange, object: nil)
    }

    convenience init(bounds: CGRect, config: PopOverVieConfiguration?, itemArr: [MenuItems], type: Int) {
        self.init(bounds: bounds, config: config)
        var info = [String]()//纯文字
        var iconInfo = [[String: String]]()//图标 + 文字
        var eventArr = [EventsData]()
        if type == 2 {
            for item in itemArr {
                info.append(item.fields?.title ?? "")
                if let safeEvents = item.events {//添加cell的事件
                    eventArr.append(safeEvents["click"] ?? EventsData())
                }
            }
            titleMenus = info
        } else {
            for item in itemArr {
                var dic = ["name": item.fields?.title ?? ""]
                dic["icon"] = item.fields?.normalIcon ?? ""
                dic["iconfont"] = item.fields?.iconfont ?? ""
                iconInfo.append(dic)
                if let safeEvents = item.events {//添加cell的事件
                    eventArr.append(safeEvents["click"] ?? EventsData())
                }
            }
            titleInfoes = iconInfo
        }
        self.events = eventArr
        //1图片 2文字 3文字+图片 4图片+文字
        self.showType = type
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func refreshContainerFrame() {
        var contentFrame: CGRect? = content?.frame
        contentFrame?.origin.x = CGFloat((config?.roundMargin ?? 0))
        contentFrame?.origin.y = CGFloat((config?.triAngelHeight ?? 0)) + CGFloat((config?.roundMargin ?? 0)) + 8
        content?.frame = contentFrame ?? CGRect.zero
        var temp: CGRect? = containerView.frame
        temp?.size.width = CGFloat((contentFrame?.maxX ?? 0)) + CGFloat((config?.roundMargin ?? 0))
        // left and right space
        temp?.size.height = CGFloat((contentFrame?.maxY ?? 0)) + CGFloat((config?.roundMargin ?? 0))
        containerView.frame = temp ?? CGRect.zero
        if let aContent = content {
            containerView.addSubview(aContent)
        }
    }

    func initDefaultConfig() {
        config = PopOverVieConfiguration()
        guard let config = config else { return }
        config.triAngelHeight = 8.0
        config.triAngelWidth = 10.0
        config.containerViewCornerRadius = 6.0
        config.roundMargin = 10.0
        config.showSpace = 3.0
        // 普通用法
        config.defaultRowHeight = 35.0
        config.tableBackgroundColor = UIColor.clear
        config.separatorColor = UIColor(white: 1, alpha: 0.4)
        config.separatorStyle = .singleLine
        config.textColor = UIColor.white
        config.font = UIFont.systemFont(ofSize: 14.0)
    }

    func show(from: UIView?) {
        showFrom = from
        judgeAlignStyle()
        // 此方法找到的window会在模态弹出时不准确
        //    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
        let window: UIWindow? = (UIApplication.shared.delegate as? AppDelegate)?.window
        containerView.alpha = 0
        self.backgroundColor = UIColor(white: 0, alpha: 0.0)
        window?.addSubview(self)
        updateSubViewFrames()
        addFocusView()
        delegate?.popOverViewDidShow?(self)
        if config?.isNeedAnimate ?? false {
            // animations support
            let oldOrigin = containerView.frame.origin
            var anchorPoint = CGPoint(x: 0.5, y: 0.5)
            if alignStyle == .leftTop {
                anchorPoint = CGPoint(x: 0, y: 0)
            } else if alignStyle == .leftBottom {
                anchorPoint = CGPoint(x: 0, y: 1)
            } else if alignStyle == .rightTop {
                anchorPoint = CGPoint(x: 1, y: 0)
            } else if alignStyle == .rightBottom {
                anchorPoint = CGPoint(x: 1, y: 1)
            } else if alignStyle == .left {
                let ratio = ((showFrom?.frame.width ?? 0) / 2 + 5) / containerView.width
                anchorPoint = CGPoint(x: ratio, y: 0)
            } else if alignStyle == .right {
                let ratio = (containerView.frame.width - (showFrom?.frame.width ?? 0) / 2 + 5) / containerView.width
                anchorPoint = CGPoint(x: ratio, y: 0)
            }
            containerView.layer.anchorPoint = anchorPoint
            let newOrigin = containerView.frame.origin

            var transition = CGPoint.zero
            transition.x = newOrigin.x - oldOrigin.x
            transition.y = newOrigin.y - oldOrigin.y
            containerView.center = CGPoint(x: containerView.center.x - transition.x, y: containerView.center.y - transition.y)

            containerView.transform = CGAffineTransform(scaleX: 0, y: 0) //CGAffineTransform(scaleX: 1.1, y: 1.1)

            containerView.alpha = 0
            self.backgroundColor = UIColor(white: 0, alpha: 0.0)
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.2)
            UIView.setAnimationCurve(.easeOut)
            containerView.transform = .identity //CGAffineTransform(scaleX: 1.0, y: 1.0)
            containerView.alpha = 1
            self.backgroundColor = UIColor(white: 0, alpha: 0.2)
            UIView.commitAnimations()
        } else {
            containerView.alpha = 1
            self.backgroundColor = UIColor(white: 0, alpha: 0.2)
        }
    }

    func judgeAlignStyle() {
        let window: UIWindow? = (UIApplication.shared.delegate as? AppDelegate)?.window
        if let showFrom = showFrom {
            let newFrame: CGRect = showFrom.convert(showFrom.bounds, to: window)
            let midX = newFrame.midX
            let midY = newFrame.midY
            let atNavBar = showFrom.superview is NaviBar
            let atLeft = midX <= kScreenW / 2
            let atTop = midY <= kScreenH / 2
            if atNavBar { // 自动判断：按钮在导航栏上则显示小三角 否则不显示
                config?.triAngelHeight = 8.0
                config?.triAngelWidth = 10.0
            } else {
                config?.triAngelHeight = 0
                config?.triAngelWidth = 0
            }
            // 这里暂时没有判断按钮在屏幕中间的情况，如果需要则加下判断 @浩弟
            if atLeft { // 屏幕左侧
                if atTop { // 屏幕左上方
                    if atNavBar { // 在导航栏左侧
                        alignStyle = .left
                    } else {
                        alignStyle = .leftTop
                    }
                } else { // 屏幕左下方
                    alignStyle = .leftBottom
                }
            } else { // 屏幕右侧
                if atTop { // 屏幕右上方
                    if atNavBar { // 在导航栏右侧
                        alignStyle = .right
                    } else {
                        alignStyle = .rightTop
                    }
                } else { // 屏幕右下方
                    alignStyle = .rightBottom
                }
            }
        } else {
            alignStyle = .left
        }
    }

    func addFocusView() {
        let window: UIWindow? = (UIApplication.shared.delegate as? AppDelegate)?.window
        if let showFrom = showFrom {
            let newFrame: CGRect = showFrom.convert(showFrom.bounds, to: window)
            let focusV = showFrom.snapshotView(afterScreenUpdates: true)
            focusV?.frame = newFrame
            if let focusV = focusV {
                addSubview(focusV)
            }

//            let imgV: UIImageView = UIImageView()
//            imgV.image = showFrom.screenSnapshot()
//            imgV.frame = newFrame
//            addSubview(imgV)
        }
    }

    func dismiss() {
        if config?.isNeedAnimate ?? false {
            // animations support
            UIView.animate(withDuration: 0.2, animations: {() -> Void in
                self.containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.containerView.alpha = 0
                self.backgroundColor = .clear
            }, completion: {(_ finished: Bool) -> Void in
                self.removeFromSuperview()
            })
        } else {
            removeFromSuperview()
        }
        delegate?.popOverViewDidDismiss?(self)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if config?.isShouldDismissOnTouchOutside ?? false {
            dismiss()
        }
    }
    func updateSubViewFrames() {
        let window: UIWindow? = (UIApplication.shared.delegate as? AppDelegate)?.window
        self.frame = window?.bounds ?? .zero
        if showFrom == nil {
            containerView.center = self.center
            return
        }
        guard let showFrom = showFrom else { return }
        let newFrame: CGRect = showFrom.convert(showFrom.bounds, to: window)
        // change containerView position
        var containerViewFrame: CGRect = containerView.frame
        containerViewFrame.origin.y = newFrame.maxY + CGFloat(config?.showSpace ?? 0)
        containerView.frame = containerViewFrame
        switch alignStyle {
        case .center:
            var center: CGPoint? = containerView.center
            center?.x = newFrame.midX
            containerView.center = center ?? CGPoint.zero
            containerView.apexOftriangelX = containerView.frame.width / 2
        case .left:
            var frame: CGRect? = containerView.frame
            frame?.origin.x = newFrame.minX
            containerView.frame = frame ?? CGRect.zero
            containerView.apexOftriangelX = showFrom.frame.width / 2
        case .right:
            var frame: CGRect? = containerView.frame
            let cWidth = frame?.size.width
            frame?.origin.x = CGFloat(Float(newFrame.minX) - (fabs(Float((cWidth ?? 0.0) - newFrame.size.width))))
            containerView.frame = frame ?? .zero
            containerView.apexOftriangelX = containerView.frame.width - showFrom.frame.width / 2
//        default:
        case .leftTop:
            var frame: CGRect? = containerView.frame
            let oY = frame?.origin.y ?? 0
            frame?.origin.x = newFrame.maxX - showFrom.width / 2
            frame?.origin.y = oY - newFrame.size.height + showFrom.height / 2
            containerView.frame = frame ?? CGRect.zero
            containerView.apexOftriangelX = showFrom.frame.width / 2
        case .leftCenter:
            var frame: CGRect? = containerView.frame
            frame?.origin.x = newFrame.maxX
            let oY = frame?.origin.y ?? 0
            let oH = frame?.size.height ?? 0
            frame?.origin.y = oY - oH / 2
            containerView.frame = frame ?? CGRect.zero
            containerView.apexOftriangelX = showFrom.frame.width / 2
        case .leftBottom:
            var frame: CGRect? = containerView.frame
            frame?.origin.x = newFrame.maxX - showFrom.width / 2
            let oY = frame?.origin.y ?? 0
            let oH = frame?.size.height ?? 0
            frame?.origin.y = oY - oH - showFrom.height / 2
            containerView.frame = frame ?? CGRect.zero
            containerView.apexOftriangelX = showFrom.frame.width / 2
        case .rightTop:
            var frame: CGRect? = containerView.frame
            let cWidth = frame?.size.width ?? 0
            let oY = frame?.origin.y ?? 0
            frame?.origin.x = CGFloat(Float(newFrame.minX) - Float(cWidth)) + showFrom.width / 2
            frame?.origin.y = oY - newFrame.size.height + showFrom.height / 2
            containerView.frame = frame ?? .zero
            containerView.apexOftriangelX = containerView.frame.width - showFrom.frame.width / 2
        case .rightCener:
            var frame: CGRect? = containerView.frame
            let cWidth = frame?.size.width ?? 0
            let oY = frame?.origin.y ?? 0
            let oH = frame?.size.height ?? 0
            frame?.origin.x = CGFloat(Float(newFrame.minX) - Float(cWidth))
            frame?.origin.y = oY - oH / 2
            containerView.frame = frame ?? .zero
            containerView.apexOftriangelX = containerView.frame.width - showFrom.frame.width / 2
        case .rightBottom:
            var frame: CGRect? = containerView.frame
            let cWidth = frame?.size.width ?? 0
            let oY = frame?.origin.y ?? 0
            let oH = frame?.size.height ?? 0
            frame?.origin.x = CGFloat(Float(newFrame.minX) - Float(cWidth)) + showFrom.width / 2
            frame?.origin.y = oY - oH - showFrom.height / 2
            containerView.frame = frame ?? .zero
            containerView.apexOftriangelX = containerView.frame.width - showFrom.frame.width / 2
        }
    }

    // MARK: - Notis
    @objc func cpScreenOrientationChange() {
        updateSubViewFrames()
    }

    // MARK: - <UITableViewDelegate, UITableViewDataSource>
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleMenus?.count ?? titleInfoes?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "GYPopOverCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? PopOverCell
        if nil == cell {
            cell = PopOverCell(style: .default, reuseIdentifier: identifier)
//            cell?.selectionStyle = .none
            cell?.contentView.backgroundColor = UIColor.clear
        }
        var text: String?
        var icon: String?
        var iconfont: String?
        if (titleMenus?.count ?? 0) > indexPath.row {
            text = titleMenus?[indexPath.row]
        }
        if (titleInfoes?.count ?? 0) > indexPath.row {
            if let dic = titleInfoes?[indexPath.row] {
                text = dic["name"] as? String ?? ""
                icon = dic["icon"] as? String ?? ""
                iconfont = dic["iconfont"] as? String ?? ""
            }
        }
        if showType != 1 {
            cell?.titleLbl.text = text
            cell?.titleLbl.textColor = config?.textColor
            cell?.titleLbl.font = config?.font
            cell?.titleLbl.textAlignment = config?.textAlignment ?? .left
        }
        let view = UIView(frame: cell?.frame ?? .zero)
        cell?.selectedBackgroundView = view
        cell?.selectedBackgroundView?.backgroundColor = config?.selectColor
        cell?.type = showType
        if icon != nil && icon != "" {
            cell?.iconImgV.kf.setImage(with: URL(string: icon ?? ""))
        } else if iconfont != nil && iconfont != ""{
            cell?.iconImgV.setYJIconWithCode(iconCode: iconfont ?? "", textColor: config?.textColor ?? .white, size: CGSize(width: 25, height: config?.fontSize ?? 14))
        }

        cell?.iconImgV.contentMode = .scaleAspectFit
        if let aCell = cell {
            return aCell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss()
        delegate?.popOverView(self, didClickMenuIndex: indexPath.row)
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
    }
    // MARK: -
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
