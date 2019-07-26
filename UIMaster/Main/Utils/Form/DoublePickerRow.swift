//
//  DoublePickerInlineRow.swift
//  UIMaster
//
//  Created by hobson on 2018/7/2.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Eureka
import UIKit

public struct Tuple<A: Equatable, B: Equatable> {
    public let first: A
    public let second: B

    public init(first: A, second: B) {
        self.first = first
        self.second = second
    }
}

extension Tuple: Equatable {}

public func == <A: Equatable, B: Equatable>(lhs: Tuple<A, B>, rhs: Tuple<A, B>) -> Bool {
    return lhs.first == rhs.first && lhs.second == rhs.second
}

// MARK: MultiplePickerCell

class DoublePickerCell<A, B> : PickerCell<Tuple<A, B>> where A: Equatable, B: Equatable {
    private var pickerRow: DoublePickerRowInner<A, B>! { return row as? DoublePickerRowInner<A, B> }

    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func update() {
        super.update()
        if let selectedValue = pickerRow.value, let indexA = pickerRow.firstOptions().index(of: selectedValue.first),
            let indexB = pickerRow.secondOptions(selectedValue.first).index(of: selectedValue.second) {
            picker.selectRow(indexA, inComponent: 0, animated: true)
            picker.selectRow(indexB, inComponent: 1, animated: true)
        }
    }

    override func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return  component == 0 ? pickerRow.firstOptions().count : pickerRow.secondOptions(pickerRow.selectedFirst()).count
    }

    override func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return pickerRow.displayValueForFirstRow(pickerRow.firstOptions()[row])
        } else {
            return pickerRow.displayValueForSecondRow(pickerRow.secondOptions(pickerRow.selectedFirst())[row])
        }
    }

    override func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            let first = pickerRow.firstOptions()[row]
            if let value = pickerRow.value {
                guard value.first != first else {
                    return
                }
                if pickerRow.secondOptions(first).contains(value.second) {
                    pickerRow.value = Tuple(first: first, second: value.second)
                    pickerView.reloadComponent(1)
                    return
                } else {
                    pickerRow.value = Tuple(first: first, second: pickerRow.secondOptions(first)[0])
                }
            } else {
                pickerRow.value = Tuple(first: first, second: pickerRow.secondOptions(first)[0])
            }
            pickerView.reloadComponent(1)
            pickerView.selectRow(0, inComponent: 1, animated: true)
        } else {
            let first = pickerRow.selectedFirst()
            pickerRow.value = Tuple(first: first, second: pickerRow.secondOptions(first)[row])
        }
    }
}

// MARK: PickerRow
 class DoublePickerRowInner<A, B> : Row<DoublePickerCell<A, B>> where A: Equatable, B: Equatable {
    /// Options for first component. Will be called often so should be O(1)
    public var firstOptions: (() -> [A]) = { [] }
    /// Options for second component given the selected value from the first component. Will be called often so should be O(1)
    public var secondOptions: ((A) -> [B]) = { _ in [] }

    /// Modify the displayed values for the first picker row.
    public var displayValueForFirstRow: ((A) -> (String)) = { first in String(describing: first) }
    /// Modify the displayed values for the second picker row.
    public var displayValueForSecondRow: ((B) -> (String)) = { second in String(describing: second) }

    public required init(tag: String?) {
        super.init(tag: tag)
    }

    func selectedFirst() -> A {
        return value?.first ?? firstOptions()[0]
    }
}

/// A generic row where the user can pick an option from first picker view
final class DoublePickerRow<A, B>: DoublePickerRowInner<A, B>, RowType where A: Equatable, B: Equatable {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
