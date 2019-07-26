//
//  UITableView+Util.swift
//  UIMaster
//
//  Created by hobson on 2018/9/27.
//  Copyright © 2018 one2much. All rights reserved.
//

import UIKit

public extension UITableView {
    // MARK: - Cell register and reuse
    /**
     Register cell nib
     
     - parameter aClass: class
     */
    func registerCellNib<T: UITableViewCell>(_ aClass: T.Type) {
        let name = String(describing: aClass)
        let nib = UINib(nibName: name, bundle: nil)
        self.register(nib, forCellReuseIdentifier: aClass.getIdentifier)
    }

    /**
     Register cell class
     
     - parameter aClass: class
     */
    func registerCellClass<T: UITableViewCell>(_ aClass: T.Type) {
        let name = aClass.getIdentifier
        self.register(aClass, forCellReuseIdentifier: name)
    }

    /**
     Reusable Cell
     
     - parameter aClass:    class
     
     - returns: cell
     */
    func dequeueReusableCell<T: UITableViewCell>(_ aClass: T.Type) -> T! {
        let name = aClass.getIdentifier
        guard let cell = dequeueReusableCell(withIdentifier: name) as? T else {
            fatalError("\(name) is not registed")
        }
        return cell
    }

    // MARK: - HeaderFooter register and reuse
    /**
     Register cell nib
     
     - parameter aClass: class
     */
    func registerHeaderFooterNib<T: UIView>(_ aClass: T.Type) {
        let name = String(describing: aClass)
        let nib = UINib(nibName: name, bundle: nil)
        self.register(nib, forHeaderFooterViewReuseIdentifier: name)
    }

    /**
     Register cell class
     
     - parameter aClass: class
     */
    func registerHeaderFooterClass<T: UIView>(_ aClass: T.Type) {
        let name = String(describing: aClass)
        self.register(aClass, forHeaderFooterViewReuseIdentifier: name)
    }

    /**
     Reusable Cell
     
     - parameter aClass:    class
     
     - returns: cell
     */
    func dequeueReusableHeaderFooter<T: UIView>(_ aClass: T.Type) -> T! {
        let name = String(describing: aClass)
        guard let cell = dequeueReusableHeaderFooterView(withIdentifier: name) as? T else {
            fatalError("\(name) is not registed")
        }
        return cell
    }
}

extension UITableView {
    func reloadData(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion: { _ in
            completion()
        })
    }

    func insertRowsAtBottom(_ rows: [IndexPath]) {
        //保证 insert row 不闪屏
        UIView.setAnimationsEnabled(false)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.beginUpdates()
        self.insertRows(at: rows, with: .none)
        self.endUpdates()
        self.scrollToRow(at: rows[0], at: .bottom, animated: false)
        CATransaction.commit()
        UIView.setAnimationsEnabled(true)
    }

    func totalRows() -> Int {
        var idx = 0
        var rowCount = 0
        while idx < self.numberOfSections {
            rowCount += self.numberOfRows(inSection: idx)
            idx += 1
        }
        return rowCount
    }

    var lastIndexPath: IndexPath? {
        if (self.totalRows() - 1) > 0 {
            return IndexPath(row: self.totalRows() - 1, section: 0)
        } else {
            return nil
        }
    }

    //插入数据后调用
    func scrollBottomWithoutFlashing() {
        guard let indexPath = self.lastIndexPath else {
            return
        }
        UIView.setAnimationsEnabled(false)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.scrollToRow(at: indexPath, at: .bottom, animated: false)
        CATransaction.commit()
        UIView.setAnimationsEnabled(true)
    }

    //键盘动画结束后调用
    func scrollBottomToLastRow() {
        guard let indexPath = self.lastIndexPath else {
            return
        }
        self.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    func scrollToBottom(animated: Bool) {
        if self.contentSize.height - self.bounds.size.height <= 0 {
            return
        }
        let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
        self.setContentOffset(bottomOffset, animated: animated)
    }

    var isContentInsetBottomZero: Bool {
        get { return self.contentInset.bottom == 0 }
    }

    func resetContentInsetAndScrollIndicatorInsets() {
        self.contentInset = UIEdgeInsets.zero
        self.scrollIndicatorInsets = UIEdgeInsets.zero
    }
}
