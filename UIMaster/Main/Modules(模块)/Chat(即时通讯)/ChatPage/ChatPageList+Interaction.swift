//
//  ChatPageList+Interaction.swift
//  UIMaster
//
//  Created by hobson on 2018/9/27.
//  Copyright © 2018 one2much. All rights reserved.
//

import Alamofire
import JXPhotoBrowser
import MobileCoreServices
import Photos
import QuickLook
import TZImagePickerController
import UIKit

// MARK: - protocol ChatShareMoreViewDelegate
// 分享更多里面的 Button 交互
//extension ChatPageList: ChatShareMoreViewDelegate {

//    func chatShareMoreViewFileTaped() {
//        let documentTypes = ["public.content", "public.text", "public.source-code ", "public.image", "p@objc(previewController:previewItemAtIndex:) ublic.audiovisual-content", "com.adobe.pdf", "com.apple.keynote.key", "com.microsoft.word.doc", "com.microsoft.excel.xls", "com.microsoft@objc(numberOfPreviewItemsInPreviewController:) .powerpoint.ppt"]
//
//        let documentPicker = UIDocumentPickerViewController.init(documentTypes: documentTypes, in: UIDocumentPickerMode.open)
//        documentPicker.delegate = self
//        kWindowRootVC?.present(documentPicker, animated: true, completion: nil)
//    }

    //选择打开相册
//    func chatShareMoreViewPhotoTaped() {
//
//        guard let imagePickerVC = TZImagePickerController.init(maxImagesCount: 9, delegate: self) else{ return }
//        imagePickerVC.allowPickingVideo = false
//        imagePickerVC.didFinishPickingPhotosHandle = { (photos,assets,finish) in
//            for photo in photos ?? []{
//
//                DispatchQueue.main.async {
//                    self.chatHelper?.resizeAndSendImage(photo)
//                }
//
//            }
//        }
//        kWindowRootVC?.present(imagePickerVC, animated: true, completion: nil)
//    }

    //选择打开相机
//    func chatShareMoreViewCameraTaped() {
//        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
//        if authStatus == .notDetermined {
//            self.checkCameraPermission()
//        } else if authStatus == .restricted || authStatus == .denied {
//            HUDUtil.showAlert(title: "无法访问您的相机", message: "请到设置 -> 隐私 -> 相机 ，打开访问权限")
//        } else if authStatus == .authorized {
//            self.chatHelper?.openCamera()
//        }
//    }

//    func checkCameraPermission () {
//        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {granted in
//            if !granted {
//                HUDUtil.showAlert(title: "无法访问您的相机", message: "请到设置 -> 隐私 -> 相机 ，打开访问权限")
//            }
//        })
//    }
//
//    func openCamera() {
//        self.imagePicker =  UIImagePickerController()
//        self.imagePicker.delegate = self
//        self.imagePicker.sourceType = .camera
//        self.present(self.imagePicker, animated: true, completion: nil)
//    }

    //处理图片，并且发送图片消息
//    func resizeAndSendImage(_ theImage: UIImage) {
//        //FIXME:
//        //        UIImage.fixImageOrientation(theImage)
//        let originalImage = theImage
//        let storeKey = "img_\(Int64(Date().timeIntervalSince1970 * 100000))"
//        let thumbSize = imageScaler.getThumbImageSize(originalImage.size)
//
//        //保存原图
//        ImageFilesManager.storeImage(originalImage, key: storeKey + "_original", completionHandler: nil)
//        //获取缩略图失败 ，抛出异常：发送失败
//        guard let thumbNail = originalImage.resize(thumbSize) else { return }
//        ImageFilesManager.storeImage(thumbNail, key: storeKey, completionHandler: { [weak self] in
//            guard let strongSelf = self else { return }
//            //发送图片消息
//            let sendImageModel = ChatMessageModel()
//            sendImageModel.msg_id = Int64(Date().getTimeIntervalSince1970())
//            sendImageModel.imageHeight = originalImage.size.height
//            sendImageModel.imageWidth = originalImage.size.width
//            sendImageModel.session_id = self?.currentSessionModel.session_id ?? 0
//            sendImageModel.localStoreName = storeKey
//            sendImageModel.localOriginalStoreName = storeKey + "_original"
//            sendImageModel.sender = self?.currentSessionModel.sender ?? 0
//            sendImageModel.sender_pid = self?.currentSessionModel.sender_pid ?? 0
//            sendImageModel.receiver = self?.currentSessionModel.receiver ?? 0
//            sendImageModel.receiver_pid = self?.currentSessionModel.receiver_pid ?? 0
//            sendImageModel.groupPid = self?.currentSessionModel.groupPid ?? 0
//            sendImageModel.client_time = Date.currentTimeStr
//            sendImageModel.kind = ChatMessageType.picture.rawValue
//            sendImageModel.send_state = ChatSendStatus.sending.rawValue
//            sendImageModel.chat_type = self?.currentSessionModel.chat_type ?? 0
//            strongSelf.chatSendImage(sendImageModel)
//
//            DatabaseTool.shared.modifyPicMessage(with: sendImageModel.msg_id , model: sendImageModel)
//            /**
//             *  异步上传原图, 然后上传成功后，把 model 值改掉
//             *  但因为还没有找到上传的 API，所以这个函数会返回错误  T.T
//             * //TODO: 原图尺寸略大，需要剪裁
//             */
//            UploadImageTool.uploadImage(image: originalImage, progress: { (_, progress) in
//                dPrint(progress)
//            }, success: { (url) in
//
//                //发送请求
//                NetworkUtil.request(target: NetworkService.addMessage(msg_type: sendImageModel.kind, content: RC4Tool.encryptRC4(with: url, key: getUserDefaults(key: kRC4Key) as! String), target_pid: sendImageModel.receiver_pid, send_time: sendImageModel.client_time, session: Int64(sendImageModel.session_id), file_name: "", client_id: Int64(sendImageModel.msg_id), target: sendImageModel.receiver), success: { (json) in
//                    sendImageModel.content = url
//                    DatabaseTool.shared.modifyPicMessage(with: sendImageModel.msg_id , model: sendImageModel)
//                    var status = ChatSendStatus.success.rawValue
//                    if BaseModel.deserialize(from: json)?.code != "0"{
//                        status = ChatSendStatus.fail.rawValue
//                    }
//                    DatabaseTool.shared.modifySendState(sessionID: sendImageModel.session_id, msgID: sendImageModel.msg_id, state: status)
//                }, failure: { (error) in
//                    DatabaseTool.shared.modifySendState(sessionID: sendImageModel.session_id, msgID: sendImageModel.msg_id, state: ChatSendStatus.fail.rawValue)
//                    dPrint(error)
//                })
//                //修改缩略图的名称
//                //                let tempStorePath = URL(string:ImageFilesManager.cachePathForKey(storeKey)!)
//                //                let targetStorePath = URL(string:ImageFilesManager.cachePathForKey(sendImageModel.thumbURL)!)
//                //                ImageFilesManager.renameFile(tempStorePath!, destinationPath: targetStorePath!)
//            }, failure: { (error) in
//                DatabaseTool.shared.modifySendState(sessionID: sendImageModel.session_id, msgID: sendImageModel.msg_id, state: ChatSendStatus.fail.rawValue)
//                dPrint(error)
//            })
//
//        })
//
//    }
//}

// MARK: - 选择文件
//extension ChatPageList: UIDocumentPickerDelegate{

//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
//        let arr = url.absoluteString.components(separatedBy: "/")
//        let fileName = arr.last?.removingPercentEncoding ?? ""
//        //检测iCloud可不可用
//        guard let _ = FileManager.default.url(forUbiquityContainerIdentifier: nil) else{
//            HUDUtil.msg(msg: "iCloud不可用", type: .error)
//            return
//        }
//        let doc = YJDocument.init(fileURL: url)
//
//        doc.open { [weak self] (finish) in
//            if finish{
//                doc.close(completionHandler: { (finish) in
//                    dPrint("关闭成功")
//                })
//            }
//            guard let data = doc.data else{
//                return
//            }
//            if let img = UIImage.init(data: data as Data){
//                self?.chatHelper?.resizeAndSendImage(img)
//                return
//            }
//            let fileUrl = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("com.one2much.app\(GlobalConfigTool.shared.appId ?? 0)/" + fileName)
//            //将数据写入到路径下
//            if let safeUrl = fileUrl {
//                do {
//                    try data.write(to: safeUrl, options: .atomic)
//
//                    //发送图片消息
//                    let sendFileModel = ChatMessageModel()
//                    sendFileModel.msg_id = Int64(Date().getTimeIntervalSince1970())
//                    sendFileModel.session_id = self?.currentSessionModel.session_id ?? 0
//                    sendFileModel.localStoreName = safeUrl.absoluteString.replacingOccurrences(of: "file://", with: "")
//                    sendFileModel.sender = self?.currentSessionModel.sender ?? 0
//                    sendFileModel.sender_pid = self?.currentSessionModel.sender_pid ?? 0
//                    sendFileModel.receiver = self?.currentSessionModel.receiver ?? 0
//                    sendFileModel.receiver_pid = self?.currentSessionModel.receiver_pid ?? 0
//                    sendFileModel.groupPid = self?.currentSessionModel.groupPid ?? 0
//                    sendFileModel.client_time = Date.currentTimeStr
//                    sendFileModel.filename = fileName
//                    sendFileModel.kind = ChatMessageType.file.rawValue
//                    sendFileModel.send_state = ChatSendStatus.sending.rawValue
//                    sendFileModel.chat_type = self?.currentSessionModel.chat_type ?? 0
//                    self?.chatSendFile(sendFileModel)
//
//                    DatabaseTool.shared.modifyPicMessage(with: sendFileModel.msg_id , model: sendFileModel)
//
//                    UploadImageTool.uploadFile(filePath: safeUrl.absoluteString, progress: { (msg, progress) in
//                    }, success: { (url) in
//                        //发送请求
//                        NetworkUtil.request(target: NetworkService.addMessage(msg_type: sendFileModel.kind,  content: RC4Tool.encryptRC4(with: url, key: getUserDefaults(key: kRC4Key) as! String), target_pid: sendFileModel.receiver_pid, send_time: sendFileModel.client_time, session: Int64(sendFileModel.session_id),file_name: fileName, client_id: Int64(sendFileModel.msg_id), target: sendFileModel.receiver), success: { (json) in
//                            sendFileModel.content = url
//                            DatabaseTool.shared.modifyPicMessage(with: sendFileModel.msg_id , model: sendFileModel)
//                            var status = ChatSendStatus.success.rawValue
//                            if BaseModel.deserialize(from: json)?.code != "0"{
//                                status = ChatSendStatus.fail.rawValue
//                            }
//                            DatabaseTool.shared.modifySendState(sessionID: sendFileModel.session_id, msgID: sendFileModel.msg_id, state: status)
//                        }, failure: { (error) in
//                            DatabaseTool.shared.modifySendState(sessionID: sendFileModel.session_id, msgID: sendFileModel.msg_id, state: ChatSendStatus.fail.rawValue)
//                            dPrint(error)
//                        })
//                    }, failure: { (error) in
//
//                        DatabaseTool.shared.modifySendState(sessionID: sendFileModel.session_id, msgID: sendFileModel.msg_id, state: ChatSendStatus.fail.rawValue)
//                        dPrint(error)
//                    })
//                } catch {
//                    dPrint(error)
//                }
//            }
//        }
//
//    }
//}

// MARK: - @protocol UIImagePickerControllerDelegate
// 拍照完成，进行上传图片，并且发送的请求
//extension ChatPageList: UINavigationControllerDelegate, UIImagePickerControllerDelegate,TZImagePickerControllerDelegate {
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
//            dPrint("No image found")
//            return
//        }
//        self.chatHelper?.resizeAndSendImage(image)
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//}

// MARK: - @protocol RecordAudioDelegate
// 语音录制完毕后
//extension ChatPageList: RecordAudioDelegate {
//    func audioRecordUpdateMetra(_ metra: Float) {
//        //        self.voiceIndicatorView.updateMetersValue(metra)
//    }
//
//    func audioRecordTooShort() {
//        //        self.voiceIndicatorView.messageTooShort()
//    }
//
//    func audioRecordFinish(_ uploadAmrData: Data, recordTime: Float, fileHash: String) {
//        //        self.voiceIndicatorView.endRecord()
//        //
//        //        //发送本地音频
//        //        let audioModel = ChatAudioModel()
//        //        audioModel.keyHash = fileHash
//        //        audioModel.audioURL = ""
//        //        audioModel.duration = recordTime
//        //        self.chatSendVoice(audioModel)
//        //
//        //        /**
//        //         *  异步上传音频文件, 然后上传成功后，把 model 值改掉
//        //         *  因为还没有上传的 API，所以这个函数会返回错误  T.T
//        //         */
//        //        HttpManager.uploadAudio(uploadAmrData, recordTime: String(recordTime), success: {model in
//        //            audioModel.keyHash = model.keyHash
//        //            audioModel.audioURL = model.audioURL
//        //            audioModel.duration = recordTime
//        //        }, failure: {
//        //
//        //        })
//    }
//
//    func audioRecordFailed() {
//        HUDUtil.showAlert(title: "录音失败，请重试", message: "")
//    }
//
//    func audioRecordCanceled() {
//
//    }
//}

// MARK: - @protocol PlayAudioDelegate
//extension ChatPageList: PlayAudioDelegate {
//    /**
//     播放完毕
//     */
//    func audioPlayStart() {
//        
//    }
//    
//    /**
//     播放完毕
//     */
//    func audioPlayFinished() {
//        self.currentVoiceCell.resetVoiceAnimation()
//    }
//    
//    /**
//     播放失败
//     */
//    func audioPlayFailed() {
//        self.currentVoiceCell.resetVoiceAnimation()
//    }
//    
//    
//    /**
//     播放被中断
//     */
//    func audioPlayInterruption() {
//        self.currentVoiceCell.resetVoiceAnimation()
//    }
//}

// MARK: - @protocol ChatEmotionInputViewDelegate
// 表情点击完毕后
//extension ChatPageList: ChatEmotionInputViewDelegate {
//    //点击表情
//    func chatEmoticonInputViewDidTapCell(_ cell: ChatEmotionCell) {
//        self.chatActionBarView.inputTextView.insertText(cell.emotionModel!.text)
//    }
//    
//    //点击撤退删除
//    func chatEmoticonInputViewDidTapBackspace(_ cell: ChatEmotionCell) {
//        self.chatActionBarView.inputTextView.deleteBackward()
//    }
//    
//    //点击发送文字，包含表情
//    func chatEmoticonInputViewDidTapSend() {
//        self.chatSendText()
//    }
//}

// MARK: - @protocol UITextViewDelegate
extension ChatPageList: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            //点击发送文字，包含表情
            self.chatHelper?.chatSendText(actionBarView: self.chatActionBarView)
            return false
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        let contentHeight = textView.contentSize.height
        guard contentHeight < kChatActionBarTextViewMaxHeight, contentHeight != 37 else {
            return
        }
        let newHeight = contentHeight + 17
        if newHeight == self.chatActionBarView.inputTextViewCurrentHeight {
            return
        }
        self.chatActionBarView.inputTextViewCurrentHeight = newHeight
        self.controlExpandableInputView(showExpandable: true)
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        //设置键盘类型，响应 UIKeyboardWillShowNotification 事件
        self.chatActionBarView.inputTextViewCallKeyboard()

        //使 UITextView 滚动到末尾的区域
        UIView.setAnimationsEnabled(false)
        let range = NSRange(location: textView.text.count - 1, length: 1)
        textView.scrollRangeToVisible(range)
        UIView.setAnimationsEnabled(true)
        return true
    }
}

// MARK: - @protocol ChatCellDelegate
extension ChatPageList: ChatCellDelegate {
    func cellDidTapedFileButton(_ cell: ChatFileCell) {
        let config = DownloadConfig(fileName: cell.model?.filename ?? "", urlStr: cell.model?.content ?? "", sessionID: cell.model?.session_id ?? 0, messageID: cell.model?.msg_id ?? 0, chatType: cell.model?.chat_type ?? 0, cell: cell)
        let downloadVC = DownloadVC(nibName: "DownloadVC", bundle: nil, config: config)
        VCController.push(downloadVC, with: VCAnimationClassic.defaultAnimation())
    }

    /**
     点击了 cell 本身
     */
    func cellDidTaped(_ cell: ChatBaseCell) {
    }

    /**
     点击了 cell 的头像
     */
    func cellDidTapedAvatarImage(_ cell: ChatBaseCell) {
        //跳转个人中心
        let uid = cell.model?.sender
        let pid = cell.model?.sender_pid
        guard let safeID = uid, let safePID = pid else {
            HUDUtil.msg(msg: "找不到该用户信息", type: .error)
            return
        }
        PageRouter.shared.router(to: PageRouter.RouterPageType.personalCenterT(tuple: (safeID, safePID)))
    }
    // 图片模型
    func getPhotoModels(finish: @escaping ([PhotoModel]) -> Void) {
    }
    /**
     点击了 cell 的图片
     */
    func cellDidTapedImageView(_ cell: ChatBaseCell) {
        let model = cell.model
        let imgUrl = model?.content ?? ""
        let msgID = model?.msg_id
        // 移除所有本地图片
        localImages.removeAll()
        // 设置当前点击的cell
        self.clickedCell = cell
        //遍历图片数据
        var index = 0
        DatabaseTool.shared.queryAllPicUrl(with: currentSessionModel.session_id, chatType: currentSessionModel.chat_type, finish: { [weak self] photoStr in
            for (photoIndex, tuple) in photoStr.enumerated() {
                let (id, url, originalName) = tuple
                if !originalName.isEmpty { // 有本地图片，将路径添加到localImages中
                    let path = ImageFilesManager.cachePathForKey(originalName) ?? ""
                    self?.localImages.append(UIImage(contentsOfFile: path) ?? R.image.llplaceholder() ?? UIImage.from(color: UIColor(hexString: "#777777")))
                } else {
                    self?.localImages.append(nil)
                }
                // 找到图片对应的索引位置
                if id == msgID && imgUrl == url {
                    index = photoIndex
                }
            }
            // 创建图片浏览器
            let browser = PhotoBrowser(animationType: .scaleNoHiding, delegate: self, originPageIndex: index)
            // 光点型页码指示器
            browser.cellPlugins = [ProgressViewPlugin()]
            //        ,RawImageButtonPlugin()

            // 显示
            //                VCController.push(browser, swith: VCAnimationClassic.defaultAnimation())
            DatabaseTool.shared.queryAllPicUrl(with: self?.currentSessionModel.session_id ?? 0, chatType: self?.currentSessionModel.chat_type ?? 0, finish: { photoStr in
                var photoModelArr = [PhotoModel]()
                for photoTuple in photoStr {
                    let urlStr = photoTuple.1
                    let originalName = photoTuple.2
                    let photoModel = PhotoModel(thumbnailUrl: urlStr + "?imageMogr2/thumbnail/120x120!", highQualityUrl: urlStr + "?imageslim", rawUrl: urlStr, localName: originalName)
                    photoModelArr.append(photoModel)
                }
                self?.photoModelArr = photoModelArr
                browser.show(from: kWindowRootVC)
            })
        })
    }

    /**
     点击了 cell 中文字的 URL
     */
    func cellDidTapedLink(_ cell: ChatBaseCell, linkString: String) {
        let otherVC = OtherWebVC()
        otherVC.urlString = linkString
        VCController.push(otherVC, with: VCAnimationClassic.defaultAnimation())
    }

    /**
     点击了 cell 中文字的 电话
     */
    func cellDidTapedPhone(_ cell: ChatBaseCell, phoneString: String) {
        DeviceTool.makePhoneCall(with: phoneString)
    }

    /**
     点击了声音 cell 的播放 button
     */
    func cellDidTapedVoiceButton(_ cell: ChatVoiceCell, isPlayingVoice: Bool) {
        //在切换选中的语音 cell 之前把之前的动画停止掉
        if self.currentVoiceCell != nil && self.currentVoiceCell != cell {
            self.currentVoiceCell?.resetVoiceAnimation()
        }

//        if isPlayingVoice {
//            self.currentVoiceCell = cell
//            guard let audioID = cell.model?.audioID else {
//                AudioPlayInstance.stopPlayer()
//                return
//            }
//            AudioPlayInstance.startPlaying(audioModel)
//        } else {
//            AudioPlayInstance.stopPlayer()
//        }
    }
}

extension ChatPageList: PhotoBrowserDelegate {
    /// 图片总数量
    func numberOfPhotos(in photoBrowser: PhotoBrowser) -> Int {
        return photoModelArr.count
    }

    /// 缩略图所在 view
    func photoBrowser(_ photoBrowser: PhotoBrowser, thumbnailViewForIndex index: Int) -> UIView? {
        return (self.clickedCell as? ChatImageCell)?.chatImageView
    }

    /// 缩略图图片，在加载完成之前用作 placeholder 显示
    func photoBrowser(_ photoBrowser: PhotoBrowser, thumbnailImageForIndex index: Int) -> UIImage? {
        return nil
    }

    /// 高清图
    func photoBrowser(_ photoBrowser: PhotoBrowser, highQualityUrlForIndex index: Int) -> URL? {
        return photoModelArr[index].highQualityUrl.flatMap {
            if $0.hasPrefix("http://") || $0.hasPrefix("https://") {
                return URL(string: $0)
            } else {
                return URL(string: "http://\($0)")
            }
        }
    }

    func photoBrowser(_ photoBrowser: PhotoBrowser, localImageForIndex index: Int) -> UIImage? {
        return localImages[index]
    }

    /// 原图
    func photoBrowser(_ photoBrowser: PhotoBrowser, rawUrlForIndex index: Int) -> URL? {
        return photoModelArr[index].rawUrl.flatMap {
            if $0.hasPrefix("http://") || $0.hasPrefix("https://") {
                return URL(string: $0)
            } else {
                return URL(string: "http://\($0)")
            }
        }
    }

    // 保存到手机
    func photoBrowser(_ photoBrowser: PhotoBrowser, didLongPressForIndex index: Int, image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == PHAuthorizationStatus.authorized {
                let actionSheet = UIAlertController()
                actionSheet.addAction(title: "保存到手机") {[weak self] _ in
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self?.image(image:didFinishSavingWithError:contextInfo:)), nil)
                }
                actionSheet.addAction(title: "取消", style: .cancel, handler: nil)
                photoBrowser.present(actionSheet, animated: true, completion: nil)
            }
        }
    }

    @objc func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            HUDUtil.msg(msg: "保存成功", type: .successful)
        } else {
            HUDUtil.msg(msg: "保存失败，请重试", type: .error)
        }
    }
}
