//
//  CLBottomCommentViewDelegate.swift
//  UIDS
//
//  Created by one2much on 2018/1/23.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

protocol CLBottomCommentViewDelegate: NSObjectProtocol {
    func bottomViewDidShare()
    func bottomViewDidMark(_ markButton: UIButton)

    func cl_textViewDidChange(_ textView: CLTextView)
    func cl_textViewDidEndEditing(_ textView: CLTextView)
}
