//
//  PickerInputRow.swift
//  UIMaster
//
//  Created by hobson on 2018/7/2.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Eureka
import UIKit

struct Tuple3<A: Equatable, B: Equatable>:InputTypeInitiable {
    init?(string stringValue: String) {
        self.init(string: stringValue)
    }

    let first: A
    let second: B

    init(first: A, second: B) {
        self.first = first
        self.second = second
    }
}
extension Tuple3: Equatable {}

func == <A: Equatable, B: Equatable>(lhs: Tuple3<A, B>, rhs: Tuple3<A, B>) -> Bool {
    return lhs.first == rhs.first && lhs.second == rhs.second
}

// MARK: MultiplePickerCell

class TriplePickerCell<A, B> : PickerCell<Tuple3<A, B>> where A: Equatable, B: Equatable {
    private var pickerRow: TriplePickerRowInner<A, B>! { return row as? TriplePickerRowInner<A, B> }

    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
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
        if component == 0 {
            return pickerRow.firstOptions().count
        } else {
            return pickerRow.secondOptions(pickerRow.selectedFirst()).count
        }
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
                let second: B = pickerRow.secondOptions(first).contains(value.second) ? value.second : pickerRow.secondOptions(first)[0]
                pickerView.reloadComponent(1)
                pickerRow.value = Tuple3(first: first, second: second)
                if second != value.second {
                    pickerView.selectRow(0, inComponent: 1, animated: true)
                }
            } else {
                let second = pickerRow.secondOptions(first)[0]
                pickerRow.value = Tuple3(first: first, second: second)
                pickerView.reloadComponent(1)
                pickerView.selectRow(0, inComponent: 1, animated: true)
            }
        } else if component == 1 {
            let first = pickerRow.selectedFirst()
            let second = pickerRow.secondOptions(first)[row]
            if let value = pickerRow.value {
                guard value.second != second else {
                    return
                }
                pickerRow.value = Tuple3(first: first, second: second)
            } else {
                pickerRow.value = Tuple3(first: first, second: second)
            }
        } else {
            let first = pickerRow.selectedFirst()
            let second = pickerRow.selectedSecond()
            pickerRow.value = Tuple3(first: first, second: second)
        }
    }
}

// MARK: PickerRow
class TriplePickerRowInner<A, B> : Row<TriplePickerCell<A, B>> where A: Equatable, B: Equatable {
    /// Options for first component. Will be called often so should be O(1)
    var firstOptions: (() -> [A]) = { [] }
    /// Options for second component given the selected value from the first component. Will be called often so should be O(1)
    var secondOptions: ((A) -> [B]) = { _ in [] }

    /// Modify the displayed values for the first picker row.
    var displayValueForFirstRow: ((A) -> (String)) = { first in String(describing: first) }
    /// Modify the displayed values for the second picker row.
    var displayValueForSecondRow: ((B) -> (String)) = { second in String(describing: second) }

    required init(tag: String?) {
        super.init(tag: tag)
    }

    func selectedFirst() -> A {
        return value?.first ?? firstOptions()[0]
    }

    func selectedSecond() -> B {
        return value?.second ?? secondOptions(selectedFirst())[0]
    }
}

/// A generic row where the user can pick an option from first picker view
final class TriplePickerRow<A, B>: TriplePickerRowInner<A, B>, RowType where A: Equatable, B: Equatable {
    required init(tag: String?) {
        super.init(tag: tag)
    }
}
