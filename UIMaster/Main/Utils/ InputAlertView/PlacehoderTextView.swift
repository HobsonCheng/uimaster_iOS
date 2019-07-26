//
//  PlacehoderTextView.swift
//  UIMaseter
//
//  Created by gongcz on 2018/4/19.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

class PlacehoderTextView: UITextView {
    var placeholder: String? {
        set { placeholderView?.text = placeholder }
        get { return placeholderView?.text }
    }
    private let kTextKey = "text"
    var placeholderView: UITextView?

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setUpPlaceholderView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
        removeObserver(self, forKeyPath: kTextKey)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderView?.frame = bounds
    }
    // MARK: - observation
    func setUpPlaceholderView() {
        placeholderView = UITextView()
        guard let placeholderView = self.placeholderView else { return }
        placeholderView.isEditable = false
        placeholderView.isScrollEnabled = false
        placeholderView.showsHorizontalScrollIndicator = false
        placeholderView.showsVerticalScrollIndicator = false
        placeholderView.isUserInteractionEnabled = false
        placeholderView.font = font
        placeholderView.contentInset = contentInset
        placeholderView.contentOffset = contentOffset
        placeholderView.textContainerInset = textContainerInset
        placeholderView.textColor = UIColor.lightGray
        placeholderView.backgroundColor = UIColor.clear
        addSubview(placeholderView)
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self, selector: #selector(textDidChange(_:)), name: .UITextViewTextDidChange, object: self)
        addObserver(self, forKeyPath: kTextKey, options: .new, context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == kTextKey) {
            placeholderView?.isHidden = hasText
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    @objc func textDidChange(_ notification: Notification) {
        placeholderView?.isHidden = hasText
    }
    // MARK: - setter
    override var font: UIFont? {
        didSet { placeholderView?.font = font }
    }
    override var textAlignment: NSTextAlignment {
        didSet { placeholderView?.textAlignment = textAlignment }
    }
    override var contentInset: UIEdgeInsets {
        didSet { placeholderView?.contentInset = contentInset }
    }
    override var contentOffset: CGPoint {
        didSet { placeholderView?.contentOffset = contentOffset }
    }
    override var textContainerInset: UIEdgeInsets {
        didSet { placeholderView?.textContainerInset = textContainerInset }
    }
}
