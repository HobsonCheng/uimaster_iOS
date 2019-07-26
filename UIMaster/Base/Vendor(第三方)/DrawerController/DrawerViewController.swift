//
//  DrawerViewController.swift
//  Pods
//
//  Created by Millman YANG on 2017/3/30.
//
//

import UIKit

// only check segue are (main/segue) ,
 class DrawerSegue: UIStoryboardSegue {
    override  func perform() {}
}

 enum SliderMode {
    case frontWidth(fWidth: CGFloat)
    case frontWidthRate(fWidthR: CGFloat)
    case rearWidth(rWidth: CGFloat)
    case rearWidthRate(rWidthR: CGFloat)
    case none
}

 enum ShowMode {
    case left
    case right
    case main
}
 typealias ConfigBlock = ((_ vc: UIViewController) -> Void)?
struct SegueParams {
    var type: String
    var params: Any?
    var config: ConfigBlock
}

class DrawerViewController: BaseNameVC {
    var statusBarHidden = false {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
            //            UIApplication.shared.statusBarView?.isHidden = true
        }
    }
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }

     var isShowMask = false {
        didSet {
            self.maskView.isHidden = !isShowMask
        }
    }

    fileprivate lazy var maskView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.alpha = 0.0
        view.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        return view
    }()
    lazy var containerView: UIView = {
        let view = UIView()
        self.view.addSubview(view)

        view.mLayout.constraint { maker in
            maker.set(type: .leading, value: 0)
            maker.set(type: .top, value: 0)
            maker.set(type: .bottom, value: 0)
            maker.set(type: .width, value: self.view.frame.width)
        }
        return view
    }()

     private(set) var sliderMap = [SliderLocation: SliderManager]()
    var currentManager: SliderManager?

    override  func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let safeSegue = segue as? DrawerSegue,
            let segueParams = sender as? SegueParams {
            if let config = segueParams.config {
                config(segue.destination)
            }
            switch segueParams.type {
            case "main":
                self.set(main: safeSegue.destination)
            case "left":
                if let slideMode = segueParams.params as? SliderMode {
                    self.set(left: safeSegue.destination as? NaviBarVC ?? NaviBarVC(), mode: slideMode)
                }
            case "right":
                if let slideMode = segueParams.params as? SliderMode {
                    self.set(right: safeSegue.destination as? NaviBarVC ?? NaviBarVC(), mode: slideMode)
                }
            default:
                break
            }
        }
    }

     var main: UIViewController? {
        willSet {
            main?.removeFromParentViewController()
            main?.didMove(toParentViewController: nil)
            main?.view.removeFromSuperview()
            main?.view.subviews.forEach({ $0.removeFromSuperview() })
            main?.endAppearanceTransition()
        } didSet {
            if let new = main {
                new.view.shadow(opacity: 0.4, radius: 5.0)
                new.view.addGestureRecognizer(mainPan)
                new.view.translatesAutoresizingMaskIntoConstraints = false
                containerView.insertSubview(new.view, belowSubview: maskView)
                new.view.mLayout.constraint { maker in
                    maker.set(type: .leading, value: 0)
                    maker.set(type: .top, value: 0)
                    maker.set(type: .bottom, value: 0)
                    maker.set(type: .trailing, value: 0)
                }
                self.view.layoutIfNeeded()
                self.addChildViewController(new)
            }
        }
    }

     lazy var maskPan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(DrawerViewController.panAction(pan:)))
        return pan
    }()
    lazy var mainPan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(DrawerViewController.panAction(pan:)))
        return pan
    }()

     var draggable: Bool = true {
        didSet {
            mainPan.isEnabled = draggable
            sliderMap.forEach { $0.1.sliderPan.isEnabled = draggable }
        }
    }

     override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        self.containerView.mLayout.update { make in
            make.constraintMap[.width]?.constant = size.width
        }

        sliderMap.forEach { _, value in
            value.viewRotation(size: size)
        }
    }

     func set(left: NaviBarVC, mode: SliderMode) {
        sliderMap[.left] = SliderManager(drawer: self)
        sliderMap[.left]?.showChangeBlock = { [weak self] _ in
            self?.checkShowResult()
        }
        sliderMap[.left]?.addSlider(slider: left, location: .left, mode: mode)
        self.view.layoutIfNeeded()
    }

     func set(right: NaviBarVC, mode: SliderMode) {
        sliderMap[.right] = SliderManager(drawer: self)
        sliderMap[.right]?.addSlider(slider: right, location: .right, mode: mode)
        sliderMap[.right]?.showChangeBlock = { [weak self] _ in
            self?.checkShowResult()
        }

        self.view.layoutIfNeeded()
    }

     func setLeft(mode: SliderMode) {
        sliderMap[.left]?.mode = mode
        self.view.layoutIfNeeded()
    }

     func setRight(mode: SliderMode) {
        sliderMap[.right]?.mode = mode
        self.view.layoutIfNeeded()
    }

     func set(main: UIViewController) {
        self.main = main
        self.view.layoutIfNeeded()
    }

     func showLeftSlider(isShow: Bool) {
        sliderMap[.left]?.show(isShow: isShow)
    }

     func showRightSlider(isShow: Bool) {
        sliderMap[.right]?.show(isShow: isShow)
    }

     func getManager(direction: SliderLocation) -> SliderManager? {
        return sliderMap[direction]
    }

     func setMainWith(identifier: String) {
        self.setController(identifier: identifier, params: SegueParams(type: "main", params: nil, config: nil))
    }

     func setMain(identifier: String, config: ConfigBlock) {
        self.setController(identifier: identifier, params: SegueParams(type: "main", params: nil, config: config))
    }

     func setLeftWith(identifier: String, mode: SliderMode) {
        self.setController(identifier: identifier, params: SegueParams(type: "left", params: mode, config: nil))
    }

     func setLeft(identifier: String, mode: SliderMode, config: ConfigBlock) {
        self.setController(identifier: identifier, params: SegueParams(type: "left", params: mode, config: config))
    }

     func setRightWith(identifier: String, mode: SliderMode) {
        self.setController(identifier: identifier, params: SegueParams(type: "right", params: mode, config: nil))
    }

     func setRightWith(identifier: String, mode: SliderMode, config: ConfigBlock) {
        self.setController(identifier: identifier, params: SegueParams(type: "right", params: mode, config: config))
    }

    fileprivate func setController(identifier: String, params: SegueParams ) {
        self.performSegue(withIdentifier: identifier, sender: params)
    }

    fileprivate func checkShowResult() {
        var isShow = false
        sliderMap.forEach {
            if $0.value.isShow {
                isShow = true
            }
        }
        UIView.animate(withDuration: 0.15) { [weak self] in
            self?.maskView.alpha = (isShow) ? 1.0 : 0.0
        }
    }

     override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if touches.first?.view == maskView {
            sliderMap.forEach {
                $0.value.show(isShow: false)
            }
        }
    }
}

extension DrawerViewController {
    @objc func panAction(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            currentManager = self.searchCurrentManagerWith(pan: pan)
            currentManager?.panAction(pan: pan)
        case .changed:
            currentManager?.panAction(pan: pan)
        case .cancelled, .ended :
            currentManager?.panAction(pan: pan)
            currentManager = nil
        default:
            break
        }
    }

    fileprivate func searchCurrentManagerWith(pan: UIPanGestureRecognizer) -> SliderManager? {
        var manager: SliderManager?
        let rect = self.view.bounds.insetBy(dx: 40, dy: 40)
        let first = pan.location(in: pan.view)
        //Edge
        if !rect.contains(first) {
            sliderMap.forEach({ _, value in
                if let slider = manager?.slider?.view {
                    let pre = first.distance(point: slider.center)
                    let current = first.distance(point: value.slider?.view.center)

                    if current < pre {
                        manager = value
                    }
                } else {
                    manager = value
                }
            })
        } else {
            manager = nil
        }
        return manager
    }

    override  func viewDidLoad() {
        super.viewDidLoad()

        containerView.addSubview(maskView)
        maskView.mLayout.constraint { maker in
            maker.set(type: .leading, value: 0)
            maker.set(type: .trailing, value: 0)
            maker.set(type: .top, value: 0)
            maker.set(type: .bottom, value: 0)
        }
        maskView.addGestureRecognizer(maskPan)
    }
}
