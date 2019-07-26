//
//  BaseFormVC.swift
//  UIMaster
//
//  Created by hobson on 2018/6/26.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Eureka
import UIKit

class BaseFormVC: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tableView.separatorColor = .clear
        self.tableView.backgroundColor = .clear
        self.tableView.isScrollEnabled = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 1))
        // 开启导航辅助，并且遇到被禁用的行就隐藏导航
        navigationOptions = RowNavigationOptions.Disabled
//            RowNavigationOptions.Enabled.union(.Enabled)
        // 开启流畅地滚动到之前没有显示出来的行
        animateScroll = true
        // 设置键盘顶部和正在编辑行底部的间距为20
        rowKeyboardSpacing = 5
        // Do any additionalpod 'Eureka' setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
//extension BaseFormVC{
//    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        guard tableView == self.tableView else { return tableView.rowHeight }
//        let row = form[indexPath.section][indexPath.row]
//        return row.baseCell.height
//    }
//    
//    open override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        guard tableView == self.tableView else { return tableView.estimatedRowHeight }
//        let row = form[indexPath.section][indexPath.row]
//        return row.baseCell.height
//    }
//}
