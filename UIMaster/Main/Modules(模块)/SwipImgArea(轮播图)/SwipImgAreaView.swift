//
//  SwipImgView.swift
//  UIDS
//
//  Created by one2much on 2018/1/10.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit
/// 底部指示器样式
 enum PageControlStyle {
    case none
    case system
    case fill
    case pill
    case snake
    case image
}
/// 指示器位置
enum PageControlPosition: Int {
    case left
    case center
    case right
}

typealias DidSelectItemAtIndexClosure = (Int) -> Void

class SwipImgAreaView: UIView, PageModuleAble {
    var styleDic: [String: Any]? {
        didSet {
            let swiperImageModel = SwiperImageModel.deserialize(from: styleDic)
            self.layer.cornerRadius = swiperImageModel?.styles?.radius ?? 0
            self.layer.masksToBounds = true
            self.customPageControlStyle = swiperImageModel?.styles?.switchStyle == 1 ? .pill : .system
            self.scrollDirection = swiperImageModel?.styles?.switchEffect == 1 ? .vertical : .horizontal
            self.autoScrollTimeInterval = swiperImageModel?.styles?.switchTime ?? self.autoScrollTimeInterval
            self.collectionViewBackgroundColor = swiperImageModel?.styles?.bgColor?.toColor() ?? self.collectionViewBackgroundColor
            self.imageViewContentMode = .scaleToFill
            self.pageControlTintColor = swiperImageModel?.styles?.bgColorIndicatorColor?.toColor() ?? self.pageControlTintColor
            self.pageControlCurrentPageColor = swiperImageModel?.styles?.bgColorIndicatorColorSel?.toColor() ?? self.pageControlCurrentPageColor
            self.customPageControlTintColor = swiperImageModel?.styles?.bgColorIndicatorColor?.toColor() ?? self.customPageControlTintColor
            self.customPageControlInActiveTintColor = swiperImageModel?.styles?.bgColorIndicatorColorSel?.toColor() ?? self.customPageControlInActiveTintColor
            self.pageControlPosition = PageControlPosition(rawValue: swiperImageModel?.styles?.buttonPosition ?? self.pageControlPosition.rawValue) ?? self.pageControlPosition
            self.infiniteLoop = true
//            self.customPageControlIndicatorPadding = 16
            self.pageControlBottom = 15
//            self.pageControlLeadingOrTrialingContact = 0
            getCacheJson(key: SwipImgAreaView.getClassName + (self.pageKey ?? "") + (self.moduleCode ?? "")) { [weak self] json in
                if let imageData = SwiperImageDataModel.deserialize(from: json)?.data {
                    self?.imagePaths.removeAll()
                    self?.titles.removeAll()
                    for item in imageData {
                        self?.imagePaths.append(item.fields?.normalIcon ?? "")
                    }
                    self?.didSelectItemAtIndex = { index in
                        if imageData.count <= index {
                            return
                        }
                        let event = imageData[index].events?["click"]
                        let result = EventUtil.handleEvents(event: event)
                        EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
                    }
                }
            }
            getSwiperData()
        }
    }

    weak var moduleDelegate: ModuleRefreshDelegate?
    // MARK: 控制参数
    /// 是否自动滚动，默认true
     var autoScroll = true {
        didSet {
            invalidateTimer()
            // 如果关闭的无限循环，则不进行计时器的操作，否则每次滚动到最后一张就不在进行了。
            if autoScroll && infiniteLoop {
                setupTimer()
            }
        }
    }

    // 无限循环，默认true 此属性修改了就不存在轮播的意义了
     var infiniteLoop = true {
        didSet {
            if !(imagePaths.isEmpty) {
                let temp = imagePaths
                imagePaths = temp
            }
        }
    }

    // 滚动方向，默认horizontal
     var scrollDirection: UICollectionViewScrollDirection? = .horizontal {
        didSet {
            flowLayout?.scrollDirection = scrollDirection!
            if scrollDirection == .horizontal {
                position = .centeredHorizontally
            } else {
                position = .centeredVertically
            }
        }
    }

    // 滚动间隔时间,默认2s
     var autoScrollTimeInterval: Double = 2.0 {
        didSet {
            autoScrollTimeInterval += 0.8
            autoScroll = true
        }
    }

    // 加载状态图 -- 这个是有数据，等待加载的占位图
     var placeHolderImage: UIImage? = nil {
        didSet {
            if placeHolderImage != nil {
                placeHolderViewImage = placeHolderImage
            }
        }
    }

    // 空数据页面显示占位图 -- 这个是没有数据，整个轮播器的占位图
     var coverImage: UIImage? = nil {
        didSet {
            if coverImage != nil {
                coverViewImage = coverImage
            }
        }
    }

    // 背景色
     var collectionViewBackgroundColor: UIColor! = UIColor.clear

    // MARK: 图片属性
    // 图片显示Mode
     var imageViewContentMode: UIViewContentMode? {
        didSet {
            collectionView.reloadData()
        }
    }

    // MARK: PageControl
     var pageControlTintColor = UIColor.lightGray {
        didSet {
            setupPageControl()
        }
    }
    // 当前显示颜色
     var pageControlCurrentPageColor = UIColor.white {
        didSet {
            setupPageControl()
        }
    }

    // MARK: CustomPageControl
    // 注意： 由于属性较多，所以请使用style对应的属性，如果没有标明则通用
     var customPageControlStyle: PageControlStyle = .system {
        didSet {
            setupPageControl()
        }
    }
    // 颜色
     var customPageControlTintColor = UIColor.white {
        didSet {
            setupPageControl()
        }
    }
    // Indicator间距
     var customPageControlIndicatorPadding: CGFloat = 8 {
        didSet {
            setupPageControl()
        }
    }

    // PageControl 位置
     var pageControlPosition: PageControlPosition = .center {
        didSet {
            setupPageControl()
        }
    }

    // PageControl x轴间距
     var pageControlLeadingOrTrialingContact: CGFloat = 28 {
        didSet {
            setNeedsDisplay()
        }
    }

    // PageControl bottom间距
     var pageControlBottom: CGFloat = 11 {
        didSet {
            setNeedsDisplay()
        }
    }

    // PageControl x轴文本间距
     var titleLeading: CGFloat = 15

    // PageControl
     var pageControl: UIPageControl?

    // Custom PageControl
     var customPageControl: UIView?

    // PageControlStyle == .fill
    // 圆大小
     var fillPageControlIndicatorRadius: CGFloat = 4 {
        didSet {
            setupPageControl()
        }
    }

    // PageControlStyle == .pill || PageControlStyle == .snake
    // 当前的颜色
     var customPageControlInActiveTintColor = UIColor(white: 1, alpha: 0.3) {
        didSet {
            setupPageControl()
        }
    }

    // 自定义pageControl图标
     var pageControlActiveImage: UIImage? = nil {
        didSet {
            setupPageControl()
        }
    }

    // 当前的pageControl图标
     var pageControlInActiveImage: UIImage? = nil {
        didSet {
            setupPageControl()
        }
    }

    // ImagePaths数据源
     var imagePaths: [String] = [] {
        didSet {
            totalItemsCount = infiniteLoop ? imagePaths.count * 100 : imagePaths.count
            if imagePaths.count > 1 {
                collectionView.isScrollEnabled = true
                setupPageControl()
                pageControl?.isHidden = false
                pageControl?.isUserInteractionEnabled = false
            } else {
                collectionView.isScrollEnabled = false
                setupPageControl()
                pageControl?.isHidden = true
                pageControl?.isUserInteractionEnabled = false
            }

            // 计算最大扩展区大小
            if scrollDirection == .horizontal {
                maxSwipeSize = CGFloat(imagePaths.count) * collectionView.frame.width
            } else {
                maxSwipeSize = CGFloat(imagePaths.count) * collectionView.frame.height
            }

            collectionView.reloadData()
        }
    }

    // 文本颜色
     var textColor = UIColor.white

    // 文本行数
     var numberOfLines: Int = 2

    // 文本字体
     var font = UIFont.systemFont(ofSize: 15)

    // 文本区域背景颜色
     var titleBackgroundColor = UIColor.black.withAlphaComponent(0.3)

    // 标题
     var titles: [String] = [] {
        didSet {
            if !(titles.isEmpty) {
                if imagePaths.isEmpty {
                    imagePaths = titles
                }
            }
        }
    }

    // MARK: 闭包
    // 回调
     var didSelectItemAtIndex: DidSelectItemAtIndexClosure?

    // MARK: Private
    // Identifier
    fileprivate let identifier = "SwipImgAreaCell"

    // 数量
    fileprivate var totalItemsCount = 1

    // 显示图片(CollectionView)
    fileprivate var collectionView: UICollectionView!

    // 最大伸展空间(防止出现问题，可外部设置)
    // 用于反方向滑动的时候，需要知道最大的contentSize
    fileprivate var maxSwipeSize: CGFloat = 0

    // 暂不开放
    // 用于反方向滑动的时候，需要知道最大的contentSize
    //  var maxContentSize: CGFloat = 0 {
    //    didSet {
    //        maxSwipeSize = maxContentSize
    //    }
    // }

    // 方向(swift后没有none，只能指定了)
    fileprivate var position: UICollectionViewScrollPosition! = .centeredHorizontally

    // 是否纯文本
    fileprivate var isOnlyTitle: Bool = false

    // Cell Height
    fileprivate var cellHeight: CGFloat = 56

    // FlowLayout
    fileprivate lazy var flowLayout: UICollectionViewFlowLayout? = {
        let tempFlowLayout = UICollectionViewFlowLayout()
        tempFlowLayout.minimumLineSpacing = 0
        tempFlowLayout.scrollDirection = .horizontal
        return tempFlowLayout
    }()

    // 计时器
    fileprivate var timer: Timer?

    // 加载状态图
    fileprivate var placeHolderViewImage: UIImage! = UIImage(named: "llplaceholder.png", in: Bundle(for: SwipImgAreaView.self), compatibleWith: nil)

    // 空数据页面显示占位图
    fileprivate var coverViewImage: UIImage! = UIImage(named: "llplaceholder.png", in: Bundle(for: SwipImgAreaView.self), compatibleWith: nil)

    // MARK: 初始化
    override  init(frame: CGRect) {
        super.init(frame: frame)
        // setupMainView
        setupMainView()
        setupPageControl()
    }

     class func llCycleScrollViewWithFrame(_ frame: CGRect, imageURLPaths: Array<String>? = [], titles: Array<String>? = [], didSelectItemAtIndex: DidSelectItemAtIndexClosure? = nil) -> SwipImgAreaView {
        let llcycleScrollView = SwipImgAreaView(frame: frame)
        // Nil
        llcycleScrollView.imagePaths = []
        llcycleScrollView.titles = []

        if let imageURLPathList = imageURLPaths, !(imageURLPathList.isEmpty) {
            llcycleScrollView.imagePaths = imageURLPathList
        }

        if let titleList = titles, !(titleList.isEmpty) {
            llcycleScrollView.titles = titleList
        }

        if didSelectItemAtIndex != nil {
            llcycleScrollView.didSelectItemAtIndex = didSelectItemAtIndex
        }
        return llcycleScrollView
    }

    // MARK: 纯文本
     class func llCycleScrollViewWithTitles(frame: CGRect, backImage: UIImage? = nil, titles: Array<String>? = [], didSelectItemAtIndex: DidSelectItemAtIndexClosure? = nil) -> SwipImgAreaView {
        let llcycleScrollView = SwipImgAreaView(frame: frame)
        // Nil
        llcycleScrollView.titles = []

        if let backImage = backImage {
            // 异步加载数据时候，第一个页面会出现placeholder image，可以用backImage来设置纯色图片等其他方式
            llcycleScrollView.coverImage = backImage
        }

        // Set isOnlyTitle
        llcycleScrollView.isOnlyTitle = true

        // Cell Height
        llcycleScrollView.cellHeight = frame.size.height

        // Titles Data
        if let titleList = titles, !(titleList.isEmpty) {
            llcycleScrollView.titles = titleList
        }

        if didSelectItemAtIndex != nil {
            llcycleScrollView.didSelectItemAtIndex = didSelectItemAtIndex
        }
        return llcycleScrollView
    }

    required  init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupMainView()
    }

    // MARK: 添加Timer
    func setupTimer() {
        // 仅一张图不进行滚动操纵
        if self.imagePaths.count <= 1 { return }
        timer = Timer.scheduledTimer(timeInterval: autoScrollTimeInterval as TimeInterval, target: self, selector: #selector(automaticScroll), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .commonModes)
    }

    // MARK: 关闭倒计时
    func invalidateTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }

    // MARK: Actions
    @objc func automaticScroll() {
        if totalItemsCount == 0 { return }
        let targetIndex = currentIndex() + 1
        scollToIndex(targetIndex: targetIndex)
    }

    func scollToIndex(targetIndex: Int) {
        if targetIndex >= totalItemsCount {
            if infiniteLoop {
                collectionView.scrollToItem(at: IndexPath(item: Int(totalItemsCount / 2), section: 0), at: position, animated: false)
            }
            return
        }
        collectionView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: position, animated: true)
    }

    func currentIndex() -> Int {
        if collectionView.width == 0 || collectionView.height == 0 {
            return 0
        }
        var index = 0
        if flowLayout?.scrollDirection == UICollectionViewScrollDirection.horizontal {
            index = NSInteger(collectionView.contentOffset.x + (flowLayout?.itemSize.width)! * 0.5) / NSInteger((flowLayout?.itemSize.width)!)
        } else {
            index = NSInteger(collectionView.contentOffset.y + (flowLayout?.itemSize.height)! * 0.5) / NSInteger((flowLayout?.itemSize.height)!)
        }
        return index
    }
}

// MARK: 网络
extension SwipImgAreaView {
    //刷新数据
    func reloadViewData() {
        getSwiperData()
    }
    //向m2请求数据
    func getSwiperData() {
        NetworkUtil.request(target: .getSlideByModel(group_id: UserUtil.getGroupId(), page: self.pageKey ?? "", code: self.moduleCode ?? ""), success: { [weak self] json in
            self?.cacheJson(key: SwipImgAreaView.getClassName + (self?.pageKey ?? "") + (self?.moduleCode ?? ""), json: json)
            if let imageData = SwiperImageDataModel.deserialize(from: json)?.data {
                self?.imagePaths.removeAll()
                self?.titles.removeAll()
                for item in imageData {
                    self?.imagePaths.append(item.fields?.normalIcon ?? "")
                }
                self?.didSelectItemAtIndex = { index in
                    if imageData.count <= index {
                        return
                    }
                    let event = imageData[index].events?["click"]
                    let result = EventUtil.handleEvents(event: event)
                    EventUtil.eventTrigger(with: result, on: nil, delegate: nil)
                }
            }
            self?.moduleDelegate?.moduleDataDidRefresh(noMore: false)
        }) { error in
            dPrint(error)
        }
    }
}
// MARK: - UI布局
extension SwipImgAreaView {
    // MARK: 添加UICollectionView
    private func setupMainView() {
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout!)
        collectionView.register(SwipImgAreaCell.self, forCellWithReuseIdentifier: identifier)
        collectionView.backgroundColor = collectionViewBackgroundColor
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.scrollsToTop = false
        self.addSubview(collectionView)
    }

    // MARK: 添加PageControl
    func setupPageControl() {
        // 重新添加
        if pageControl != nil {
            pageControl?.removeFromSuperview()
        }

        if customPageControl != nil {
            customPageControl?.removeFromSuperview()
        }

        if customPageControlStyle == .none {
            pageControl = UIPageControl()
            pageControl?.numberOfPages = self.imagePaths.count
        }

        if customPageControlStyle == .system {
            pageControl = UIPageControl()
            pageControl?.pageIndicatorTintColor = pageControlTintColor
            pageControl?.currentPageIndicatorTintColor = pageControlCurrentPageColor
            pageControl?.numberOfPages = self.imagePaths.count
            self.addSubview(pageControl!)
            pageControl?.isHidden = false
        }

        if customPageControlStyle == .fill {
            customPageControl = SwipImgAreaPageControl(frame: CGRect.zero)
            customPageControl?.tintColor = customPageControlTintColor
            (customPageControl as? SwipImgAreaPageControl)?.indicatorPadding = customPageControlIndicatorPadding
            (customPageControl as? SwipImgAreaPageControl)?.indicatorRadius = fillPageControlIndicatorRadius
            (customPageControl as? SwipImgAreaPageControl)?.pageCount = self.imagePaths.count
            self.addSubview(customPageControl!)
        }

        if customPageControlStyle == .pill {
            customPageControl = SwipImgAreaPillPageControl(frame: CGRect.zero)
            (customPageControl as? SwipImgAreaPillPageControl)?.indicatorPadding = customPageControlIndicatorPadding
            (customPageControl as? SwipImgAreaPillPageControl)?.activeTint = customPageControlTintColor
            (customPageControl as? SwipImgAreaPillPageControl)?.inactiveTint = customPageControlInActiveTintColor
            (customPageControl as? SwipImgAreaPillPageControl)?.pageCount = self.imagePaths.count
            self.addSubview(customPageControl!)
        }

        if customPageControlStyle == .snake {
            customPageControl = SwipImgAreaSnakePageControl(frame: CGRect.zero)
            (customPageControl as? SwipImgAreaSnakePageControl)?.activeTint = customPageControlTintColor
            (customPageControl as? SwipImgAreaSnakePageControl)?.indicatorPadding = customPageControlIndicatorPadding
            (customPageControl as? SwipImgAreaSnakePageControl)?.indicatorRadius = fillPageControlIndicatorRadius
            (customPageControl as? SwipImgAreaSnakePageControl)?.inactiveTint = customPageControlInActiveTintColor
            (customPageControl as? SwipImgAreaSnakePageControl)?.pageCount = self.imagePaths.count
            self.addSubview(customPageControl!)
        }

        if customPageControlStyle == .image {
            pageControl = SwipImgAreaImagePageControl()
            pageControl?.pageIndicatorTintColor = UIColor.clear
            pageControl?.currentPageIndicatorTintColor = UIColor.clear

            if let activeImage = pageControlActiveImage {
                (pageControl as? SwipImgAreaImagePageControl)?.dotActiveImage = activeImage
            }
            if let inActiveImage = pageControlInActiveImage {
                (pageControl as? SwipImgAreaImagePageControl)?.dotInActiveImage = inActiveImage
            }

            pageControl?.numberOfPages = self.imagePaths.count
            self.addSubview(pageControl!)
            pageControl?.isHidden = false
        }
    }

    // MARK: layoutSubviews
    override  func layoutSubviews() {
        super.layoutSubviews()
        // CollectionView
        collectionView.frame = self.bounds
        // Cell Size
        flowLayout?.itemSize = self.frame.size
        // Page Frame
        if customPageControlStyle == .none || customPageControlStyle == .system || customPageControlStyle == .image {
            if pageControlPosition == .center {
                pageControl?.frame = CGRect(x: 0, y: self.height - pageControlBottom, width: UIScreen.main.bounds.width, height: 10)
            } else {
                let pointSize = pageControl?.size(forNumberOfPages: self.imagePaths.count)
                if pageControlPosition == .left {
                    pageControl?.frame = CGRect(x: -(UIScreen.main.bounds.width - (pointSize?.width)! - pageControlLeadingOrTrialingContact) * 0.5, y: self.height - pageControlBottom, width: UIScreen.main.bounds.width, height: 10)
                } else {
                    pageControl?.frame = CGRect(x: (UIScreen.main.bounds.width - (pointSize?.width)! - pageControlLeadingOrTrialingContact) * 0.5, y: self.height - pageControlBottom, width: UIScreen.main.bounds.width, height: 10)
                }
            }
        } else {
            var y = self.height - pageControlBottom

            // pill
            if customPageControlStyle == .pill {
                y += 5
            }

            let oldFrame = customPageControl?.frame
            switch pageControlPosition {
            case .left:
                customPageControl?.frame = CGRect(x: pageControlLeadingOrTrialingContact * 0.5, y: y, width: (oldFrame?.size.width)!, height: 10)
            case.right:
                customPageControl?.frame = CGRect(x: UIScreen.main.bounds.width - (oldFrame?.size.width)! - pageControlLeadingOrTrialingContact * 0.5, y: y, width: (oldFrame?.size.width)!, height: 10)
            default:
                customPageControl?.frame = CGRect(x: (oldFrame?.origin.x)!, y: y, width: (oldFrame?.size.width)!, height: 10)
            }
        }

        if collectionView.contentOffset.x == 0 && totalItemsCount > 0 {
            var targetIndex = 0
            if infiniteLoop {
                targetIndex = totalItemsCount / 2
            }
            collectionView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: position, animated: false)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension SwipImgAreaView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if imagePaths.isEmpty { return }
        let indexOnPageControl = pageControlIndexWithCurrentCellIndex(index: currentIndex())
        if customPageControlStyle == .none || customPageControlStyle == .system || customPageControlStyle == .image {
            pageControl?.currentPage = indexOnPageControl
        } else {
            var progress: CGFloat = 999
            // 方向
            if scrollDirection == .horizontal {
                var currentOffsetX = scrollView.contentOffset.x - (CGFloat(totalItemsCount) * scrollView.frame.size.width) / 2
                if currentOffsetX < 0 {
                    if currentOffsetX >= -scrollView.frame.size.width {
                        currentOffsetX = CGFloat(indexOnPageControl) * scrollView.frame.size.width
                    } else if currentOffsetX <= -maxSwipeSize {
                        collectionView.scrollToItem(at: IndexPath(item: Int(totalItemsCount / 2), section: 0), at: position, animated: false)
                    } else {
                        currentOffsetX = maxSwipeSize + currentOffsetX
                    }
                }
                if currentOffsetX >= CGFloat(self.imagePaths.count) * scrollView.frame.size.width && infiniteLoop {
                    collectionView.scrollToItem(at: IndexPath(item: Int(totalItemsCount / 2), section: 0), at: position, animated: false)
                }
                progress = currentOffsetX / scrollView.frame.size.width
            } else if scrollDirection == .vertical {
                var currentOffsetY = scrollView.contentOffset.y - (CGFloat(totalItemsCount) * scrollView.frame.size.height) / 2
                if currentOffsetY < 0 {
                    if currentOffsetY >= -scrollView.frame.size.height {
                        currentOffsetY = CGFloat(indexOnPageControl) * scrollView.frame.size.height
                    } else if currentOffsetY <= -maxSwipeSize {
                        collectionView.scrollToItem(at: IndexPath(item: Int(totalItemsCount / 2), section: 0), at: position, animated: false)
                    } else {
                        currentOffsetY = maxSwipeSize + currentOffsetY
                    }
                }
                if currentOffsetY >= CGFloat(self.imagePaths.count) * scrollView.frame.size.height && infiniteLoop {
                    collectionView.scrollToItem(at: IndexPath(item: Int(totalItemsCount / 2), section: 0), at: position, animated: false)
                }
                progress = currentOffsetY / scrollView.frame.size.height
            }

            if progress == 999 {
                progress = CGFloat(indexOnPageControl)
            }
            // progress
            if customPageControlStyle == .fill {
                (customPageControl as? SwipImgAreaPageControl)?.progress = progress
            } else if customPageControlStyle == .pill {
                (customPageControl as? SwipImgAreaPillPageControl)?.progress = progress
            } else if customPageControlStyle == .snake {
                (customPageControl as? SwipImgAreaSnakePageControl)?.progress = progress
            }
        }
    }

    // MARK: ScrollView Begin Drag
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if autoScroll {
            invalidateTimer()
        }
    }

    // MARK: ScrollView End Drag
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if autoScroll {
            setupTimer()
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension SwipImgAreaView: UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalItemsCount == 0 ? 1:totalItemsCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SwipImgAreaCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? SwipImgAreaCell ?? SwipImgAreaCell()
        // Setting
        cell.titleFont = font
        cell.titleLabelTextColor = textColor
        cell.titleBackViewBackgroundColor = titleBackgroundColor
        cell.titleLines = numberOfLines

        // Leading
        cell.titleLabelLeading = titleLeading

        // Only Title
        if isOnlyTitle && !(titles.isEmpty) {
            cell.titleLabelHeight = cellHeight
            let itemIndex = pageControlIndexWithCurrentCellIndex(index: indexPath.item)
            cell.title = titles[itemIndex]
        } else {
            // Mode
            if let imageViewContentMode = imageViewContentMode {
                cell.imageView.contentMode = imageViewContentMode
            }

            // 0==count 占位图
            if imagePaths.isEmpty {
                cell.imageView.image = coverViewImage
            } else {
                let itemIndex = pageControlIndexWithCurrentCellIndex(index: indexPath.item)
                let imagePath = imagePaths[itemIndex]

                // 根据imagePath，来判断是网络图片还是本地图
                if imagePath.hasPrefix("http") || imagePath.hasPrefix("https") {
                    cell.imageView.kf.setImage(with: URL(string: imagePath), placeholder: placeHolderImage, options: nil, progressBlock: nil, completionHandler: nil)
                } else {
                    if let image = UIImage(named: imagePath) {
                        cell.imageView.image = image
                    } else {
                        cell.imageView.image = UIImage(contentsOfFile: imagePath)
                    }
                }

                // 对冲数据判断
                if itemIndex <= titles.count - 1 {
                    cell.title = titles[itemIndex]
                } else {
                    cell.title = ""
                }
            }
        }
        return cell
    }

    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let didSelectItemAtIndexPath = didSelectItemAtIndex {
            didSelectItemAtIndexPath(pageControlIndexWithCurrentCellIndex(index: indexPath.item))
        }
    }

    func pageControlIndexWithCurrentCellIndex(index: Int) -> (Int) {
        if imagePaths.isEmpty {
            return 0
        }
        return Int(index % imagePaths.count)
    }
}
