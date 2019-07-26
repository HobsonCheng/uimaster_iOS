//
//  SwiftIntroView.swift
//  UIDS
//
//  Created by one2much on 2018/2/6.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

// 代理
@objc protocol SwiftIntroViewDelegate {
    func doneButtonClick()
}

class SwiftIntroView: UIView, UIScrollViewDelegate {
    fileprivate var scrollView: UIScrollView!
    fileprivate var pageControl: UIPageControl!
    fileprivate var doneButton: UIButton!
    fileprivate var openButton: UIButton!
    fileprivate let picCount = GlobalConfigTool.shared.globalData?.global?.welcome ?? 0
    weak var delegate: SwiftIntroViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        //注意逻辑关系，有些视图依赖前一个视图而存在
        self.initScrollView()
        self.initPageViews()
        self.initPageControl()
        self.initDoneButton()
    }

    //初始化 scrollView
    func initScrollView() {
        scrollView = UIScrollView(frame: self.frame)
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.bounces = false

        scrollView.contentSize = CGSize(width: self.frame.size.width * CGFloat(picCount), height: scrollView.frame.size.height)
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView)
    }

    //初始化页面视图 - 可根据需要自己增加控件
    func initPageViews() {
        let originW = self.frame.size.width

        let global = GlobalConfigTool.shared.globalData?.global
        let countNum = global?.welcome ?? 0
        for index in 0..<countNum {
            let imageView = UIImageView(frame: self.frame)
            imageView.frame.origin.x = originW * CGFloat(index)
            imageView.image = UIImage(named: "guiImage\(index + 1).png")
            self.scrollView.addSubview(imageView)
        }
    }

    //初始化 pageControl
    func initPageControl() {
        if picCount == 1 { return }
        pageControl = UIPageControl(frame: CGRect(x: 0, y: self.frame.size.height - kTabBarHeight - 15, width: self.frame.size.width, height: 10))
        pageControl.currentPageIndicatorTintColor = UIColor(red: 33 / 255, green: 150 / 255, blue: 243 / 255, alpha: 0.8)
        pageControl.numberOfPages = 3
        self.addSubview(pageControl)
    }

    //初始化 DoneButton
    func initDoneButton() {
        doneButton = UIButton(frame: CGRect(x: 0, y: self.frame.size.height - kTabBarHeight, width: self.frame.size.width, height: kTabBarHeight))
        doneButton.setTitle("跳过", for: UIControlState.normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        doneButton.backgroundColor = UIColor(red: 233 / 255, green: 233 / 255, blue: 233 / 255, alpha: 0.5)
        doneButton.isHidden = picCount == 1 ? true : false
        openButton = UIButton(frame: CGRect(x: (kScreenW - 200) / 2, y: self.frame.size.height - kTabBarHeight, width: 200, height: 40))
        openButton.setTitle("进入APP", for: .normal)
        openButton.setTitleColor(.gray, for: .normal)
        openButton.layer.cornerRadius = 5
        openButton.layer.borderWidth = 1
        openButton.layer.borderColor = UIColor.gray.cgColor
        openButton.isHidden = picCount == 1 ? false : true
        openButton.rx.tap.do(onNext: {
            self.delegate?.doneButtonClick()
        }).asObservable().subscribe().disposed(by: rx.disposeBag)
        //增加点击事件并交给代理去完成
        doneButton.rx.tap.do(onNext: {
            self.delegate?.doneButtonClick()
        }).asObservable().subscribe().disposed(by: rx.disposeBag)
        self.addSubview(doneButton)
        self.addSubview(openButton)
    }

    //实现 UIScrollViewDelegate 方法
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = self.frame.width
        let pageFraction = self.scrollView.contentOffset.x / pageWidth
        self.pageControl.currentPage = Int(roundf(Float(pageFraction)))
        let globalConfig = GlobalConfigTool.shared.globalData?.global
        self.doneButton.isHidden = self.pageControl.currentPage + 1 == globalConfig?.welcome ? true : false
        self.openButton.isHidden = self.pageControl.currentPage + 1 == globalConfig?.welcome ? false : true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
