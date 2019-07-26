//
//  JFNewsBottomBar.swift
//  UIDS
//
//  Created by bai on 16/4/1.
//  Copyright © 2016年 bai. All rights reserved.
//

import UIKit

protocol JFNewsBottomBarDelegate: AnyObject {
    func didTappedEditButton(_ button: UIButton)
    func didTappedCollectButton(_ button: UIButton)
    func didTappedShareButton(_ button: UIButton)
    func didTappedCommentButton(_ button: UIButton)
    func didTappedPraiseButton(_ button: UIButton)
}

class JFNewsBottomBar: UIView {
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var collectionButton: UIButton!

    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var praiseButton: UIButton!
    weak var delegate: JFNewsBottomBarDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.shareButton.setYJIcon(icon: .report, iconSize: 16, forState: UIControlState.normal)
        self.praiseButton.setYJIcon(icon: .praise2, iconSize: 16, forState: UIControlState.normal)
        self.praiseButton.setYJIcon(icon: .praised0, iconSize: 16, forState: UIControlState.selected)
    }

    @IBAction func didTappedEditButton(_ button: UIButton) {
        delegate?.didTappedEditButton(button)
    }

    @IBAction func didTappedCommentButton(_ button: UIButton) {
        delegate?.didTappedCommentButton(button)
    }

    @IBAction func didTappedCollectButton(_ button: UIButton) {
        delegate?.didTappedCollectButton(button)
    }

    @IBAction func didTappedShareButton(_ button: UIButton) {
        delegate?.didTappedShareButton(button)
    }

    @IBAction func didTappedPraiseButton(_ button: UIButton) {
        delegate?.didTappedPraiseButton(button)
    }
}
