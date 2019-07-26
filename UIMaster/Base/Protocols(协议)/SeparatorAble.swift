//
//  CellStyleable.swift
//  UIDS
//
//  Created by one2much on 2018/1/25.
//  Copyright © 2018年 one2much. All rights reserved.
//

import SnapKit
import Then
import UIKit

private struct SeparatorMetric {
    static let separatorHeight: CGFloat = 0.5
    static let padding: CGFloat = 10.0
    static let margin: CGFloat = 10.0
}
public enum SeparatorStyle {
    case none                   // 无横线
    case full                   // 充满
    case leftGap(margin:CGFloat)// 有左边距
    case gap(margin: CGFloat)//两侧间距
}

protocol SeparatorAble {}

extension SeparatorAble where Self: UIView {
    // MARK: - 横线
    func bottomLine(style: SeparatorStyle, color: UIColor) {
        // 创建组件
        let bottomLine = UIView().then {
            $0.backgroundColor = color
        }

        // 添加组件
        self.addSubview(bottomLine)

        // 添加约束
        bottomLine.snp.makeConstraints { make in
            make.height.equalTo(SeparatorMetric.separatorHeight)
            make.left.equalTo(SeparatorMetric.margin * 2)
            make.right.equalTo(self)
            make.bottom.equalTo(self.snp.bottom).offset(-SeparatorMetric.separatorHeight)
        }

        // 调整样式
        switch style {
        case .none:
            bottomLine.isHidden = true
        case let .leftGap(margin):
            bottomLine.isHidden = false
            bottomLine.snp.updateConstraints({ make in
                make.left.equalTo(margin * 2)
            })
        case .full:
            bottomLine.isHidden = false
            bottomLine.snp.updateConstraints({ make in
                make.left.equalTo(0)
            })
        case let .gap(margin):
            bottomLine.isHidden = false
            bottomLine.snp.updateConstraints({ make in
                make.left.equalTo(margin)
                make.right.equalTo(-margin)
            })
        }
    }

    // MARK: - 横线
    func topLine(style: SeparatorStyle, color: UIColor) -> UIView {
        // 创建组件
        let topLine = UIView().then {
            $0.backgroundColor = color
        }

        // 添加组件
        self.addSubview(topLine)

        // 添加约束
        topLine.snp.makeConstraints { make in
            make.height.equalTo(SeparatorMetric.separatorHeight)
            make.left.equalTo(SeparatorMetric.margin * 2)
            make.right.equalTo(self)
            make.top.equalTo(self.snp.top).offset(SeparatorMetric.separatorHeight)
        }

        // 调整样式
        switch style {
        case .none:
            topLine.isHidden = true
        case let .leftGap(margin):
            topLine.isHidden = false
            topLine.snp.updateConstraints({ make in
                make.left.equalTo(margin * 2)
            })
        case .full:
            topLine.isHidden = false
            topLine.snp.updateConstraints({ make in
                make.left.equalTo(0)
            })
        case let .gap( margin):
            topLine.isHidden = false
            topLine.snp.updateConstraints({ make in
                make.left.equalTo(margin)
                make.right.equalTo(-margin)
            })
        }
        return topLine
    }
}

extension UIView: SeparatorAble {}
