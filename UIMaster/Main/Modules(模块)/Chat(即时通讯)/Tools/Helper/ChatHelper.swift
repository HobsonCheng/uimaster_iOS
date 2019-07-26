//
//  ChatHelper.swift
//  UIMaster
//
//  Created by hobson on 2018/11/19.
//  Copyright © 2018 one2much. All rights reserved.
//

import SwiftyJSON
import TZImagePickerController
import UIKit

class ChatHelper: NSObject, ChatShareMoreViewDelegate, AVPermissionCheckAble, UIShareAble {
    /// 会话数据模型
    fileprivate var chatSessionModel: ChatSessionModel?
    fileprivate var imagePicker = UIImagePickerController()   //照相机

    init(chatSessionModel: ChatSessionModel?) {
        self.chatSessionModel = chatSessionModel
        super.init()
    }

    override private init() {
        super.init()
    }

    func setChatSessionModel(chatSessionModel: ChatSessionModel?) {
        self.chatSessionModel = chatSessionModel
    }

    /// 文件按钮点击
    func chatShareMoreViewFileTaped() {
        let documentTypes = ["public.content", "public.text", "public.source-code ", "public.image", "p@objc(previewController:previewItemAtIndex:) ublic.audiovisual-content", "com.adobe.pdf", "com.apple.keynote.key", "com.microsoft.word.doc", "com.microsoft.excel.xls", "com.microsoft@objc(numberOfPreviewItemsInPreviewController:) .powerpoint.ppt"]

        let documentPicker = UIDocumentPickerViewController(documentTypes: documentTypes, in: UIDocumentPickerMode.open)
        documentPicker.delegate = self
        kWindowRootVC?.present(documentPicker, animated: true, completion: nil)
    }

    //点击打开相册
    func chatShareMoreViewPhotoTaped() {
        guard let imagePickerVC = TZImagePickerController(maxImagesCount: 9, delegate: self) else {
            return
        }
        imagePickerVC.allowPickingVideo = false
        imagePickerVC.didFinishPickingPhotosHandle = { photos, assets, finish in
            for photo in photos ?? [] {
                DispatchQueue.main.async {
                    self.resizeAndSendImage(photo)
                }
            }
        }
        kWindowRootVC?.present(imagePickerVC, animated: true, completion: nil)
    }

    func checkCameraPermission() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { granted in
            if !granted {
                HUDUtil.showAlert(title: "无法访问您的相机", message: "请到设置 -> 隐私 -> 相机 ，打开访问权限")
            }
        })
    }

    //

    //点击打开相机
    func chatShareMoreViewCameraTaped() {
        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .notDetermined {
            self.checkCameraPermission()
        } else if authStatus == .restricted || authStatus == .denied {
            HUDUtil.showAlert(title: "无法访问您的相机", message: "请到设置 -> 隐私 -> 相机 ，打开访问权限")
        } else if authStatus == .authorized {
            self.openCamera()
        }
    }

    func openCamera() {
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .camera
        kWindowRootVC?.present(self.imagePicker, animated: true, completion: nil)
    }
}

// 拍照完成，进行上传图片，并且发送的请求
extension ChatHelper: UINavigationControllerDelegate, UIImagePickerControllerDelegate, TZImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            dPrint("No image found")
            return
        }
        self.resizeAndSendImage(image)
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    //处理图片，并且发送图片消息
    func resizeAndSendImage(_ theImage: UIImage) {
        //FIXME:
        //        UIImage.fixImageOrientation(theImage)
        let originalImage = theImage
        let storeKey = "img_\(Int64(Date().timeIntervalSince1970 * 100_000))"
        let thumbSize = ImageScaler.getThumbImageSize(originalImage.size)

        //保存原图
        ImageFilesManager.storeImage(originalImage, key: storeKey + "_original", completionHandler: nil)
        //获取缩略图失败 ，抛出异常：发送失败
        guard let thumbNail = originalImage.resize(thumbSize) else {
            return
        }
        ImageFilesManager.storeImage(thumbNail, key: storeKey, completionHandler: { [weak self] in
            //发送图片消息
            let sendImageModel = ChatMessageModel()
            sendImageModel.msg_id = Int64(Date().getTimeIntervalSince1970())
            sendImageModel.imageHeight = originalImage.size.height
            sendImageModel.imageWidth = originalImage.size.width
            sendImageModel.session_id = self?.chatSessionModel?.session_id ?? 0
            sendImageModel.localStoreName = storeKey
            sendImageModel.localOriginalStoreName = storeKey + "_original"
            sendImageModel.sender = self?.chatSessionModel?.sender ?? 0
            sendImageModel.sender_pid = self?.chatSessionModel?.sender_pid ?? 0
            sendImageModel.receiver = self?.chatSessionModel?.receiver ?? 0
            sendImageModel.receiver_pid = self?.chatSessionModel?.receiver_pid ?? 0
            sendImageModel.groupPid = self?.chatSessionModel?.groupPid ?? 0
            sendImageModel.client_time = Date.currentTimeStr
            sendImageModel.kind = ChatMessageType.picture.rawValue
            sendImageModel.send_state = ChatSendStatus.sending.rawValue
            sendImageModel.chat_type = self?.chatSessionModel?.chat_type ?? 0
            DatabaseTool.shared.insertMessages(with: [sendImageModel])
            NotificationCenter.default.post(name: Notification.Name(kChatAddMessageNotification), object: sendImageModel)

            DatabaseTool.shared.modifyPicMessage(with: sendImageModel.msg_id, model: sendImageModel)
            /**
             *  异步上传原图, 然后上传成功后，把 model 值改掉
             *  但因为还没有找到上传的 API，所以这个函数会返回错误  T.T
             * //TODO: 原图尺寸略大，需要剪裁
             */
            UploadImageTool.uploadImage(
                image: originalImage,
                progress: { _, progress in
                    dPrint(progress)
                },
                success: { url in
                    //发送请求
                    guard let keys = getUserDefaults(key: kRC4Key) as? String else {
                        return
                    }
                    NetworkUtil.request(
                        target: NetworkService.addMessage(msg_type: sendImageModel.kind, content: RC4Tool.encryptRC4(with: url, key: keys), target_pid: sendImageModel.receiver_pid, send_time: sendImageModel.client_time, session: Int64(sendImageModel.session_id), file_name: "", client_id: Int64(sendImageModel.msg_id), target: sendImageModel.receiver, chat_type: sendImageModel.chat_type),
                        success: { json in
                            sendImageModel.content = url
                            DatabaseTool.shared.modifyPicMessage(with: sendImageModel.msg_id, model: sendImageModel)
                            var status = ChatSendStatus.success.rawValue
                            if BaseModel.deserialize(from: json)?.code != "0" {
                                status = ChatSendStatus.fail.rawValue
                            }
                            DatabaseTool.shared.modifySendState(sessionID: sendImageModel.session_id, chatType: sendImageModel.chat_type, msgID: sendImageModel.msg_id, state: status)
                        },
                        failure: { error in
                            DatabaseTool.shared.modifySendState(sessionID: sendImageModel.session_id, chatType: sendImageModel.chat_type, msgID: sendImageModel.msg_id, state: ChatSendStatus.fail.rawValue)
                            dPrint(error)
                        }
                    )
                    //修改缩略图的名称
                    //                let tempStorePath = URL(string:ImageFilesManager.cachePathForKey(storeKey)!)
                    //                let targetStorePath = URL(string:ImageFilesManager.cachePathForKey(sendImageModel.thumbURL)!)
                    //                ImageFilesManager.renameFile(tempStorePath!, destinationPath: targetStorePath!)
                },
                failure: { error in
                    DatabaseTool.shared.modifySendState(sessionID: sendImageModel.session_id, chatType: sendImageModel.chat_type, msgID: sendImageModel.msg_id, state: ChatSendStatus.fail.rawValue)
                    dPrint(error)
                }
            )
        })
    }
}

extension ChatHelper: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let arr = url.absoluteString.components(separatedBy: "/")
        let fileName = arr.last?.removingPercentEncoding ?? ""
        //检测iCloud可不可用
        guard FileManager.default.url(forUbiquityContainerIdentifier: nil) != nil else {
            HUDUtil.msg(msg: "iCloud不可用", type: .error)
            return
        }
        let doc = YJDocument(fileURL: url)

        doc.open { [weak self] finish in
            if finish {
                doc.close(completionHandler: { _ in
                    dPrint("关闭成功")
                })
            }
            guard let data = doc.data else {
                return
            }
            let fileUrl = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("com.one2much.app\(GlobalConfigTool.shared.appId ?? 0)/" + fileName)
            //将数据写入到路径下
            if let safeUrl = fileUrl {
                do {
                    try data.write(to: safeUrl, options: .atomic)

                    //发送图片消息
                    let sendFileModel = ChatMessageModel()
                    sendFileModel.msg_id = Int64(Date().getTimeIntervalSince1970())

                    sendFileModel.session_id = self?.chatSessionModel?.session_id ?? 0
                    sendFileModel.localStoreName = safeUrl.absoluteString.replacingOccurrences(of: "file://", with: "")
                    sendFileModel.sender = self?.chatSessionModel?.sender ?? 0
                    sendFileModel.sender_pid = self?.chatSessionModel?.sender_pid ?? 0
                    sendFileModel.receiver = self?.chatSessionModel?.receiver ?? 0
                    sendFileModel.receiver_pid = self?.chatSessionModel?.receiver_pid ?? 0
                    sendFileModel.client_time = Date.currentTimeStr
                    sendFileModel.groupPid = self?.chatSessionModel?.groupPid ?? 0
                    sendFileModel.filename = fileName
                    sendFileModel.kind = ChatMessageType.file.rawValue
                    sendFileModel.send_state = ChatSendStatus.sending.rawValue
                    sendFileModel.chat_type = self?.chatSessionModel?.chat_type ?? 0
                    DatabaseTool.shared.insertMessages(with: [sendFileModel])
                    NotificationCenter.default.post(name: Notification.Name(kChatAddMessageNotification), object: sendFileModel)
                    DatabaseTool.shared.modifyPicMessage(with: sendFileModel.msg_id, model: sendFileModel)
                    UploadImageTool.uploadFile(
                        filePath: safeUrl.absoluteString,
                        progress: { _, progress in
                            dPrint(progress)
                        },
                        success: { url in
                            guard let keys = getUserDefaults(key: kRC4Key) as? String else {
                                return
                            }
                            //发送请求
                            NetworkUtil.request(
                                target: NetworkService.addMessage(msg_type: sendFileModel.kind, content: RC4Tool.encryptRC4(with: url, key: keys), target_pid: sendFileModel.receiver_pid, send_time: sendFileModel.client_time, session: Int64(sendFileModel.session_id), file_name: fileName, client_id: Int64(sendFileModel.msg_id), target: sendFileModel.receiver, chat_type: sendFileModel.chat_type),
                                success: { json in
                                    sendFileModel.content = url
                                    DatabaseTool.shared.modifyPicMessage(with: sendFileModel.msg_id, model: sendFileModel)
                                    var status = ChatSendStatus.success.rawValue
                                    if BaseModel.deserialize(from: json)?.code != "0" {
                                        status = ChatSendStatus.fail.rawValue
                                    }
                                    DatabaseTool.shared.modifySendState(sessionID: sendFileModel.session_id, chatType: sendFileModel.chat_type, msgID: sendFileModel.msg_id, state: status)
                                },
                                failure: { error in
                                    DatabaseTool.shared.modifySendState(sessionID: sendFileModel.session_id, chatType: sendFileModel.chat_type, msgID: sendFileModel.msg_id, state: ChatSendStatus.fail.rawValue)
                                    dPrint(error)
                                }
                            )
                        },
                        failure: { error in
                            DatabaseTool.shared.modifySendState(sessionID: sendFileModel.session_id, chatType: sendFileModel.chat_type, msgID: sendFileModel.msg_id, state: ChatSendStatus.fail.rawValue)
                            dPrint(error)
                        }
                    )
                } catch {
                    dPrint(error)
                }
            }
        }
    }
}

// MARK: - @extension TSChatViewController
extension ChatHelper {
    /// 发送文字
    ///
    /// - Parameter actionBarView: 输入栏视图对象
    func chatSendText(actionBarView: ChatActionBarView) {
        dispatch_async_safely_to_main_queue({ [weak self] in
            guard let textView = actionBarView.inputChatView else {
                return
            }
            guard textView.text.count <= 1_000 else {
                HUDUtil.msg(msg: "超出1000字数限制", type: .error)
                return
            }

            let text = textView.text.trimmingCharacters(in: CharacterSet.whitespaces)
            if text.isEmpty {
                return
            }

            let string = actionBarView.inputChatView.text
            var modelArr = [ChatMessageModel]()
            let model = ChatMessageModel()
            model.content = string ?? ""
            model.msg_id = Int64(Date().getTimeIntervalSince1970())
            model.session_id = self?.chatSessionModel?.session_id ?? 0
            model.client_time = Date.currentTimeStr
            model.server_time = Date.currentTimeStr
            model.groupPid = self?.chatSessionModel?.groupPid ?? 0
            model.direction = ChatDirection.sendToOthers.rawValue
            model.chat_type = self?.chatSessionModel?.chat_type ?? 0
            model.kind = ChatMessageType.text.rawValue
            model.receiver = self?.chatSessionModel?.receiver ?? 0
            model.receiver_pid = self?.chatSessionModel?.receiver_pid ?? 0
            model.sender = self?.chatSessionModel?.sender ?? 0
            model.sender_pid = self?.chatSessionModel?.sender_pid ?? 0
            model.send_state = ChatSendStatus.sending.rawValue
            // 添加数据模型
            modelArr.append(model)

            //写入数据库
            DatabaseTool.shared.insertMessages(with: modelArr)
            NotificationCenter.default.post(name: Notification.Name(kChatAddMessageNotification), object: model)
            textView.text = "" //发送完毕后清空
            DatabaseTool.shared.modifyDraft(with: self?.chatSessionModel?.session_id ?? 0, chatType: model.chat_type, content: "")

            //发送请求
            NetworkUtil.request(
                target: NetworkService.addMessage(msg_type: model.kind, content: model.content.rc4EncodeStr, target_pid: model.receiver_pid, send_time: model.client_time, session: Int64(model.session_id), file_name: "", client_id: Int64(model.msg_id), target: model.receiver, chat_type: model.chat_type),
                success: { json in
                    var status = ChatSendStatus.success.rawValue
                    if BaseModel.deserialize(from: json)?.code != "0" {
                        status = ChatSendStatus.fail.rawValue
                    }
                    DatabaseTool.shared.modifySendState(sessionID: model.session_id, chatType: model.chat_type, msgID: model.msg_id, state: status)
                },
                failure: { error in
                    DatabaseTool.shared.modifySendState(sessionID: model.session_id, chatType: model.chat_type, msgID: model.msg_id, state: ChatSendStatus.fail.rawValue)
                    dPrint(error)
                }
            )

//            strongSelf.itemList.append(model)
//            let insertIndexPath = IndexPath(row: strongSelf.itemList.count - 1, section: 0)
//            strongSelf.listTableView.insertRowsAtBottom([insertIndexPath])
            //            strongSelf.textViewDidChange(strongSelf.chatActionBarView.inputChatView)
        })
    }

    /**
     发送声音
     */
    func chatSendVoice(_ audioModel: ChatMessageModel) {
        //        dispatch_async_safely_to_main_queue({[weak self] in
        //            guard let strongSelf = self else { return }
        //            let model = ChatModel(audioModel: audioModel)
        //            strongSelf.itemDataSouce.append(model)
        //            let insertIndexPath = IndexPath(row: strongSelf.itemDataSouce.count - 1, section: 0)
        //            strongSelf.listTableView.insertRowsAtBottom([insertIndexPath])
        //        })
    }
}

// MARK: - @protocol RecordAudioDelegate
// 语音录制完毕后
//extension ChatHelper: RecordAudioDelegate {
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
////    func audioRecordCanceled() {
////
////    }
//}

// MARK: - 重发消息
extension ChatHelper {
    static func reSendMsg(type: ChatMessageType, model: ChatMessageModel) {
        if model.kind == ChatMessageType.text.rawValue {
            DatabaseTool.shared.modifySendState(sessionID: model.session_id, chatType: model.chat_type, msgID: model.msg_id, state: ChatSendStatus.sending.rawValue)
            //发送请求
            NetworkUtil.request(
                target: NetworkService.addMessage(msg_type: model.kind, content: model.content.rc4EncodeStr, target_pid: model.receiver_pid, send_time: model.client_time, session: Int64(model.session_id), file_name: "", client_id: Int64(model.msg_id), target: model.receiver, chat_type: model.chat_type),
                success: { json in
                    var status = ChatSendStatus.success.rawValue
                    if BaseModel.deserialize(from: json)?.code != "0" {
                        status = ChatSendStatus.fail.rawValue
                    }
                    DatabaseTool.shared.modifySendState(sessionID: model.session_id, chatType: model.chat_type, msgID: model.msg_id, state: status)
                },
                failure: { error in
                    DatabaseTool.shared.modifySendState(sessionID: model.session_id, chatType: model.chat_type, msgID: model.msg_id, state: ChatSendStatus.fail.rawValue)
                    dPrint(error)
                }
            )
        } else if model.kind == ChatMessageType.picture.rawValue {
            DatabaseTool.shared.modifySendState(sessionID: model.session_id, chatType: model.chat_type, msgID: model.msg_id, state: ChatSendStatus.sending.rawValue)
            if !model.content.isEmpty {
                guard let key = getUserDefaults(key: kRC4Key) as? String else {
                    return
                }
                //发送请求
                NetworkUtil.request(
                    target: NetworkService.addMessage(msg_type: model.kind, content: RC4Tool.encryptRC4(with: model.content, key: key), target_pid: model.receiver_pid, send_time: model.client_time, session: Int64(model.session_id), file_name: "", client_id: Int64(model.msg_id), target: model.receiver, chat_type: model.chat_type),
                    success: { json in
                        var status = ChatSendStatus.success.rawValue
                        if BaseModel.deserialize(from: json)?.code != "0" {
                            status = ChatSendStatus.fail.rawValue
                        }
                        DatabaseTool.shared.modifySendState(sessionID: model.session_id, chatType: model.chat_type, msgID: model.msg_id, state: status)
                    },
                    failure: { error in
                        DatabaseTool.shared.modifySendState(sessionID: model.session_id, chatType: model.chat_type, msgID: model.msg_id, state: ChatSendStatus.fail.rawValue)
                        dPrint(error)
                    }
                )
            } else {
                guard let originalImage = model.localoriginalStoreImage else {
                    DatabaseTool.shared.modifySendState(sessionID: model.session_id, chatType: model.chat_type, msgID: model.msg_id, state: ChatSendStatus.fail.rawValue)
                    return
                }
                UploadImageTool.uploadImage(
                    image: originalImage,
                    progress: { _, progress in
                        dPrint(progress)
                    },
                    success: { url in
                        model.content = url
                        DatabaseTool.shared.modifyPicMessage(with: model.msg_id, model: model)
                        //发送请求
                        guard let key = getUserDefaults(key: kRC4Key) as? String else {
                            return
                        }
                        NetworkUtil.request(
                            target: NetworkService.addMessage(msg_type: model.kind, content: RC4Tool.encryptRC4(with: url, key: key), target_pid: model.receiver_pid, send_time: model.client_time, session: Int64(model.session_id), file_name: "", client_id: Int64(model.msg_id), target: model.receiver, chat_type: model.chat_type),
                            success: { json in
                                var status = ChatSendStatus.success.rawValue
                                if BaseModel.deserialize(from: json)?.code != "0" {
                                    status = ChatSendStatus.fail.rawValue
                                }
                                DatabaseTool.shared.modifySendState(sessionID: model.session_id, chatType: model.chat_type, msgID: model.msg_id, state: status)
                            },
                            failure: { error in
                                DatabaseTool.shared.modifySendState(sessionID: model.session_id, chatType: model.chat_type, msgID: model.msg_id, state: ChatSendStatus.fail.rawValue)
                                dPrint(error)
                            }
                        )
                        //修改缩略图的名称
                        //                let tempStorePath = URL(string:ImageFilesManager.cachePathForKey(storeKey)!)
                        //                let targetStorePath = URL(string:ImageFilesManager.cachePathForKey(model.thumbURL)!)
                        //                ImageFilesManager.renameFile(tempStorePath!, destinationPath: targetStorePath!)
                    },
                    failure: { error in
                        DatabaseTool.shared.modifySendState(sessionID: model.session_id, chatType: model.chat_type, msgID: model.msg_id, state: ChatSendStatus.fail.rawValue)
                        dPrint(error)
                    }
                )
            }
        } else if model.kind == ChatMessageType.file.rawValue {
            DatabaseTool.shared.modifySendState(sessionID: model.session_id, chatType: model.chat_type, msgID: model.msg_id, state: ChatSendStatus.sending.rawValue)
            if !model.content.isEmpty {//已经上传成功
                guard let key = getUserDefaults(key: kRC4Key) as? String else {
                    return
                }
                //发送请求
                NetworkUtil.request(
                    target: NetworkService.addMessage(msg_type: model.kind, content: RC4Tool.encryptRC4(with: model.content, key: key), target_pid: model.receiver_pid, send_time: model.client_time, session: Int64(model.session_id), file_name: model.filename, client_id: Int64(model.msg_id), target: model.receiver, chat_type: model.chat_type),
                    success: { json in
                        var status = ChatSendStatus.success.rawValue
                        if BaseModel.deserialize(from: json)?.code != "0" {
                            status = ChatSendStatus.fail.rawValue
                        }
                        DatabaseTool.shared.modifySendState(sessionID: model.session_id, chatType: model.chat_type, msgID: model.msg_id, state: status)
                    },
                    failure: { error in
                        DatabaseTool.shared.modifySendState(sessionID: model.session_id, chatType: model.chat_type, msgID: model.msg_id, state: ChatSendStatus.fail.rawValue)
                        dPrint(error)
                    }
                )
            } else {
                guard !model.localStoreName.isEmpty else {
                    DatabaseTool.shared.modifySendState(sessionID: model.session_id, chatType: model.chat_type, msgID: model.msg_id, state: ChatSendStatus.fail.rawValue)
                    return
                }
                UploadImageTool.uploadFile(
                    filePath: model.localStoreName,
                    progress: { _, _ in
                    },
                    success: { url in
                        model.content = url
                        DatabaseTool.shared.modifyPicMessage(with: model.msg_id, model: model)
                        //发送请求
                        guard let keyIsString = getUserDefaults(key: kRC4Key) as? String else {
                            return
                        }
                        NetworkUtil.request(
                            target: NetworkService.addMessage(msg_type: model.kind, content: RC4Tool.encryptRC4(with: model.content, key: keyIsString), target_pid: model.receiver_pid, send_time: model.client_time, session: Int64(model.session_id), file_name: model.filename, client_id: Int64(model.msg_id), target: model.receiver, chat_type: model.chat_type),
                            success: { json in
                                var status = ChatSendStatus.success.rawValue
                                if BaseModel.deserialize(from: json)?.code != "0" {
                                    status = ChatSendStatus.fail.rawValue
                                }
                                DatabaseTool.shared.modifySendState(sessionID: model.session_id, chatType: model.chat_type, msgID: model.msg_id, state: status)
                            },
                            failure: { error in
                                DatabaseTool.shared.modifySendState(sessionID: model.session_id, chatType: model.chat_type, msgID: model.msg_id, state: ChatSendStatus.fail.rawValue)
                                dPrint(error)
                            }
                        )
                    },
                    failure: { error in
                        DatabaseTool.shared.modifySendState(sessionID: model.session_id, chatType: model.chat_type, msgID: model.msg_id, state: ChatSendStatus.fail.rawValue)
                        dPrint(error)
                    })
            }
        }
    }
}
