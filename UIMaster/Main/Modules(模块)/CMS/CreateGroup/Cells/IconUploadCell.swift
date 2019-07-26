//
//  IconUploadCell.swift
//  UIMaster
//
//  Created by hobson on 2018/6/29.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Eureka
import UIKit

struct IconUploadInfo: Equatable {
    var title: String
    var subIconUpload: String
    var uploadImage: UIImage?
}
func ==(lhs: IconUploadInfo, rhs: IconUploadInfo) -> Bool {
    return lhs.title == rhs.title && lhs.subIconUpload == rhs.subIconUpload
}

class IconUploadCell: Cell<IconUploadInfo>, CellType, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var uploadImageBtn: UIButton!
    @IBOutlet weak var subIconUploadLabel: UILabel!

    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setup() {
        super.setup()
        selectionStyle = .none

        uploadImageBtn.contentMode = .scaleAspectFill
        uploadImageBtn.clipsToBounds = true

        // specify the desired height for our cell
        uploadImageBtn.addTarget(self, action: #selector(touchItem(btn:)), for: .touchUpInside)
        row.value = IconUploadInfo(title: "群组头像", subIconUpload: "为您的群组添加一张有代表性的图片", uploadImage: nil)
        // set a light background color for our cell
        backgroundColor = .clear
    }

    override func update() {
        super.update()
        // get the value from our row
        guard let values = row.value else { return }

        // set the texts to the labels
        titleLabel.text = values.title
        subIconUploadLabel.text = values.subIconUpload
        if let img = values.uploadImage {
            uploadImageBtn.setImage(img, for: .normal)
        }
    }

    // MARK: 事件处理
    @objc func touchItem(btn: UIButton) {
        if !UserUtil.isValid() {
            PageRouter.shared.router(to: .login)
            HUDUtil.msg(msg: "请登录", type: .error)
            return
        }
        _ = self.becomeFirstResponder()
        let alertVC = UIAlertController(title: "上传图片", message: nil, preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "拍照", style: .default, handler: { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                picker.allowsEditing = true
                kWindowRootVC?.present(picker, animated: true, completion: nil)
            } else {
                HUDUtil.msg(msg: "您的设备好像不支持照相机~~", type: .info)
            }
        }))
        alertVC.addAction(UIAlertAction(title: "相册选取", style: .default, handler: { _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            kWindowRootVC?.present(picker, animated: true, completion: nil)
        }))
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        kWindowRootVC?.present(alertVC, animated: true, completion: nil)
    }

    // MARK: 选取图片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true)

        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            dPrint("No image found")
            return
        }
        self.row.value?.uploadImage = image
        update()
    }
}

final class IconUploadRow: Row<IconUploadCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<IconUploadCell>(nibName: "IconUploadCell")
    }
}
