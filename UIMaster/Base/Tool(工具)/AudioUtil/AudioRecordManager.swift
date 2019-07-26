////
////  AudioRecordManager.swift
////  UIMaster
////
////  Created by hobson on 2019/2/13.
////  Copyright © 2019 one2much. All rights reserved.
////
//
//import UIKit
//import AVFoundation
//
///// 录音工具类
//class AudioRecordManager: NSObject {
//    var recorder: AVAudioRecorder!
//    var operationQueue: OperationQueue!
//    weak var delegate: RecordAudioDelegate?
//    static let instance : AudioRecordManager = AudioRecordManager()
//    
//    fileprivate var startTime: CFTimeInterval! //录音开始时间
//    fileprivate var endTimer: CFTimeInterval! //录音结束时间
//    fileprivate var audioTimeInterval: NSNumber!
//    fileprivate var isFinishRecord: Bool = true
//    fileprivate var isCancelRecord: Bool = false
//    private let tempWavRecordPath = AudioFilesManager.wavPathWithName("wav_temp_record") //wav 临时路径
//    private let tempAmrFilePath = AudioFilesManager.amrPathWithName("amr_temp_record")   //amr 临时路径
//    
//    
//    fileprivate override init() {
//        self.operationQueue = OperationQueue()
//        super.init()
//    }
//    
//    
//    /// 检测录音权限
//    func checkPermissionAndSetupRecord() {
//        let session = AVAudioSession.sharedInstance()
//        do {
//            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .duckOthers)
//            do {
//                try session.setActive(true)
//                session.requestRecordPermission{allowed in
//                    if !allowed {
//                        HUDUtil.showAlert(title: "无法访问您的麦克风", message: "请到设置 -> 隐私 -> 麦克风 ，打开访问权限")
//                    }
//                }
//            } catch let error as NSError {
//                HUDUtil.showAlert(title: "无法访问您的麦克风", message: error.localizedFailureReason!)
//            }
//        } catch let error as NSError {
//            HUDUtil.showAlert(title: "无法访问您的麦克风", message: error.localizedFailureReason!)
//        }
//    }
//    
//    /// 监听耳机插入
//    func checkHeadphones() {
//        // check NewDeviceAvailable and OldDeviceUnavailable for them being plugged in/unplugged
//        let currentRoute = AVAudioSession.sharedInstance().currentRoute
//        if currentRoute.outputs.count > 0 {
//            for description in currentRoute.outputs {
//                if description.portType == AVAudioSessionPortHeadphones {
//                    dPrint("headphones are plugged in")
//                    break
//                } else {
//                    dPrint("headphones are unplugged")
//                }
//            }
//        } else {
//            dPrint("checking headphones requires a connection to a device")
//        }
//    }
//    
//    /// 开始录音
//    func startRecord() {
//        self.isCancelRecord = false
//        self.startTime = CACurrentMediaTime()
//        //        self.tempAudioFileURL = AudioFilesManager.wavPathWithName(kTempWavRecordName)
//        do {
//            //基础参数
//            let recordSettings:[String : AnyObject] = [
//                //线性采样位数  8、16、24、32
//                AVLinearPCMBitDepthKey: NSNumber(value: 16 as Int32),
//                //设置录音格式  AVFormatIDKey == kAudioFormatLinearPCM
//                AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM as UInt32),
//                //录音通道数  1 或 2
//                AVNumberOfChannelsKey: NSNumber(value: 1 as Int32),
//                //设置录音采样率(Hz) 如：AVSampleRateKey == 8000/44100/96000（影响音频的质量）
//                AVSampleRateKey: NSNumber(value: 8000.0 as Float),
//                ]
//            
//            self.recorder = try AVAudioRecorder(url: tempWavRecordPath, settings: recordSettings)
//            self.recorder.delegate = self
//            self.recorder.isMeteringEnabled = true
//            self.recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
//        } catch let error as NSError {
//            self.recorder = nil
//            HUDUtil.showAlert("初始化录音功能失败", message: error.localizedDescription)
//        }
//        self.perform(#selector(AudioRecordManager.readyStartRecord), with: self, afterDelay: 0.0)
//    }
//    
//    /// 更新进度
//    func updateMeters() {
//        guard let recorder = self.recorder else { return }
//        
//        repeat {
//            recorder.updateMeters()
//            self.audioTimeInterval = NSNumber(value: NSNumber(value: recorder.currentTime as Double).floatValue as Float)
//            let averagePower = recorder.averagePower(forChannel: 0)
//            let lowPassResults = pow(10, (0.05 * averagePower)) * 10
//            dispatch_async_safely_to_main_queue({ () -> () in
//                self.delegate?.audioRecordUpdateMetra(lowPassResults)
//            })
//            //如果大于 60 ,停止录音
//            if self.audioTimeInterval.int32Value > 60 {
//                self.stopRecord()
//            }
//            
//            Thread.sleep(forTimeInterval: 0.05)
//        } while(recorder.isRecording)
//    }
//    /**
//     停止录音
//     */
//    func stopRecord() {
//        self.isFinishRecord = true
//        self.isCancelRecord = false
//        self.endTimer = CACurrentMediaTime()
//        if (self.endTimer - self.startTime) < 0.5 {
//            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(AudioRecordManager.readyStartRecord), object: self)
//            dispatch_async_safely_to_main_queue({ () -> () in
//                self.delegate?.audioRecordTooShort()
//            })
//        } else {
//            self.audioTimeInterval = NSNumber(value: NSNumber(value: self.recorder.currentTime as Double).int32Value as Int32)
//            if self.audioTimeInterval.int32Value < 1 {
//                self.perform(#selector(AudioRecordManager.readyStopRecord), with: self, afterDelay: 0.4)
//            } else {
//                self.readyStopRecord()
//            }
//        }
//        self.operationQueue.cancelAllOperations()
//    }
//    
//    /**
//     取消录音
//     */
//    func cancelRrcord() {
//        self.isCancelRecord = true
//        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(AudioRecordManager.readyStartRecord), object: self)
//        self.isFinishRecord = false
//        self.recorder.stop()
//        self.recorder.deleteRecording()
//        self.recorder = nil
//        self.delegate?.audioRecordCanceled()
//    }
//    
//    @objc func readyStopRecord() {
//        self.recorder.stop()
//        self.recorder = nil
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setActive(false, with: .notifyOthersOnDeactivation)
//        } catch let error as NSError {
//            log.error("error:\(error)")
//        }
//    }
//    
//    /**
//     删除录音文件
//     */
//    func deleteRecordFiles() {
//        AudioFilesManager.deleteAllRecordingFiles()
//    }
//}
//
//// MARK: - @protocol AVAudioRecorderDelegate
//extension AudioRecordManager : AVAudioRecorderDelegate {
//    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
//        if flag && self.isFinishRecord {
//            //转换 amr 音频文件
//            if TSVoiceConverter.convertWavToAmr(TempWavRecordPath.path, amrSavePath: TempAmrFilePath.path) {
//                //获取 amr 文件的 NSData, 改名字使用
//                guard let amrAudioData = try? Data(contentsOf: TempAmrFilePath) else {
//                    self.delegate?.audioRecordFailed()
//                    return
//                }
//                let fileName = amrAudioData.ts_md5String
//                let amrDestinationURL = AudioFilesManager.amrPathWithName(fileName)
//                log.warning("amr destination URL:\(amrDestinationURL)")
//                AudioFilesManager.renameFile(TempAmrFilePath, destinationPath: amrDestinationURL)
//                
//                //缓存：将录音 temp 文件改名为 amr 文件 NSData 的 md5 值
//                let wavDestinationURL = AudioFilesManager.wavPathWithName(fileName)
//                AudioFilesManager.renameFile(TempWavRecordPath, destinationPath: wavDestinationURL)
//                
//                self.delegate?.audioRecordFinish(amrAudioData, recordTime: self.audioTimeInterval.floatValue, fileHash: fileName)
//            } else {
//                self.delegate?.audioRecordFailed()
//            }
//        } else {
//            //如果不是取消录音，再进行回调 failed 方法
//            if !self.isCancelRecord {
//                self.delegate?.audioRecordFailed()
//            }
//        }
//    }
//    
//    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
//        if let e = error {
//            log.error("\(e.localizedDescription)")
//            self.delegate?.audioRecordFailed()
//        }
//    }
//}
