//
//  BaseTableView.swift
//  UIDS
//
//  Created by one2much on 2018/1/26.
//  Copyright © 2018年 one2much. All rights reserved.
//

import EmptyDataSet_Swift
import MJRefresh
import UIKit

class BaseTableView: UITableView {
    fileprivate var isLoading = false
    var endRefreshCB: ((Bool) -> Void)?
    var parentVC: PageModuleAble?

    func configEmptyDataSet() {
        self.emptyDataSetSource = self
        self.emptyDataSetDelegate = self

        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }

    func configRefresh() {
        self.tableFooterView = UIView()
        self.backgroundColor = .clear
        //监听上拉结束
        self.endRefreshCB  = { [weak self] noMore in
            self?.isLoading = false
            if noMore {
                self?.mj_footer.endRefreshingWithNoMoreData()
            } else {
                self?.mj_footer.endRefreshing()
            }
        }
        // 顶部刷新
        let header = MJRefreshNormalHeader { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                if let header = self?.mj_header {
                    header.endRefreshing()
                }
            })
            if self?.parentVC != nil {
                self?.parentVC?.reloadViewData()
            }
            if let module = self as? PageModuleAble {
                module.reloadViewData()
            }
            for view in self?.tableHeaderView?.subviews ?? [] {
                if let subView = view as? PageModuleAble {
                    subView.reloadViewData()
                } else if let module = view.ownerVC() as? PageModuleAble {
                    module.reloadViewData()
                }
            }
        }

        header?.setTitle("下拉刷新", for: .idle)
        header?.setTitle("松开刷新", for: .pulling)
        header?.setTitle("正在刷新", for: .refreshing)
        header?.lastUpdatedTimeLabel.isHidden = true
        // 底部刷新
        let footer = MJRefreshAutoNormalFooter { [weak self] in
            if self?.isLoading == true {
                return
            }
            self?.isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                if let footer = self?.mj_footer {
                    footer.endRefreshing()
                }
            })
            if let module = self as? PageModuleAble {
                module.loadMoreData()
            } else if let module = self?.ownerVC() as? PageModuleAble {
                module.loadMoreData()
            }
        }
        footer?.setTitle("点击或上拉加载更多", for: .idle)
        footer?.setTitle("松开加载更多", for: .pulling)
        footer?.setTitle("加载中", for: .refreshing)
        footer?.setTitle("暂无更多数据", for: .noMoreData)
        //设置刷新文字的颜色
//        header?.stateLabel.textColor = self.pageModel?.fields?.refreshColor?.toColor() ?? .black
//        footer?.stateLabel.textColor = self.pageModel?.fields?.refreshColor?.toColor() ?? .black
        self.mj_header = header
        self.mj_footer = footer
    }
}

extension BaseTableView: EmptyDataSetSource, EmptyDataSetDelegate {
    @objc func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let text = "暂时没有数据"
        let font = UIFont.systemFont(ofSize: 22)
        let textColor = UIColor(hexString: "cccccc")
        let attributes = NSMutableDictionary()
        attributes.setObject(textColor, forKey: NSAttributedStringKey.foregroundColor as NSCopying)
        attributes.setObject(font, forKey: NSAttributedStringKey.font as NSCopying)
        return NSAttributedString(string: text, attributes: attributes  as? [NSAttributedStringKey: Any])
    }

    @objc func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let text = "当有新数据时，将会展示在这里"
        let textColor = UIColor(hexString: "cccccc")
        let attributes = NSMutableDictionary()
        let paragraph = NSMutableParagraphStyle()
        let font = UIFont.systemFont(ofSize: 18)
        paragraph.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraph.alignment = NSTextAlignment.center
        paragraph.lineSpacing = 5.0

        attributes.setObject(textColor, forKey: NSAttributedStringKey.foregroundColor as NSCopying)
        attributes.setObject(paragraph, forKey: NSAttributedStringKey.paragraphStyle as NSCopying)
        attributes.setObject(font, forKey: NSAttributedStringKey.font as NSCopying)
        return NSMutableAttributedString(string: text, attributes: attributes as? [NSAttributedStringKey: Any])
    }

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        return UIColor.white
    }

    @objc func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> NSAttributedString? {
        let text = "重新加载"
        let font = UIFont.systemFont(ofSize: 18)
        let textColor = UIColor(hexString: "aaaaaa")
        let attributes = NSMutableDictionary()
        attributes.setObject(textColor, forKey: NSAttributedStringKey.foregroundColor as NSCopying)
        attributes.setObject(font, forKey: NSAttributedStringKey.font as NSCopying)
        return NSAttributedString(string: text, attributes: attributes  as? [NSAttributedStringKey: Any])
    }

    @objc func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {
        if let module = self as? PageModuleAble {
            module.reloadViewData()
        }
    }
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return false
    }
}
