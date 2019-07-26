//
//  ScanViewController.swift
//  swiftScan
//
//  Created by ia on 15/12/8.
//  Copyright © 2015年 xialibing. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

protocol ScanViewControllerDelegate {
     func scanFinished(scanResult: ScanResult, error: String?)
}

class ScanViewController: NaviBarVC, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 //返回扫码结果，也可以通过继承本控制器，改写该handleCodeResult方法即可
   var scanResultDelegate: ScanViewControllerDelegate?

   var scanObj: ScanWrapper?

   var scanStyle: ScanViewStyle? = ScanViewStyle()

   var qRScanView: ScanView?

    //启动区域识别功能
   var isOpenInterestRect = false
    //识别码的类型
   public var arrayCodeType: [AVMetadataObject.ObjectType]?

    //是否需要识别后的当前图像
   public  var isNeedCodeImage = false

    //相机启动提示文字
    public var readyString: String! = "loading"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

              // [self.view addSubview:_qRScanView];
        self.view.backgroundColor = UIColor.black
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
    }

    func setNeedCodeImage(needCodeImg: Bool) {
        isNeedCodeImage = needCodeImg
    }
    //设置框内识别
    func setOpenInterestRect(isOpen: Bool) {
        isOpenInterestRect = isOpen
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        drawScanView()

        perform(#selector(ScanViewController.startScan), with: nil, afterDelay: 0.3)
    }

    @objc func startScan() {
        if (scanObj == nil) {
            var cropRect = CGRect.zero
            if isOpenInterestRect {
                cropRect = ScanView.getScanRectWithPreView(preView: self.view, style: scanStyle! )
            }

            //指定识别几种码
            if arrayCodeType == nil {
                arrayCodeType = [AVMetadataObject.ObjectType.qr, AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.code128]
            }

            scanObj = ScanWrapper(videoPreView: self.view, objType: arrayCodeType!, isCaptureImg: isNeedCodeImage, cropRect: cropRect, success: { [weak self] arrayResult -> Void in
                if let strongSelf = self {
                    //停止扫描动画
                    strongSelf.qRScanView?.stopScanAnimation()

                    strongSelf.handleCodeResult(arrayResult: arrayResult)
                }
             })
        }

        //结束相机等待提示
        qRScanView?.deviceStopReadying()

        //开始扫描动画
        qRScanView?.startScanAnimation()

        //相机运行
        scanObj?.start()
    }

    func drawScanView() {
        if qRScanView == nil {
            qRScanView = ScanView(frame: self.view.frame, vstyle: scanStyle! )

            qRScanView?.top = self.naviBar?.bottom ?? 64
            self.view.addSubview(qRScanView!)
        }
        qRScanView?.deviceStartReadying(readyStr: readyString)
    }

    /**
     处理扫码结果，如果是继承本控制器的，可以重写该方法,作出相应地处理，或者设置delegate作出相应处理
     */

    func handleCodeResult(arrayResult: [ScanResult]) {
        if let delegate = scanResultDelegate {
            self.navigationController? .popViewController(animated: true)
            let result: ScanResult = arrayResult[0]

            delegate.scanFinished(scanResult: result, error: nil)
        } else {
            for result: ScanResult in arrayResult {
                dPrint("\(result.strScanned ?? "")")
            }

            let result: ScanResult = arrayResult[0]

            showMsg(title: result.strBarCodeType, message: result.strScanned)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)

        qRScanView?.stopScanAnimation()

        scanObj?.stop()
    }

    func openPhotoAlbum() {
        Permissions.authorizePhotoWith { [weak self] _ in
            let picker = UIImagePickerController()

            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary

            picker.delegate = self

            picker.allowsEditing = true

           self?.present(picker, animated: true, completion: nil)
        }
    }

    // MARK: - ----相册选择图片识别二维码 （条形码没有找到系统方法）
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true, completion: nil)
        var image: UIImage? = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }

        if image != nil {
            let arrayResult = ScanWrapper.recognizeQRImage(image: image!)
            if !arrayResult.isEmpty {
                handleCodeResult(arrayResult: arrayResult)
                return
            }
        }

        showMsg(title: nil, message: NSLocalizedString("Identify failed", comment: "Identify failed"))
    }

    func showMsg(title: String?, message: String?) {
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
            let alertAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.default) { _ in
//                if let strongSelf = self
//                {
//                    strongSelf.startScan()
//                }
            }

            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
    }

    deinit {
//        dPrint("ScanViewController deinit")

    }
}
