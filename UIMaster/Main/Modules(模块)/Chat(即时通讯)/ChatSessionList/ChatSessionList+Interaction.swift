//
//  ChatSessionList+Interaction.swift
//  UIMaster
//
//  Created by hobson on 2018/10/11.
//  Copyright © 2018 one2much. All rights reserved.
//

import Foundation
import Photos
import TZImagePickerController
// MARK: - 分享更多里面的 Button 交互
//extension ChatSessionList: ChatShareMoreViewDelegate,TZImagePickerControllerDelegate {
//
//    func chatShareMoreViewFileTaped() {
//        let documentTypes = ["public.content", "public.text", "public.source-code ", "public.image", "p@objc(previewController:previewItemAtIndex:) ublic.audiovisual-content", "com.adobe.pdf", "com.apple.keynote.key", "com.microsoft.word.doc", "com.microsoft.excel.xls", "com.microsoft@objc(numberOfPreviewItemsInPreviewController:) .powerpoint.ppt"];
//
//        let documentPicker = UIDocumentPickerViewController.init(documentTypes: documentTypes, in: UIDocumentPickerMode.open)
//        documentPicker.delegate = self
//        kWindowRootVC?.present(documentPicker, animated: true, completion: nil)
//    }
//
//    //选择打开相册
//    func chatShareMoreViewPhotoTaped() {
//        guard let imagePickerVC = TZImagePickerController.init(maxImagesCount: 9, delegate: self) else{ return }
//        imagePickerVC.allowPickingVideo = false
//        imagePickerVC.didFinishPickingPhotosHandle = { (photos,assets,finish) in
//            for photo in photos ?? []{
//
//                DispatchQueue.main.async {
//                    self.resizeAndSendImage(photo)
//                }
//
//            }
//        }
//        kWindowRootVC?.present(imagePickerVC, animated: true, completion: nil)
//    }
//
//    //处理打开相机
//    func chatShareMoreViewCameraTaped() {
//        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
//        if authStatus == .notDetermined {
//            self.checkCameraPermission()
//        } else if authStatus == .restricted || authStatus == .denied {
//            HUDUtil.showAlert(title: "无法访问您的相机", message: "请到设置 -> 隐私 -> 相机 ，打开访问权限")
//        } else if authStatus == .authorized {
//            self.openCamera()
//        }
//    }
//
//
//    /// 获取相机权限
//    func checkCameraPermission () {
//        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {granted in
//            if !granted {
//                HUDUtil.showAlert(title: "无法访问您的相机", message: "请到设置 -> 隐私 -> 相机 ，打开访问权限")
//            }
//        })
//    }
//
//    /// 打开相机
//    func openCamera() {
//        self.imagePicker =  UIImagePickerController()
//        self.imagePicker.delegate = self
//        self.imagePicker.sourceType = .camera
//        kWindowRootVC?.present(self.imagePicker, animated: true, completion: nil)
//    }
//
//    //处理图片，并且发送图片消息
//    func resizeAndSendImage(_ theImage: UIImage) {
//        //        UIImage.fixImageOrientation(theImage)
//        let originalImage = theImage
//        let storeKey = "\(Int64(Date().timeIntervalSince1970 * 100000))"
//        let thumbSize = imageScaler.getThumbImageSize(originalImage.size)
//
//        //获取缩略图失败 ，抛出异常：发送失败
//        guard let thumbNail = originalImage.resize(thumbSize) else { return }
//        ImageFilesManager.storeImage(thumbNail, key: storeKey, completionHandler: { [weak self] in
//            guard let strongSelf = self else { return }
//            //发送图片消息
//
//            let sendImageModel = ChatMessageModel()
//            sendImageModel.msg_id = Int64(Date().getTimeIntervalSince1970())
//            sendImageModel.imageHeight = originalImage.size.height
//            sendImageModel.imageWidth = originalImage.size.width
//            sendImageModel.session_id = self?.currentModel?.session_id ?? 0
//            sendImageModel.groupPid = self?.currentModel?.groupPid ?? 0
//            sendImageModel.localStoreName = storeKey
//            sendImageModel.sender = self?.currentModel?.sender ?? 0
//            sendImageModel.sender_pid = self?.currentModel?.sender_pid ?? 0
//            sendImageModel.receiver = self?.currentModel?.receiver ?? 0
//            sendImageModel.receiver_pid = self?.currentModel?.receiver_pid ?? 0
//            sendImageModel.client_time = Date.currentTimeStr
//            sendImageModel.kind = ChatMessageType.picture.rawValue
//            sendImageModel.send_state = ChatSendStatus.sending.rawValue
//            sendImageModel.chat_type = self?.currentModel?.chat_type ?? 0
//            strongSelf.chatSendImage(sendImageModel)
//
//            self?.hideAllKeyboard()
//            /**
//             *  异步上传原图, 然后上传成功后，把 model 值改掉
//             *  但因为还没有找到上传的 API，所以这个函数会返回错误  T.T
//             */
//            UploadImageTool.uploadImage(image: originalImage, progress: { (_, progress) in
//
//            }, success: { (url) in
//                sendImageModel.content = url
//                sendImageModel.send_state = ChatSendStatus.success.rawValue
//                DatabaseTool.shared.modifyPicMessage(with: sendImageModel.msg_id , model: sendImageModel)
//
//                //发送请求
//                NetworkUtil.request(target: NetworkService.addMessage(msg_type: sendImageModel.kind, content: RC4Tool.encryptRC4(with: url, key: getUserDefaults(key: kRC4Key) as! String), target_pid: sendImageModel.receiver_pid, send_time: sendImageModel.client_time, session: Int64(sendImageModel.session_id), file_name: "", client_id: Int64(sendImageModel.msg_id), target: sendImageModel.receiver), success: { (json) in
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
////MARK: - 选择文件
//extension ChatSessionList: UIDocumentPickerDelegate{
//
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
//                self?.resizeAndSendImage(img)
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
//
//                    sendFileModel.session_id = self?.currentModel?.session_id ?? 0
//                    sendFileModel.localStoreName = safeUrl.absoluteString.replacingOccurrences(of: "file://", with: "")
//                    sendFileModel.sender = self?.currentModel?.sender ?? 0
//                    sendFileModel.sender_pid = self?.currentModel?.sender_pid ?? 0
//                    sendFileModel.receiver = self?.currentModel?.receiver ?? 0
//                    sendFileModel.receiver_pid = self?.currentModel?.receiver_pid ?? 0
//                    sendFileModel.groupPid = self?.currentModel?.groupPid ?? 0
//                    sendFileModel.client_time = Date.currentTimeStr
//                    sendFileModel.filename = fileName
//                    sendFileModel.kind = ChatMessageType.file.rawValue
//                    sendFileModel.send_state = ChatSendStatus.sending.rawValue
//                    sendFileModel.chat_type = self?.currentModel?.chat_type ?? 0
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
//// MARK: - @protocol UIImagePickerControllerDelegate
//// 拍照完成，进行上传图片，并且发送的请求
//extension ChatSessionList: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        guard let image: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
//        if picker.sourceType == .camera {
//            self.resizeAndSendImage(image)
//        }
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//}
//
//
//// MARK: - @protocol RecordAudioDelegate
//// 语音录制完毕后
//extension ChatSessionList: RecordAudioDelegate {
//    func audioRecordUpdateMetra(_ metra: Float) {
////        self.voiceIndicatorView.updateMetersValue(metra)
//    }
//
//    func audioRecordTooShort() {
////        self.voiceIndicatorView.messageTooShort()
//    }
//
//    func audioRecordFinish(_ uploadAmrData: Data, recordTime: Float, fileHash: String) {
////        self.voiceIndicatorView.endRecord()
//
//        //发送本地音频
////        let audioModel = ChatAudioModel()
////        audioModel.keyHash = fileHash
////        audioModel.audioURL = ""
////        audioModel.duration = recordTime
////        self.chatSendVoice(audioModel)
//
//        /**
//         *  异步上传音频文件, 然后上传成功后，把 model 值改掉
//         *  因为还没有上传的 API，所以这个函数会返回错误  T.T
//         */
////        HttpManager.uploadAudio(uploadAmrData, recordTime: String(recordTime), success: {model in
////            audioModel.keyHash = model.keyHash
////            audioModel.audioURL = model.audioURL
////            audioModel.duration = recordTime
////        }, failure: {
////
////        })
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
//
//// MARK: - @protocol PlayAudioDelegate
//extension ChatSessionList: PlayAudioDelegate {
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
//extension ChatSessionList: ChatEmotionInputViewDelegate {
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
extension ChatSessionList: UITextViewDelegate {
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

        self.chatActionBarView.inputTextViewCurrentHeight = contentHeight + 17
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
