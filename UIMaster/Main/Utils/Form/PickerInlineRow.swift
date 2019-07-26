//
//  PickerInlineRow.swift
//  UIMaster
//
//  Created by hobson on 2018/7/2.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Eureka
import UIKit

open class DoublePickerInlineRowInner<A, B> : Row<PickerInlineCell<Tuple<A, B>>>, NoValueDisplayTextConformance where A: Equatable, B: Equatable {
    typealias InlineRow = DoublePickerRow<A, B>

    /// Options for first component. Will be called often so should be O(1)
    public var firstOptions: (() -> [A]) = { [] }

    /// Options for second component given the selected value from the first component. Will be called often so should be O(1)
    public var secondOptions: ((A) -> [B]) = { _ in [] }

    public var noValueDisplayText: String?

    public required init(tag: String?) {
        super.init(tag: tag)
        self.displayValueFor = { [weak self] tuple in
            if let tuple = tuple {
                return String(describing: tuple.first) + ", " + String(describing: tuple.second)
            }
            return self?.noValueDisplayText
        }
    }
}

/// A generic inline row where the user can pick an option from a picker view which shows and hides itself automatically
final class DoublePickerInlineRow<A, B> : DoublePickerInlineRowInner<A, B>, RowType, InlineRowType where A: Equatable, B: Equatable {
    public required init(tag: String?) {
        super.init(tag: tag)
        onExpandInlineRow { cell, row, _ in
            let color = cell.detailTextLabel?.textColor
            row.onCollapseInlineRow { cell, _, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }

    override public func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            toggleInlineRow()
        }
    }

    public func setupInlineRow(_ inlineRow: InlineRow) {
        inlineRow.firstOptions = firstOptions
        inlineRow.secondOptions = secondOptions
        inlineRow.displayValueFor = self.displayValueFor
        inlineRow.cell.height = UITableViewAutomaticDimension
    }
}
