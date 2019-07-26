//
//  IconUploadCell.swift
//  UIMaster
//
//  Created by hobson on 2018/6/29.
//  Copyright © 2018年 one2much. All rights reserved.
//

import Eureka
import UIKit

class ChatGroupIconUploadCell: Cell<UIImage>, CellType, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @IBOutlet weak var uploadImageBtn: UIButton!

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
        // set a light background color for our cell
        backgroundColor = .clear
    }

    override func update() {
        super.update()
        // get the value from our row
        guard let value = row.value else { return }
        uploadImageBtn.setImage(value, for: .normal)
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
        self.row.value = image
        self.update()
    }
}

final class ChatGroupIconUploadRow: Row<ChatGroupIconUploadCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<ChatGroupIconUploadCell>(nibName: "ChatGroupIconUploadCell")
    }
}
