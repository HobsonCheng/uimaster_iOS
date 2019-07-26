//
//  PageController.swift
//  PageController
//
//  Created by Mark on 15/10/20.
//  Copyright © 2015年 Wecan Studio. All rights reserved.
//

import UIKit

enum CachePolicy: Int {
    case noLimit = 0
    case lowMemory = 1
    case balanced = 3
    case high = 5
}

enum PreloadPolicy: Int {
    case never = 0
    case neighbour = 1
    case near = 2
}

let WMPageControllerDidMovedToSuperViewNotification = "WMPageControllerDidMovedToSuperViewNotification"
let WMPageControllerDidFullyDisplayedNotification = "WMPageControllerDidFullyDisplayedNotification"

@objc protocol PageControllerDataSource: NSObjectProtocol {
    @objc optional func numberOfControllersInPageController(_ pageController: PageController) -> Int
    @objc optional func pageController(_ pageController: PageController, viewControllerAtIndex index: Int) -> UIViewController
    @objc optional func pageController(_ pageController: PageController, titleAtIndex index: Int) -> String
}

@objc protocol PageControllerDelegate: NSObjectProtocol {
    @objc optional func pageController(_ pageController: PageController, lazyLoadViewController viewController: UIViewController, withInfo info: NSDictionary)
    @objc optional func pageController(_ pageController: PageController, willCachedViewController viewController: UIViewController, withInfo info: NSDictionary)
    @objc optional func pageController(_ pageController: PageController, willEnterViewController viewController: UIViewController, withInfo info: NSDictionary)
    @objc optional func pageController(_ pageController: PageController, didEnterViewController viewController: UIViewController, withInfo info: NSDictionary)
}

class ContentView: UIScrollView {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let wrapperView = NSClassFromString("UITableViewWrapperView"), let otherGestureView = otherGestureRecognizer.view else { return false }

        if otherGestureView.isKind(of: wrapperView) && (otherGestureRecognizer is UIPanGestureRecognizer) {
            return true
        }
        return false
    }
}

class PageController: NaviBarVC, UIScrollViewDelegate, MenuViewDelegate, MenuViewDataSource, PageControllerDelegate, PageControllerDataSource {
    weak var dataSource: PageControllerDataSource?
    weak var delegate: PageControllerDelegate?

    var viewControllerClasses: [UIViewController.Type]?
    var titles: [String]?
    var values: NSArray?
    var keys: [String]?
    var progressColor: UIColor?
    var progressHeight: CGFloat = 2.0
    var itemMargin: CGFloat = 0.0
    var menuViewStyle = MenuViewStyle.default
    var titleFontName: String?
    var pageAnimatable = false
    var postNotification = false
    var bounces = false
    var showOnNavigationBar = false
    /// 导航栏显示在底部
    var showOnBottom = false
    var startDragging = false
    var titleSizeSelected: CGFloat = 18.0
    var titleSizeNormal: CGFloat = 15.0
    var menuHeight: CGFloat = 44
    var menuItemWidth: CGFloat = 95.0
    weak var contentView: ContentView?
    weak var menuView: MenuView?
    weak var tabbarView: MainTabBarView?
    var imgUrl: String?
    var itemsWidths: [CGFloat]?
    var customVcHeight: CGFloat = 0
    var customVcY: CGFloat = 0

    fileprivate(set) var currentViewController: UIViewController?

    var selectedIndex: Int {
        set {
            _selectedIndex = newValue
            menuView?.selectItemAtIndex(newValue)
        }
        get { return _selectedIndex }
    }

    var menuViewContentMargin: CGFloat = 0.0 {
        didSet {
            guard let menu = menuView else { return }
            menu.contentMargin = oldValue
        }
    }

    var viewFrame = CGRect() {
        didSet {
            if let _ = menuView {
                hasInit = false
                viewDidLayoutSubviews()
            }
        }
    }

    var itemsMargins: [CGFloat]?
    var preloadPolicy: PreloadPolicy = .never

    var cachePolicy: CachePolicy = .noLimit {
        didSet { memCache.countLimit = cachePolicy.rawValue }
    }

    lazy var titleColorSelected = UIColor(red: 168.0 / 255.0, green: 20.0 / 255.0, blue: 4 / 255.0, alpha: 1.0)
    lazy var titleColorNormal = UIColor.black
    lazy var menuBGColor = UIColor.clear

    override var edgesForExtendedLayout: UIRectEdge {
        didSet {
            hasInit = false
            viewDidLayoutSubviews()
        }
    }

    // MARK: - Private vars
    fileprivate var memoryWarningCount = 0
    fileprivate var viewHeight: CGFloat = 0.0
    fileprivate var viewWidth: CGFloat = 0.0
    fileprivate var viewX: CGFloat = 0.0
    fileprivate var viewY: CGFloat = 0.0
    fileprivate var _selectedIndex = 0
    fileprivate var targetX: CGFloat = 0.0
    fileprivate var superviewHeight: CGFloat = 0.0
    fileprivate var hasInit = false
    fileprivate var shouldNotScroll = false
    fileprivate var initializedIndex = -1
    fileprivate var controllerCount  = -1

    fileprivate var childControllersCount: Int {
        if controllerCount == -1 {
            if let count = dataSource?.numberOfControllersInPageController?(self) {
                controllerCount = count
            } else {
                controllerCount = (viewControllerClasses?.count ?? 0)
            }
        }
        return controllerCount
    }

    fileprivate lazy var displayingControllers = NSMutableDictionary()
    fileprivate lazy var memCache = NSCache<NSNumber, UIViewController>()
    fileprivate lazy var childViewFrames = [CGRect]()

    // MARK: - Life cycle
     convenience init(vcClasses: [UIViewController.Type], theirTitles: [String]) {
        self.init()
        assert(vcClasses.count == theirTitles.count, "`vcClasses.count` must equal to `titles.count`")
        titles = theirTitles
        viewControllerClasses = vcClasses
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .white
        guard childControllersCount > 0 else { return }

        calculateSize()
        addScrollView()
        addViewControllerAtIndex(_selectedIndex)
        currentViewController = displayingControllers[_selectedIndex] as? UIViewController
        addMenuView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard childControllersCount > 0 else { return }

        let oldSuperviewHeight = superviewHeight
        superviewHeight = view.frame.size.height
        guard (!hasInit || superviewHeight != oldSuperviewHeight) && (view.window != nil) else { return }

        calculateSize()
        adjustScrollViewFrame()
        adjustMenuViewFrame()
        removeSuperfluousViewControllersIfNeeded()
        currentViewController?.view.frame = childViewFrames[_selectedIndex]
        hasInit = true
        view.layoutIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard childControllersCount > 0 else { return }
        postFullyDisplayedNotificationWithIndex(_selectedIndex)
        didEnterController(currentViewController!, atIndex: _selectedIndex)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        memoryWarningCount += 1
        cachePolicy = CachePolicy.lowMemory
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(PageController.growCachePolicyAfterMemoryWarning), object: nil)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(PageController.growCachePolicyToHigh), object: nil)
        memCache.removeAllObjects()
        if memoryWarningCount < 3 {
            perform(#selector(PageController.growCachePolicyAfterMemoryWarning), with: nil, afterDelay: 3.0, inModes: [RunLoopMode.commonModes])
        }
    }

    // MARK: - Reload
    func reloadData() {
        clearDatas()
        resetScrollView()
        memCache.removeAllObjects()
        viewDidLayoutSubviews()
        resetMenuView()
    }

    // MARK: - Update Title
    func updateTitle(_ title: String, atIndex index: Int) {
        menuView?.updateTitle(title, atIndex: index, andWidth: false)
    }

    func updateTitle(_ title: String, atIndex index: Int, andWidth width: CGFloat) {
        if var widths = itemsWidths {
            guard index < widths.count else {
                return
            }
            widths[index] = width
            itemsWidths = widths
        } else {
            var widths = [CGFloat]()
            for idx in 0 ..< childControllersCount {
                let newWidth = (idx == index) ? width : menuItemWidth
                widths.append(newWidth)
            }
            itemsWidths = widths
        }
        menuView?.updateTitle(title, atIndex: index, andWidth: true)
    }

    // MARK: - Data Source
    fileprivate func initializeViewControllerAtIndex(_ index: Int) -> UIViewController {
        if let viewController = dataSource?.pageController?(self, viewControllerAtIndex: index) {
            return viewController
        }
        return viewControllerClasses![index].init()
    }

    fileprivate func titleAtIndex(_ index: Int) -> String {
        if let titleAtIndex = dataSource?.pageController?(self, titleAtIndex: index) {
            return titleAtIndex
        }
        return titles![index]
    }

    // MARK: - Delegate
    fileprivate func infoWithIndex(_ index: Int) -> NSDictionary {
        let title = titleAtIndex(index)
        return ["title": title, "index": index]
    }

    fileprivate func willCachedController(_ vc: UIViewController, atIndex index: Int) {
        guard childControllersCount > 0 else { return }
        delegate?.pageController?(self, willCachedViewController: vc, withInfo: infoWithIndex(index))
    }

    fileprivate func willEnterController(_ vc: UIViewController, atIndex index: Int) {
        guard childControllersCount > 0 else { return }
        delegate?.pageController?(self, willEnterViewController: vc, withInfo: infoWithIndex(index))
    }

    fileprivate func didEnterController(_ vc: UIViewController, atIndex index: Int) {
        guard childControllersCount > 0 else { return }

        let info = infoWithIndex(index)

        delegate?.pageController?(self, didEnterViewController: vc, withInfo: info)

        if initializedIndex == index {
            delegate?.pageController?(self, lazyLoadViewController: vc, withInfo: info)
            initializedIndex = -1
        }

        if preloadPolicy == .never { return }
        var start = 0
        var end = childControllersCount - 1
        if index > preloadPolicy.rawValue {
            start = index - preloadPolicy.rawValue
        }

        if childControllersCount - 1 > preloadPolicy.rawValue + index {
            end = index + preloadPolicy.rawValue
        }

        for idx in start ... end {
            if memCache.object(forKey: NSNumber(integerLiteral: idx)) == nil && displayingControllers[idx] == nil {
                addViewControllerAtIndex(idx)
                postMovedToSuperViewNotificationWithIndex(idx)
            }
        }
        _selectedIndex = index
    }

    // MARK: - Private funcs
    fileprivate func clearDatas() {
        controllerCount = -1
        hasInit = false
        _selectedIndex = _selectedIndex < childControllersCount ? _selectedIndex : childControllersCount - 1
        for viewController in displayingControllers.allValues {
            if let viewControl = viewController as? UIViewController {
                viewControl.view.removeFromSuperview()
                viewControl.willMove(toParentViewController: nil)
                viewControl.removeFromParentViewController()
            }
        }
        memoryWarningCount = 0
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(PageController.growCachePolicyAfterMemoryWarning), object: nil)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(PageController.growCachePolicyToHigh), object: nil)
        currentViewController = nil
        displayingControllers.removeAllObjects()
        calculateSize()
    }

    fileprivate func resetScrollView() {
        contentView?.removeFromSuperview()
        addScrollView()
        addViewControllerAtIndex(_selectedIndex)
        currentViewController = displayingControllers[_selectedIndex] as? UIViewController
    }

    fileprivate func calculateSize() {
        var navBarHeight: CGFloat = 0 // (navigationController != nil) ? navigationController!.navigationBar.frame.maxY : 0
        if let navBar = self.naviBarHead {
            navBarHeight = navBar.height
        }
        //        let tabBar = tabBarController?.tabBar ?? (navigationController?.toolbar ?? nil)
        //        let height = (tabBar != nil && tabBar?.isHidden != true) ? tabBar!.frame.height : 0
        var tabBarHeight: CGFloat = 0 //(hidesBottomBarWhenPushed == true) ? 0 : height

        let mainWindow = UIApplication.shared.delegate?.window!
        let absoluteRect = view.superview?.convert(view.frame, to: mainWindow)
        if let rect = absoluteRect {
            navBarHeight -= rect.origin.y
            tabBarHeight -= mainWindow!.frame.height - rect.maxY
        }
        tabBarHeight = isHomePage ? GlobalConfigTool.shared.tabbar?.styles?.heightTabBar ?? 0 : 0
        tabBarHeight += kIsiPhoneX ? kiPhoneXBottomH : 0
        viewX = viewFrame.origin.x
        viewY = viewFrame.origin.y
        if viewFrame == CGRect.zero {
            viewWidth = view.frame.size.width
            viewHeight = view.frame.size.height - menuHeight - navBarHeight - tabBarHeight
            viewY += navBarHeight
        } else {
            viewWidth = viewFrame.size.width
            viewHeight = viewFrame.size.height - menuHeight
        }
        if let naviBar = self.naviBar {
            if showOnNavigationBar && !naviBar.isHidden {
                viewHeight += menuHeight
            }
        }
        if customVcHeight > 0 {
            viewHeight = customVcHeight
        }
        childViewFrames.removeAll()
        for index in 0 ..< childControllersCount {
            let viewControllerFrame = CGRect(x: CGFloat(index) * viewWidth, y: 0, width: viewWidth, height: viewHeight)
            childViewFrames.append(viewControllerFrame)
        }
    }

    fileprivate func addScrollView() {
        let scrollView = ContentView()
        scrollView.scrollsToTop = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = bounces
        view.addSubview(scrollView)
        contentView = scrollView
    }
    private func createMainTabBarView() {
        //1.获取系统自带的标签栏视图的frame
        let tabBarFrame = CGRect(x: 0, y: kScreenH - kTabBarHeight, width: kScreenW, height: kTabBarHeight)
        //2.使用得到的frame，和plist数据创建自定义标签栏
        let tabbar = MainTabBarView(frame: tabBarFrame, tabBarConfig: self.pageModel?.tabBar)
        tabbarView = tabbar
        tabbarView?.delegate = self
        self.view.addSubview(tabbarView!)
    }
    fileprivate func addMenuView() {
        if showOnBottom {
            createMainTabBarView()
            return
        }

        var menuY = viewY
        if showOnNavigationBar {
            menuY = kNavigationBarHeight - 44
        }

        let menuViewFrame = CGRect(x: viewX, y: menuY, width: viewWidth, height: menuHeight)
        let menu = MenuView(frame: menuViewFrame)
        menu.delegate = self
        menu.dataSource = self
        menu.backgroundColor = menuBGColor
        menu.normalSize = titleSizeNormal
        menu.selectedSize = titleSizeSelected
        menu.normalColor = titleColorNormal
        menu.selectedColor = titleColorSelected
        menu.style = menuViewStyle
        menu.progressHeight = progressHeight
        menu.progressColor = progressColor
        menu.fontName = titleFontName
        menu.contentMargin = menuViewContentMargin
        if let safeUrl = imgUrl {
            let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: menu.frame.width, height: menu.frame.height))
            imgView.kf.setImage(with: URL(string: safeUrl))
            menu.addSubview(imgView)
            menu.sendSubview(toBack: imgView)
        }
        if showOnNavigationBar {
            if let nav = self.naviBar {
                nav.titleView = menu
            }
        } else {
            view.addSubview(menu)
        }
        menuView = menu
    }

    fileprivate func postMovedToSuperViewNotificationWithIndex(_ index: Int) {
        guard postNotification else { return }
        let info = ["index": index, "title": titleAtIndex(index)] as [String: Any]
        NotificationCenter.default.post(name: Notification.Name(rawValue: WMPageControllerDidMovedToSuperViewNotification), object: info)
    }

    fileprivate func postFullyDisplayedNotificationWithIndex(_ index: Int) {
        guard postNotification else { return }
        let info = ["index": index, "title": titleAtIndex(index)] as [String: Any]
        NotificationCenter.default.post(name: Notification.Name(rawValue: WMPageControllerDidFullyDisplayedNotification), object: info)
    }

    fileprivate func layoutChildViewControllers() {
        let currentPage = Int(contentView!.contentOffset.x / viewWidth)
        let start = currentPage == 0 ? currentPage : (currentPage - 1)
        let end = (currentPage == childControllersCount - 1) ? currentPage : (currentPage + 1)
        for index in start ... end {
            let viewControllerFrame = childViewFrames[index]
            var vc = displayingControllers.object(forKey: index)
            if inScreen(viewControllerFrame) {
                if vc == nil {
                    vc = memCache.object(forKey: NSNumber(integerLiteral: index))
                    if let viewController = vc as? UIViewController {
                        addCachedViewController(viewController, atIndex: index)
                    } else {
                        addViewControllerAtIndex(index)
                    }
                    postMovedToSuperViewNotificationWithIndex(index)
                }
            } else {
                if let viewController = vc as? UIViewController {
                    removeViewController(viewController, atIndex: index)
                }
            }
        }
    }

    fileprivate func removeSuperfluousViewControllersIfNeeded() {
        for (index, vc) in displayingControllers {
            let frame = childViewFrames[(index as AnyObject).intValue]
            if inScreen(frame) == false {
                guard let UIvc = vc as? UIViewController else {
                    return
                }
                removeViewController(UIvc, atIndex: (index as AnyObject).intValue)
            }
        }
    }

    fileprivate func addCachedViewController(_ viewController: UIViewController, atIndex index: Int) {
        addChildViewController(viewController)
        viewController.view.frame = childViewFrames[index]
        viewController.didMove(toParentViewController: self)
        contentView?.addSubview(viewController.view)
        willEnterController(viewController, atIndex: index)
        displayingControllers.setObject(viewController, forKey: index as NSCopying)
    }

    fileprivate func addViewControllerAtIndex(_ index: Int) {
        initializedIndex = index
        let viewController = initializeViewControllerAtIndex(index)
        if let optionalKeys = keys {
            viewController.setValue(values?[index], forKey: optionalKeys[index])
        }
        addChildViewController(viewController)
        let viewFrame = !(childViewFrames.isEmpty) ? childViewFrames[index] : view.frame
        if let vc = viewController as? AssembleVC {
            vc.pageVCViewHeight = viewFrame.height
        }
        viewController.view.frame = viewFrame
        viewController.didMove(toParentViewController: self)
        contentView?.addSubview(viewController.view)
        willEnterController(viewController, atIndex: index)
        displayingControllers.setObject(viewController, forKey: index as NSCopying)
    }

    fileprivate func removeViewController(_ viewController: UIViewController, atIndex index: Int) {
        viewController.view.removeFromSuperview()
        viewController.willMove(toParentViewController: nil)
        viewController.removeFromParentViewController()
        displayingControllers.removeObject(forKey: index)
        if memCache.object(forKey: NSNumber(integerLiteral: index)) == nil {
            willCachedController(viewController, atIndex: index)
            memCache.setObject(viewController, forKey: NSNumber(integerLiteral: index))
        }
    }

    fileprivate func inScreen(_ frame: CGRect) -> Bool {
        let x = frame.origin.x
        let screenWidth = contentView!.frame.size.width
        let contentOffsetX = contentView!.contentOffset.x
        if (frame.maxX > contentOffsetX) && (x - contentOffsetX < screenWidth) {
            return true
        }
        return false
    }

    fileprivate func resetMenuView() {
        if menuView == nil {
            addMenuView()
            return
        }
        menuView?.reload()
        guard selectedIndex != 0 else { return }
        menuView?.selectItemAtIndex(selectedIndex)
        view.bringSubview(toFront: menuView!)
    }

    @objc fileprivate func growCachePolicyAfterMemoryWarning() {
        cachePolicy = CachePolicy.balanced
        perform(#selector(PageController.growCachePolicyToHigh), with: nil, afterDelay: 2.0, inModes: [RunLoopMode.commonModes])
    }

    @objc fileprivate func growCachePolicyToHigh() {
        cachePolicy = CachePolicy.high
    }

    // MARK: - Adjust Frame
    fileprivate func adjustScrollViewFrame() {
        shouldNotScroll = true
        var scrollFrame = CGRect(x: viewX, y: viewY + menuHeight, width: viewWidth, height: viewHeight)
        if showOnBottom {
            scrollFrame.origin.y = viewY
            contentView?.frame = scrollFrame
        } else {
            scrollFrame.origin.y -= showOnNavigationBar ? menuHeight : 0
            contentView?.frame = scrollFrame
        }
        contentView?.contentSize = CGSize(width: CGFloat(childControllersCount) * viewWidth, height: 0)
        contentView?.contentOffset = CGPoint(x: CGFloat(_selectedIndex) * viewWidth, y: 0)
        shouldNotScroll = false
    }

    fileprivate func adjustMenuViewFrame() {
        let realMenuHeight = menuHeight
        var menuX = viewX
        var menuY = viewY

        var rightWidth: CGFloat = 0.0
        let nav = self.naviBar
        if showOnNavigationBar && nav != nil {
            if let nav = nav {
                for subview in nav.subviews {
                    if !subview.isKind(of: NaviBarItem.self) {
                        continue
                    }

                    guard !subview.isKind(of: MenuView.self) && (subview.alpha != 0) && (subview.isHidden == false) else { continue }

                    let maxX = subview.frame.maxX
                    if maxX < viewWidth / 2 {
                        let leftWidth = maxX
                        menuX = menuX > leftWidth ? menuX : leftWidth
                    }
                    let minX = subview.frame.minX
                    if minX > viewWidth / 2 {
                        let width = viewWidth - minX
                        rightWidth = rightWidth > width ? rightWidth : width
                    }
                }
                menuY = kNavigationBarHeight - 44
            }
        }
        if showOnBottom {
            menuX = 0
            menuY = contentView?.frame.maxY ?? menuY
            menuView?.frame = CGRect(x: menuX, y: menuY, width: viewWidth, height: realMenuHeight)
        } else {
            let menuWidth = viewWidth - menuX - rightWidth
            menuView?.frame = CGRect(x: menuX, y: menuY, width: menuWidth, height: realMenuHeight)
        }
        menuView?.resetFrames()

        if _selectedIndex != 0 {
            menuView?.selectItemAtIndex(_selectedIndex)
        }
    }
}
extension PageController: MainTabBarDelegate {
    func didChooseItem(itemIndex: Int) {
//        for index in otherActionIndex {
//            if index == itemIndex{
//                VCController.push(self.modalVc, with: VCAnimationBottom.defaultAnimation())
//                return
//            }
//        }
//        kCurrentTabbarVC = self.viewControllers![itemIndex] as! NaviBarVC
//        self.selectedIndex = itemIndex
    }
}
// MARK: - MenuViewDelegate & DataSource
extension PageController {
    func menuView(_ menuView: MenuView, didSelectedIndex index: Int, fromIndex currentIndex: Int) {
        guard hasInit else { return }
        startDragging = false
        let targetPoint = CGPoint(x: CGFloat(index) * viewWidth, y: 0)
        contentView?.setContentOffset(targetPoint, animated: pageAnimatable)
        if !pageAnimatable {
            removeSuperfluousViewControllersIfNeeded()
            if let viewController = displayingControllers[index] as? UIViewController {
                removeViewController(viewController, atIndex: index)
            }
            layoutChildViewControllers()
            currentViewController = displayingControllers[index] as? UIViewController
            postFullyDisplayedNotificationWithIndex(index)
            _selectedIndex = index
            didEnterController(currentViewController!, atIndex: _selectedIndex)
        }
    }

    func menuView(_ menuView: MenuView, widthForItemAtIndex index: Int) -> CGFloat {
        if let widths = itemsWidths {
            return widths[index]
        }
        return menuItemWidth
    }

    func menuView(_ menuView: MenuView, itemMarginAtIndex index: Int) -> CGFloat {
        if let margins = itemsMargins {
            return margins[index]
        }
        return itemMargin
    }

    // MARK: MenuViewDataSource
    func numbersOfTitlesInMenuView(_ menuView: MenuView) -> Int {
        return childControllersCount
    }

    func menuView(_ menuView: MenuView, titleAtIndex index: Int) -> String {
        return titleAtIndex(index)
    }
}

// MARK: - UIScrollView Delegate
extension PageController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if shouldNotScroll || !hasInit { return }

        layoutChildViewControllers()
        guard startDragging else { return }
        var contentOffsetX = contentView!.contentOffset.x
        if contentOffsetX < 0.0 {
            contentOffsetX = 0.0
        }
        if contentOffsetX > (scrollView.contentSize.width - viewWidth) {
            contentOffsetX = scrollView.contentSize.width - viewWidth
        }
        let rate = contentOffsetX / viewWidth
        menuView?.slideMenuAtProgress(rate)

        if scrollView.contentOffset.y == 0 { return }
        var contentOffset = scrollView.contentOffset
        contentOffset.y = 0.0
        scrollView.contentOffset = contentOffset
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startDragging = true
        menuView?.isUserInteractionEnabled = false
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        menuView?.isUserInteractionEnabled = true
        _selectedIndex = Int(contentView!.contentOffset.x / viewWidth)
        removeSuperfluousViewControllersIfNeeded()
        currentViewController = displayingControllers[_selectedIndex] as? UIViewController
        postFullyDisplayedNotificationWithIndex(_selectedIndex)
        didEnterController(currentViewController!, atIndex: _selectedIndex)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        _selectedIndex = Int(contentView!.contentOffset.x / viewWidth)
        removeSuperfluousViewControllersIfNeeded()
        currentViewController = displayingControllers[_selectedIndex] as? UIViewController
        postFullyDisplayedNotificationWithIndex(_selectedIndex)
        didEnterController(currentViewController!, atIndex: _selectedIndex)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard decelerate == false else { return }
        menuView?.isUserInteractionEnabled = true
        let rate = targetX / viewWidth
        menuView?.slideMenuAtProgress(rate)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetX = targetContentOffset.pointee.x
    }
}
