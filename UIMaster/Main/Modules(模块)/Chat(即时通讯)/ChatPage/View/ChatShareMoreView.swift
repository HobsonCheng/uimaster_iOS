//
//  ChatShareMoreView.swift
//  WeChat
//
//  Created by Hilen on 12/24/15.
//  Copyright © 2015 Hilen. All rights reserved.
//

import Dollar
import RxSwift
import SnapKit
import UIKit

private let kLeftRightPadding: CGFloat = 5.0
private let kTopBottomPadding: CGFloat = 5.0
private let kItemCountOfRow: CGFloat = 4

class ChatShareMoreView: UIView {
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var listCollectionView: UICollectionView! {didSet {
        listCollectionView.scrollsToTop = false
        }}
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    weak var delegate: ChatShareMoreViewDelegate?
    internal let disposeBag = DisposeBag()

    fileprivate let itemDataSouce: [(name: String, iconImage: UIImage)] = [
        ("照片", R.image.sharemore_pic() ?? UIImage.from(color: UIColor(hexString: "#777777"))),
        ("相机", R.image.sharemore_video() ?? UIImage.from(color: UIColor(hexString: "#777777"))),
        ("文件", R.image.sharemore_file() ?? UIImage.from(color: UIColor(hexString: "#777777")))
//        ("小视频", R.image.sharemore_sight() ?? UIImage.from(color: UIColor.init(hexString: "#777777"))),
        //        ("视频聊天", Asset.Share.sharemoreVideovoip.image),
        //        ("红包", Asset.Share.sharemoreWallet.image),  //Where is the lucky money icon!  T.T
        //        ("转账" Asset.Share.sharemorePay.image),
//        ("位置", R.image.sharemore_location() ?? UIImage.from(color: UIColor.init(hexString: "#777777"))),
        //        ("收藏", Asset.Share.sharemoreMyfav.image),
//        ("个人名片", R.image.sharemore_friendcard() ?? UIImage.from(color: UIColor.init(hexString: "#777777"))),
        //        ("语音输入", Asset.Share.sharemoreVoiceinput.image),
        //        ("卡券", Asset.Share.sharemoreWallet.image),
    ]
    fileprivate var groupDataSouce = [[(name: String, iconImage: UIImage)]]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.initialize()
    }

    convenience init() {
        self.init(frame: CGRect.zero)
        self.initialize()
    }

    func initialize() {
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let layout = FullyHorizontalFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: kTopBottomPadding, left: kLeftRightPadding, bottom: kTopBottomPadding, right: kLeftRightPadding)
        //Calculate the UICollectionViewCell size
        let itemSizeWidth = (kScreenW - kLeftRightPadding * 2 - layout.minimumLineSpacing * (kItemCountOfRow - 1)) / kItemCountOfRow
        let itemSizeHeight = (self.collectionViewHeightConstraint.constant - kTopBottomPadding * 2) / 2
        layout.itemSize = CGSize(width: itemSizeWidth, height: itemSizeHeight)

        self.listCollectionView.collectionViewLayout = layout
        self.listCollectionView.register(ChatShareMoreCollectionViewCell.getNib(), forCellWithReuseIdentifier: ChatShareMoreCollectionViewCell.getIdentifier)
        self.listCollectionView.showsHorizontalScrollIndicator = false
        self.listCollectionView.isPagingEnabled = true

        /**
         The section count is come from the groupDataSource, and The pageControl.numberOfPages is equal to the groupDataSouce.count.
         So I cut the itemDataSouce into 2 arrays. And the UICollectionView will has 2 sections.
         And then set the minimumLineSpacing and sectionInset of the flowLayout. The UI will be perfect like WeChat.
         */
        self.groupDataSouce = Dollar.chunk(self.itemDataSouce, size: Int(kItemCountOfRow) * 2)
        self.pageControl.numberOfPages = self.groupDataSouce.count
        if self.groupDataSouce.count == 1 {
            self.pageControl.isHidden = true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        //Fix the width
        self.listCollectionView.width = kScreenW
    }
}

// MARK: - @protocol UICollectionViewDelegate
extension ChatShareMoreView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let delegate = self.delegate else {
            return
        }

        let section = indexPath.section
        let row = indexPath.row
        if section == 0 {
            if row == 0 {
                delegate.chatShareMoreViewPhotoTaped()
            } else if row == 1 {
                delegate.chatShareMoreViewCameraTaped()
            } else if row == 2 {
                delegate.chatShareMoreViewFileTaped()
            }
        }
    }
}

// MARK: - @protocol UICollectionViewDataSource
extension ChatShareMoreView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.groupDataSouce.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let subArray = self.groupDataSouce[section]
        return subArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatShareMoreCollectionViewCell.getIdentifier, for: indexPath) as? ChatShareMoreCollectionViewCell else {
            return UICollectionViewCell()
        }
        let subArray = self.groupDataSouce[indexPath.section]

        let item = subArray[indexPath.row]
        cell.itemButton.setImage(item.iconImage, for: .normal)
        cell.itemLabel.text = item.name

        return cell
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan start")
    }
}

// MARK: - @protocol UIScrollViewDelegate
extension ChatShareMoreView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth: CGFloat = self.listCollectionView.width
        self.pageControl.currentPage = Int(self.listCollectionView.contentOffset.x / pageWidth)
    }
}

// MARK: - @delgate ChatShareMoreViewDelegate
protocol ChatShareMoreViewDelegate: AnyObject {
    /**
     选择相册
     */
    func chatShareMoreViewPhotoTaped()

    /**
     选择相机
     */
    func chatShareMoreViewCameraTaped()

    /// 选择文件
    func chatShareMoreViewFileTaped()
}
