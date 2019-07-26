//
//  ChatImageCell.swift
//  TSWeChat
//
//  Created by Hilen on 12/22/15.
//  Copyright © 2015 Hilen. All rights reserved.
//

import RxSwift
import SnapKit
import UIKit

let kChatImageMaxWidth: CGFloat = 185 //最大的图片宽度
let kChatImageMinWidth: CGFloat = 120 //最小的图片宽度
let kChatImageMaxHeight: CGFloat = 165 //最大的图片高度
let kChatImageMinHeight: CGFloat = 120 //最小的图片高度

class ChatImageCell: ChatBaseCell {
    @IBOutlet weak var chatImageView: UIImageView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var errorBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        //图片点击
        let tap = UITapGestureRecognizer()
        self.chatImageView.addGestureRecognizer(tap)
        self.chatImageView.isUserInteractionEnabled = true
        tap.rx.event.subscribe {[weak self] _ in
            if let strongSelf = self {
                guard let delegate = strongSelf.delegate else {
                    return
                }
                delegate.cellDidTapedImageView(strongSelf)
            }
        }.disposed(by: self.disposeBag)
    }

    override func setCellContent(_ model: ChatMessageModel) {
        super.setCellContent(model)
        if let localThumbnailImage = model.localThumbnailImage {
            self.chatImageView.image = localThumbnailImage
        } else {
            self.chatImageView.kf.setImage(with: URL(string: model.thumbURL), placeholder: nil, options: nil, progressBlock: nil) { image, _, _, _ in
                let size = image?.size
                self.model?.imageWidth = size?.width ?? 0
                self.model?.imageHeight = size?.height ?? 0
                DispatchQueue.main.async {
                    self.layoutSubviews()
                }
            }
        }

        //发送状态
        if ChatSendStatus(rawValue: model.send_state) == .sending {
            indicatorView.isHidden = false
            errorBtn.isHidden = true
            indicatorView.startAnimating()
        } else if ChatSendStatus(rawValue: model.send_state) == .fail {
            indicatorView.isHidden = true
            errorBtn.isHidden = false
        } else {
            indicatorView.isHidden = true
            errorBtn.isHidden = true
        }
        self.setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let model = self.model else {
            return
        }

        var imageOriginalWidth = kChatImageMinWidth  //默认临时加上最小的值
        var imageOriginalHeight = kChatImageMinHeight   //默认临时加上最小的值

        imageOriginalWidth = model.imageWidth

        imageOriginalHeight = model.imageHeight

        //根据原图尺寸等比获取缩略图的 size
        let originalSize = CGSize(width: imageOriginalWidth, height: imageOriginalHeight)
        self.chatImageView.size = ImageScaler.getThumbImageSize(originalSize)

        if model.fromMe {
            //value = 屏幕宽 - 头像的边距10 - 头像宽 - 气泡距离头像的 gap 值 - 图片宽
            self.chatImageView.left = kScreenW - kChatAvatarMarginLeft - kChatAvatarWidth - kChatBubbleMarginLeft - self.chatImageView.width
        } else {
            //value = 距离屏幕左边的距离
            self.chatImageView.left = kChatBubbleLeft
        }

        self.chatImageView.top = self.avatarImageView.top + self.nicknameLabel.height

        /**
         *  绘制 imageView 的 bubble layer
         */
        let stretchInsets = UIEdgeInsets(top: 30, left: 28, bottom: 23, right: 28)
        let stretchImage = model.fromMe ? R.image.senderImageNodeMask() : R.image.receiverImageNodeMask()
        let bubbleMaskImage = stretchImage?.resizableImage(withCapInsets: stretchInsets, resizingMode: .stretch) ?? UIImage.from(color: UIColor(hexString: "#777777"))

        //设置图片的 mask layer
        let layer = CALayer()
        layer.contents = bubbleMaskImage.cgImage
        layer.contentsCenter = self.CGRectCenterRectForResizableImage(bubbleMaskImage)
        layer.frame = CGRect(x: 0, y: 0, width: self.chatImageView.width, height: self.chatImageView.height)
        layer.contentsScale = UIScreen.main.scale
        layer.opacity = 1
        self.chatImageView.layer.mask = layer
        self.chatImageView.layer.masksToBounds = true

        /**
         绘制 coverImage，盖住图片
         */
        let stretchConverImage = model.fromMe ? R.image.senderImageNodeBorder() : R.image.receiverImageNodeBorder()
        let bubbleConverImage = stretchConverImage?.resizableImage(withCapInsets: stretchInsets, resizingMode: .stretch)
        self.coverImageView.image = bubbleConverImage
        self.coverImageView.frame = CGRect(
            x: self.chatImageView.left - 1,
            y: self.chatImageView.top,
            width: self.chatImageView.width + 2,
            height: self.chatImageView.height + 2
        )

        if model.fromMe {
            self.indicatorView.frame = self.chatImageView.frame
            self.indicatorView.right = self.coverImageView.right - 2
            self.indicatorView.width = self.chatImageView.frame.width - 6
//            self.indicatorView.top = self.coverImageView.top + (self.coverImageView.height / 2) - 10
            self.errorBtn.right = self.coverImageView.left - kChatTextMarginLeft - 8
            self.errorBtn.top = self.coverImageView.top + (self.coverImageView.height / 2) - 10
        } else {
            self.indicatorView.isHidden = true
            self.errorBtn.isHidden = true
        }
    }

    class func layoutHeight(_ model: ChatMessageModel) -> CGFloat {
        if model.cellHeight != 0 {
            return model.cellHeight
        }

        //        guard let imageModel = model.imageModel else {
        //            return 0
        //        }

        var height = kChatAvatarMarginTop + kChatBubblePaddingBottom

        let imageOriginalWidth = model.imageWidth
        let imageOriginalHeight = model.imageHeight

        /**
         *  1）如果图片的高度 >= 图片的宽度 , 高度就是最大的高度，宽度等比
         *  2）如果图片的高度 < 图片的宽度 , 以宽度来做等比，算出高度
         */
        if imageOriginalHeight >= imageOriginalWidth {
            height += kChatImageMaxHeight
        } else {
            let scaleHeight = imageOriginalHeight * kChatImageMaxWidth / imageOriginalWidth
            height += (scaleHeight > kChatImageMinHeight) ? scaleHeight : kChatImageMinHeight
        }
        height += 12  // 图片距离底部的距离 12

        model.cellHeight = height
        return model.cellHeight + 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */

    @IBAction func sendFailed(_ sender: Any) {
        guard let model = self.model else { return }

        let alertVC = UIAlertController(title: "重新发送该消息", message: nil, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { _ in
            ChatHelper.reSendMsg(type: ChatMessageType.picture, model: model)
        }))
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alertVC.show()
    }
    func CGRectCenterRectForResizableImage(_ image: UIImage) -> CGRect {
        return CGRect(
            x: image.capInsets.left / image.size.width,
            y: image.capInsets.top / image.size.height,
            width: (image.size.width - image.capInsets.right - image.capInsets.left) / image.size.width,
            height: (image.size.height - image.capInsets.bottom - image.capInsets.top) / image.size.height
        )
    }

    func maskImage(_ image: UIImage, maskImage: UIImage) -> UIImage {
        let maskRef: CGImage = maskImage.cgImage!
        let mask = CGImage(
            maskWidth: maskRef.width,
            height: maskRef.height,
            bitsPerComponent: maskRef.bitsPerComponent,
            bitsPerPixel: maskRef.bitsPerPixel,
            bytesPerRow: maskRef.bytesPerRow,
            provider: maskRef.dataProvider!,
            decode: nil,
            shouldInterpolate: false
            )!
        let maskedImageRef: CGImage = (image.cgImage)!.masking(mask)!
        let maskedImage = UIImage(cgImage: maskedImageRef)
        // returns new image with mask applied
        return maskedImage
    }
}
