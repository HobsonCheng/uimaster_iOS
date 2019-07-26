//
//  TGPhotoPickerConfig.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/13.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import AVFoundation
import Photos
import UIKit

enum TGPhotoPickerType: Int {
    case normal = 0
    case wechat = 1
    case weibo = 2
}

enum TGCheckboxPosition: Int {
    case topLeft = 0
    case topRight = 1
    case bottomLeft = 2
    case bottomRight = 3
}

enum TGCheckboxType: Int {
    case onlyCheckbox = 0
    case circle = 1
    case square = 2
    case belt = 3
    case diagonalBelt = 4
    case triangle = 5
    case heart = 6
    case star = 7
}

enum TGCaptureDeviceType: String {
    case builtInMicrophone = "AVCaptureDeviceTypeBuiltInMicrophone"
    case builtInWideAngleCamera = "AVCaptureDeviceTypeBuiltInWideAngleCamera"
    case builtInTelephotoCamera = "AVCaptureDeviceTypeBuiltInTelephotoCamera"
    case builtInDualCamera = "AVCaptureDeviceTypeBuiltInDualCamera"
}

enum TGSelectKind: Int {
    case onlyPhoto = 0
    case onlyLive = 1
    case onlyVideo = 2
    case all = 3
}

enum TGIndicatorPosition: Int {
    case top = 0
    case bottom = 1
    case inBottomBar = 2
    case inTopBar = 3
}
// swiftlint:disable type_body_length file_length
class TGPhotoPickerConfig {
    static let ScreenW = UIScreen.main.bounds.width
    static let ScreenH = UIScreen.main.bounds.height
    static let factor: CGFloat = 0.111_111
    static let shared = TGPhotoPickerConfig()
    private init() {
        //如果相加的宽大于屏宽 那么需要减少每个cell的宽(iPhone 5)
        let maxCellW = (TGPhotoPickerConfig.ScreenW - (mainColCount + (leftAndRigthNoPadding ? -1 : 1)) * padding) / mainColCount
        mainCellWH = mainCellWH > maxCellW ? maxCellW : mainCellWH
    }

    /** 与useCustomSmartCollectionsMask结合使用,当useCustomSmartCollectionsMask为true时过滤需要显示smartAlbum的Album类型*/
    var customSmartCollections = [
        PHAssetCollectionSubtype.smartAlbumUserLibrary, //Camera Roll
        PHAssetCollectionSubtype.smartAlbumRecentlyAdded
    ]

    /** 使用自定义的PHAssetCollectionSubtype集合来过滤显示自己想要的相册夹,如想显示慢动作和自拍,那么上面的useCustomSmartCollectionsMask数组中设置为（或添加）[PHAssetCollectionSubtype.smartAlbumSlomoVideos,PHAssetCollectionSubtype.smartAlbumSelfPortraits]*/
    var useCustomSmartCollectionsMask: Bool = true

    /** 是否使用中文名称显示smartAlbum的Album名*/
    var useChineseAlbumName: Bool = false

    /** 空内容的相册夹是否显示 */
    var isShowEmptyAlbum: Bool = false

    /** 升序排列照片*/
    var ascending: Bool = false

    /** 预置的成组配置, 微博 微信*/
    var type: TGPhotoPickerType = .normal {
        didSet {
            switch type {
            case .normal: break

            case .wechat:
                let alpha = self.barBGColor.getAlpha()
                self.barBGColor = self.barBGColor.withAlphaComponent(alpha != 1 ? alpha : 0.9)
                self.checkboxType = .circle
                self.autoSelectWH = false
                self.mainColCount = 4
                self.isShowNumber = true
                self.immediateTapSelect = false
                self.removeType = .circle
            case .weibo:
                self.immediateTapSelect = true
                self.tinColor = .orange
                self.checkboxType = .circle
                self.autoSelectWH = true
                self.mainColCount = 3
                self.isShowNumber = false
                self.useSelectMask = true
                self.removeType = .square
                self.checkboxCorner = 5
            }
        }
    }

    /** 在选择类型为方 带时用到的Corner*/
    var checkboxCorner: CGFloat = 0 {
        didSet {
            checkboxCorner = checkboxCorner > checkboxCellWH ? checkboxCellWH :(checkboxCorner < 0 ? 0 :checkboxCorner)
            cacheNumberImage()
        }
    }

    /** 选择框显示的位置*/
    var checkboxPosition: TGCheckboxPosition = .topRight {
        didSet {
            cacheNumberImage()
        }
    }

    /** 移除按钮显示的位置*/
    var removePosition: TGCheckboxPosition = .topRight

    /** 移除类型,同选择类型*/
    var removeType: TGCheckboxType = .diagonalBelt {
        didSet {
            switch removeType {
            case .heart, .star:
                removeType = .circle
            default: break
            }
        }
    }

    /** Alert样式*/
    var useCustomActionSheet: Bool = true

    /** 是否显示选择顺序*/
    var isShowNumber: Bool = true {
        didSet {
            cacheNumberImage()
        }
    }

    /** 纯数字模式下显示选择顺序时的数字阴影宽,不需要阴影设置为0*/
    var shadowW: CGFloat = 1.0 {
        didSet {
            shadowW = shadowW > 4 ? 4 :(shadowW < 0 ? 0 : shadowW)
            cacheNumberImage()
        }
    }

    /** 纯数字模式下显示选择顺序时的数字阴影高,不需要阴影设置为0*/
    var shadowH: CGFloat = 1.0 {
        didSet {
            shadowH = shadowH > 4 ? 4 :(shadowH < 0 ? 0 : shadowH)
            cacheNumberImage()
        }
    }

    /** 选择框类型（样式） 8种 */
    var checkboxType: TGCheckboxType = .diagonalBelt {
        didSet {
            switch checkboxType {
            case .diagonalBelt, .triangle:
                selectShape[7] = 4
            default:
                selectShape[7] = 3
            }

            cacheNumberImage()
        }
    }

    /** 显示在工具栏上的选择框的大小*/
    var checkboxBarWH: CGFloat = 30 {
        didSet {
            checkboxBarWH = checkboxBarWH > (toolBarH - 10) ? (toolBarH - 10) :(checkboxBarWH < (toolBarH - 20) ? (toolBarH - 20) :checkboxBarWH)
        }
    }

    /** 显示在照片Cell上的选择框的大小*/
    var checkboxCellWH: CGFloat = 20 {
        didSet {
            checkboxCellWH = checkboxCellWH > 25 ? 25 :(checkboxCellWH < 20 ? 20 : checkboxCellWH)
            cacheNumberImage()
        }
    }

    /** 选择框起始透明度*/
    var checkboxBeginngAlpha: CGFloat = 1 {
        didSet {
            checkboxBeginngAlpha = checkboxBeginngAlpha > 1 ? 1 :(checkboxBeginngAlpha < 0.2 ? 0.2 :checkboxBeginngAlpha)
        }
    }

    /** 选择框的结束透明度, 两者用于选择框渐变效果*/
    var checkboxEndingAlpha: CGFloat = 1 {
        didSet {
            checkboxEndingAlpha = checkboxEndingAlpha > 1 ? 1 :(checkboxEndingAlpha < 0.2 ? 0.2 :checkboxEndingAlpha)
        }
    }

    /** 选择框的画线宽度, 工具栏上返回、删除按钮的画线宽度*/
    var checkboxLineW: CGFloat = 1.5 {
        didSet {
            checkboxLineW = checkboxLineW > 2 ? 2 : (checkboxLineW < 1 ? 1 : checkboxLineW)
            cacheNumberImage()
        }
    }

    /** 选择框的Padding*/
    var checkboxPadding: CGFloat = 1 {
        didSet {
            checkboxPadding = checkboxPadding > 6 ? 6 : (checkboxPadding < 0 ? 0 : checkboxPadding)
            cacheNumberImage()
        }
    }

    /** 选择时是否动画效果*/
    var checkboxAnimate: Bool = true

    /** 选择时或选择到最大照片数量时，当前或其他Cell的遮罩的透明度*/
    var maskAlpha: CGFloat = 0.6 {
        didSet {
            maskAlpha = maskAlpha > 0.8 ? 0.8 : (maskAlpha < 0.3 ? 0.3 :maskAlpha)
        }
    }

    /** 使用选择遮罩: false,当选择照片数量达到最大值时,其余照片显示遮罩; true,其余照片不显示遮罩,而是已经选择的照片显示遮罩 */
    var useSelectMask: Bool = false

    /** 工具条的高度*/
    var toolBarH: CGFloat = 44.0 {
        didSet {
            toolBarH = toolBarH < 36 ? 36 : (toolBarH > 44 ? 44 : toolBarH)
        }
    }

    /** 预览UICollectionViewController的高度*/
    var previewCVH: CGFloat = 100 {
        didSet {
            previewCVH = previewCVH < 80 ? 80 : (previewCVH > 160 ? 160 : previewCVH)
        }
    }

    /** 显示预览UICollectionViewController*/
    var isShowPreviewCV: Bool = true

    /** 相册类型列表Cell的高度*/
    var albumCellH: CGFloat = 60.0 {
        didSet {
            albumCellH = albumCellH < 50 ? 50 : (albumCellH > 90 ? 90 : albumCellH)
        }
    }

    /** 照片Cell的高宽,即选择时的呈现的宽高*/
    var selectWH: CGFloat = 80 {
        didSet {
            let maxCellW = (TGPhotoPickerConfig.ScreenW - (colCount + (leftAndRigthNoPadding ? -1 : 1)) * padding) / colCount
            selectWH = selectWH > maxCellW ? maxCellW :(selectWH < 60 ? 60 :selectWH)
        }
    }

    /** 控件本身的Cell的宽高,即选择后的呈现的宽高*/
    var mainCellWH: CGFloat = 80 {
        didSet {
            let maxCellW = (TGPhotoPickerConfig.ScreenW - (mainColCount + (leftAndRigthNoPadding ? -1 : 1)) * padding) / mainColCount
            mainCellWH = mainCellWH > maxCellW ? maxCellW :(mainCellWH < 60 ? 60 :mainCellWH)
        }
    }

    /** 自动宽高,用于控件本身Cell的宽高自动计算*/
    var autoSelectWH: Bool = false

    /** true,在选择照片界面,点击照片（非checkbox区域）时,不跳转到大图预览界面,而是直接选择或取消选择当前照片; false, 点击照片checkbox区域选择或取消选择当前照片,点击非checkbox区域跳转到大图预览界面*/
    var immediateTapSelect: Bool = false

    /** 控件或Cell之间布局时的padding*/
    var padding: CGFloat = 1 {
        didSet {
            padding = padding > 10 ? 10 :(padding < 1 ? 1 :padding)
        }
    }

    /** 动画时长*/
    var animateDuration: TimeInterval = 0.5 {
        didSet {
            animateDuration = animateDuration > 2 ? 2 :(animateDuration < 0.1 ? 0.1 :animateDuration)
        }
    }

    /** 左右没有空白,即选择时呈现的UICollectionView没有contentInset中的左右Inset*/
    var leftAndRigthNoPadding: Bool = true

    /** 选择时呈现的UICollectionView的每行列数*/
    var colCount: CGFloat = 5 {
        didSet {
            colCount = colCount < 3 ? 3 : (colCount > 4 ? 4 : colCount)
        }
    }

    /** 选择后控件本身呈现的UICollectionView的每行列数*/
    var mainColCount: CGFloat = 4 {
        didSet {
            mainColCount = mainColCount > 5 ? 5 : (mainColCount < 2 ? 2 : mainColCount)
        }
    }

    /** 完成按钮标题*/
    var doneTitle = "完成"

    /** 完成按钮的宽*/
    var doneButtonW: CGFloat = 70

    /** 完成按钮的高*/
    var doneButtonH: CGFloat = 30.8 {
        didSet {
            doneButtonH = (doneButtonH > toolBarH * 0.96) ? toolBarH * 0.96 : (doneButtonH < toolBarH * 0.5 ? toolBarH * 0.5 : doneButtonH)
        }
    }

    /** 导航工具栏返回按钮图标显示圆边 及 星（star）样式显示圆边*/
    var isShowBorder: Bool = false

    /** 分多次选择照片时,剩余照片达到上限时的提示文字*/
    var leftTitle = "剩余"

    /** 相册类型界面的标题*/
    var albumTitle = "照片"

    /** 确定按钮的标题*/
    var confirmTitle  = "确定"

    /** 相机权限*/
    var cameraUsage = "相机权限未开启"
    var cameraUsageTip = "请您到 设置->隐私->相机 开启访问权限"

    /** 拍照后是否保存照片到相册*/
    var saveImageToPhotoAlbum: Bool = false

    var saveImageSuccessTip = "保存图片成功"
    var saveImageFailTip = "保存图片失败"
    var saveImageTip = "保存图片结果提示"

    /** 使用iOS8相机: false 根据iOS版本判断使用iOS10或iOS8相机; true 指定使用iOS8相机*/
    var useiOS8Camera: Bool = false

    /** 相册权限*/
    var photoLibraryUsage = "照片权限未开启"
    var photoLibraryUsageTip = "请您到 设置->隐私->照片 开启访问权限"

    /** 选择数量达到上限时的提示文字, #为占位符*/
    var errorImageMaxSelect = "图片选择最多不能超过#张"

    /** 拍摄标题*/
    var cameraTitle = "拍摄"

    /** 选择标题*/
    var selectTitle = "从手机相册选择"

    /** 取消标题*/
    var cancelTitle = "取消"

    /** 选择时显示的数字的字体大小等*/
    var fontSize: CGFloat = 15.0

    /** 预览照片的最大宽度*/
    var previewImageFetchMaxW: CGFloat = 600

    /** 工具栏的背景色,有透明部分则全屏穿透效果*/
    var barBGColor = UIColor(red: 40 / 255, green: 40 / 255, blue: 40 / 255, alpha: 0.9)

    /** 选择框 、按钮的颜色*/
    var tinColor = UIColor(red: 7 / 255, green: 179 / 255, blue: 20 / 255, alpha: 1) {
        didSet {
            cacheNumberImage()
        }
    }

    /** 删除按钮的颜色*/
    var removeHighlightedColor: UIColor = .red

    /** 删除按钮是否隐藏*/
    var isRemoveButtonHidden: Bool = false

    /** 按钮无效时的文字颜色*/
    var disabledColor: UIColor = .gray

    /** 最大照片选择数量上限*/
    var maxImageCount: Int = 9 {
        didSet {
            maxImageCount = maxImageCount < 1 ? 1 : (maxImageCount > 99 ? 99 : maxImageCount)
            cacheNumberImage()
        }
    }

    /** 压缩比,0(most)..1(least) 越小图片就越小*/
    var compressionQuality: CGFloat = 0.5 {
        didSet {
            compressionQuality = compressionQuality < 0.1 ? 0.1 : compressionQuality
        }
    }

    /** 从云端获取照片的缩放比*/
    var cloudImageScale: CGFloat = 0.5 {
        didSet {
            cloudImageScale = cloudImageScale < 0.1 ? 0.1 : cloudImageScale
        }
    }

    /** alertView Tag 用于代理*/
    var alertViewTag: Int = 9_999

    /** 缓存的选择顺序图像,自动生成*/
    var cacheNumerImageArr = [UIImage]()
    var cacheNumerImageForBarArr = [UIImage]()

    /** 相机在选择照片时显示*/
    var showCarmeraInSelectPhoto: Bool = false

    /** 选择类型，照片、Live、视频、全部*/
    var selectKind: TGSelectKind = .all {
        didSet {
            if selectKind == .onlyLive {
                useCustomSmartCollectionsMask = true
                isShowEmptyAlbum = false
                if #available(iOS 10.3, *) {
                    if !customSmartCollections.contains(.smartAlbumLivePhotos) {
                        customSmartCollections.append(.smartAlbumLivePhotos)
                    }
                }
            } else if selectKind == .onlyVideo {
                useCustomSmartCollectionsMask = true
                isShowEmptyAlbum = false
                if !customSmartCollections.contains(.smartAlbumVideos) {
                    customSmartCollections.append(.smartAlbumVideos)
                }
            }
        }
    }

    /** 显示指示器（0/9）*/
    var isShowIndicator: Bool = false

    /** 指示器背景色*/
    var indicatorColor: UIColor = .clear//.lightGray

    /** 指示器在预览界面的显示位置*/
    var indicatorPosition: TGIndicatorPosition = .bottom//.top//.inBottomBar

    /** 显示预览按钮*/
    var isShowPreviewButton: Bool = false

    /** 预览标题*/
    var previewBottonTitle: String = "预览"

    /** 显示编辑按钮*/
    var isShowEditButton: Bool = false

    /** 编辑标题*/
    var editButtonTitle: String = "编辑"

    /** 只能选择图像和视频一种，不能同时选择两种类型*/
    var onlySelectPhotoOrVideo: Bool = false

    /** 裁剪宽高比*/
    var cropScale: CGFloat = 0

    /** 显示原图按钮，显示合计选择的大小*/
    var isShowOriginal: Bool = false

    /** 原图按钮标题*/
    var originalTitle: String = "原图"

    /** 显示重置按钮*/
    var isShowReselect: Bool = false

    /** 重置按钮标题*/
    var reselectTitle: String = "重置"

    /** 拍照保存成功提示*/
    var showCameraSaveSuccess: Bool = true

    /** 以下为照相配置 8个 */
    /** 按钮分布时边界*/
    var buttonEdge = UIEdgeInsets(top: 40, left: 20, bottom: 60, right: 50)

    /** 拍摄按钮的大小*/
    var takeWH: CGFloat = 60 {
        didSet {
            takeWH = takeWH < 50 ? 50 : (takeWH > 80 ? 80 : takeWH)
        }
    }

    /** 对焦视图大小*/
    var focusViewWH: CGFloat = 80 {
        didSet {
            focusViewWH = focusViewWH < 50 ? 50 : (focusViewWH > 80 ? 80 : focusViewWH)
        }
    }

    /** 拍摄预览时的背景色*/
    var previewBGColor = UIColor(white: 1, alpha: 0.7)

    /** 前置后置摄像头切换时的动画类型,可以设置下面值
     kCATransitionFade
     kCATransitionMoveIn
     kCATransitionPush
     kCATransitionReveal
     "pageCurl"
     "pageUnCurl"
     "rippleEffect"
     "suckEffect"
     "cube"
     "oglFlip"
     */
    var transitionType: String = "oglFlip"

    /** 图像质量 */
    var sessionPreset: String = AVCaptureSession.Preset.hd1280x720.rawValue

    /** 拍摄视图的伸缩模式*/
    var videoGravity: String = AVLayerVideoGravity.resizeAspectFill.rawValue

    /** 广角*/
    var captureDeviceType: TGCaptureDeviceType = .builtInWideAngleCamera

    /** 预览Padding*/
    var previewPadding: CGFloat = 15

    /** 选择和移除路径 */
    private var selectShape: Array<CGFloat> = [3, 5, 4, 6, 4, 6, 6, 3]
    private var removeShape: Array<CGFloat> = [3.5, 3.5, 5.5, 5.5, 5.5, 3.5, 3.5, 5.5]

    /** 下面为链式配置 */
    @discardableResult
    func tg_autoSelectWH(_ auto: Bool) -> TGPhotoPickerConfig {
        self.autoSelectWH = auto
        return self
    }

    @discardableResult
    func tg_cameraTitle(_ str: String) -> TGPhotoPickerConfig {
        self.cameraTitle = str
        return self
    }

    @discardableResult
    func tg_selectWH(_ selectWH: CGFloat) -> TGPhotoPickerConfig {
        self.selectWH = selectWH
        return self
    }

    @discardableResult
    func tg_tinColor(_ color: UIColor) -> TGPhotoPickerConfig {
        self.tinColor = color
        return self
    }

    @discardableResult
    func tg_customSmartCollections(_ custom: [PHAssetCollectionSubtype]) -> TGPhotoPickerConfig {
        self.customSmartCollections = custom
        return self
    }

    @discardableResult
    func tg_animateDuration(_ duration: TimeInterval) -> TGPhotoPickerConfig {
        self.animateDuration = duration
        return self
    }

    @discardableResult
    func tg_useCustomSmartCollectionsMask(_ use: Bool) -> TGPhotoPickerConfig {
        self.useCustomSmartCollectionsMask = use
        return self
    }

    @discardableResult
    func tg_useChineseAlbumName(_ use: Bool) -> TGPhotoPickerConfig {
        self.useChineseAlbumName = use
        return self
    }

    @discardableResult
    func tg_isShowEmptyAlbum(_ show: Bool) -> TGPhotoPickerConfig {
        self.isShowEmptyAlbum = show
        return self
    }

    @discardableResult
    func tg_ascending(_ ascending: Bool) -> TGPhotoPickerConfig {
        self.ascending = ascending
        return self
    }

    @discardableResult
    func tg_previewCVH(_ param: CGFloat) -> TGPhotoPickerConfig {
        self.previewCVH = param
        return self
    }

    @discardableResult
    func tg_isShowPreviewCV(_ show: Bool) -> TGPhotoPickerConfig {
        self.isShowPreviewCV = show
        return self
    }

    @discardableResult
    func tg_type(_ type: TGPhotoPickerType) -> TGPhotoPickerConfig {
        self.type = type
        return self
    }

    @discardableResult
    func tg_checkboxCorner(_ corner: CGFloat) -> TGPhotoPickerConfig {
        self.checkboxCorner = corner
        return self
    }

    @discardableResult
    func tg_focusViewWH(_ wh: CGFloat) -> TGPhotoPickerConfig {
        self.focusViewWH = wh
        return self
    }

    @discardableResult
    func tg_checkboxPosition(_ position: TGCheckboxPosition) -> TGPhotoPickerConfig {
        self.checkboxPosition = position
        return self
    }

    @discardableResult
    func tg_removePosition(_ position: TGCheckboxPosition) -> TGPhotoPickerConfig {
        self.removePosition = position
        return self
    }

    @discardableResult
    func tg_removeType(_ type: TGCheckboxType) -> TGPhotoPickerConfig {
        self.removeType = type
        return self
    }

    @discardableResult
    func tg_isShowNumber(_ show: Bool) -> TGPhotoPickerConfig {
        self.isShowNumber = show
        return self
    }

    @discardableResult
    func tg_checkboxType(_ type: TGCheckboxType) -> TGPhotoPickerConfig {
        self.checkboxType = type
        return self
    }

    @discardableResult
    func tg_checkboxBarWH(_ wh: CGFloat) -> TGPhotoPickerConfig {
        self.checkboxBarWH = wh
        return self
    }

    @discardableResult
    func tg_checkboxCellWH(_ wh: CGFloat) -> TGPhotoPickerConfig {
        self.checkboxCellWH = wh
        return self
    }

    @discardableResult
    func tg_checkboxBeginngAlpha(_ alpha: CGFloat) -> TGPhotoPickerConfig {
        self.checkboxBeginngAlpha = alpha
        return self
    }

    @discardableResult
    func tg_checkboxEndingAlpha(_ alpha: CGFloat) -> TGPhotoPickerConfig {
        self.checkboxEndingAlpha = alpha
        return self
    }

    @discardableResult
    func tg_checkboxLineW(_ param: CGFloat) -> TGPhotoPickerConfig {
        self.checkboxLineW = param
        return self
    }

    @discardableResult
    func tg_checkboxPadding(_ padding: CGFloat) -> TGPhotoPickerConfig {
        self.checkboxPadding = padding
        return self
    }

    @discardableResult
    func tg_checkboxAnimate(_ animate: Bool) -> TGPhotoPickerConfig {
        self.checkboxAnimate = animate
        return self
    }

    @discardableResult
    func tg_maskAlpha(_ alpha: CGFloat) -> TGPhotoPickerConfig {
        self.maskAlpha = alpha
        return self
    }

    @discardableResult
    func tg_useSelectMask(_ mask: Bool) -> TGPhotoPickerConfig {
        self.useSelectMask = mask
        return self
    }

    @discardableResult
    func tg_toolBarH(_ param: CGFloat) -> TGPhotoPickerConfig {
        self.toolBarH = param
        return self
    }

    @discardableResult
    func tg_albumCellH(_ param: CGFloat) -> TGPhotoPickerConfig {
        self.albumCellH = param
        return self
    }

    @discardableResult
    func tg_mainCellWH(_ param: CGFloat) -> TGPhotoPickerConfig {
        self.mainCellWH = param
        return self
    }

    @discardableResult
    func tg_immediateTapSelect(_ immediate: Bool) -> TGPhotoPickerConfig {
        self.immediateTapSelect = immediate
        return self
    }

    @discardableResult
    func tg_padding(_ padding: CGFloat) -> TGPhotoPickerConfig {
        self.padding = padding
        return self
    }

    @discardableResult
    func tg_leftAndRigthNoPadding(_ noPadding: Bool) -> TGPhotoPickerConfig {
        self.leftAndRigthNoPadding = noPadding
        return self
    }

    @discardableResult
    func tg_colCount(_ count: CGFloat) -> TGPhotoPickerConfig {
        self.colCount = count
        return self
    }

    @discardableResult
    func tg_mainColCount(_ count: CGFloat) -> TGPhotoPickerConfig {
        self.mainColCount = count
        return self
    }
    @discardableResult
    func tg_doneTitle(_ str: String) -> TGPhotoPickerConfig {
        self.doneTitle = str
        return self
    }

    @discardableResult
    func tg_doneButtonW(_ param: CGFloat) -> TGPhotoPickerConfig {
        self.doneButtonW = param
        return self
    }

    @discardableResult
    func tg_doneButtonH(_ param: CGFloat) -> TGPhotoPickerConfig {
        self.doneButtonH = param
        return self
    }

    @discardableResult
    func tg_isShowBorder(_ show: Bool) -> TGPhotoPickerConfig {
        self.isShowBorder = show
        return self
    }

    @discardableResult
    func tg_useCustomActionSheet(_ custom: Bool) -> TGPhotoPickerConfig {
        self.useCustomActionSheet = custom
        return self
    }

    @discardableResult
    func tg_cameraUsage(_ str: String) -> TGPhotoPickerConfig {
        self.cameraUsage = str
        return self
    }

    @discardableResult
    func tg_cameraUsageTip(_ str: String) -> TGPhotoPickerConfig {
        self.cameraUsageTip = str
        return self
    }

    @discardableResult
    func tg_saveImageToPhotoAlbum(_ save: Bool) -> TGPhotoPickerConfig {
        self.saveImageToPhotoAlbum = save
        return self
    }

    @discardableResult
    func tg_photoLibraryUsage(_ str: String) -> TGPhotoPickerConfig {
        self.photoLibraryUsage = str
        return self
    }

    @discardableResult
    func tg_saveImageSuccessTip(_ str: String) -> TGPhotoPickerConfig {
        self.saveImageSuccessTip = str
        return self
    }

    @discardableResult
    func tg_saveImageFailTip(_ str: String) -> TGPhotoPickerConfig {
        self.saveImageFailTip = str
        return self
    }

    @discardableResult
    func tg_saveImageTip(_ str: String) -> TGPhotoPickerConfig {
        self.saveImageTip = str
        return self
    }

    @discardableResult
    func tg_photoLibraryUsageTip(_ str: String) -> TGPhotoPickerConfig {
        self.photoLibraryUsageTip = str
        return self
    }

    @discardableResult
    func tg_leftTitle(_ str: String) -> TGPhotoPickerConfig {
        self.leftTitle = str
        return self
    }

    @discardableResult
    func tg_albumTitle(_ str: String) -> TGPhotoPickerConfig {
        self.albumTitle = str
        return self
    }

    @discardableResult
    func tg_confirmTitle(_ str: String) -> TGPhotoPickerConfig {
        self.confirmTitle = str
        return self
    }

    @discardableResult
    func tg_errorImageMaxSelect(_ str: String) -> TGPhotoPickerConfig {
        self.errorImageMaxSelect = str
        return self
    }

    @discardableResult
    func tg_selectTitle(_ str: String) -> TGPhotoPickerConfig {
        self.selectTitle = str
        return self
    }

    @discardableResult
    func tg_cancelTitle(_ str: String) -> TGPhotoPickerConfig {
        self.cancelTitle = str
        return self
    }

    @discardableResult
    func tg_fontSize(_ size: CGFloat) -> TGPhotoPickerConfig {
        self.fontSize = size
        return self
    }

    @discardableResult
    func tg_previewImageFetchMaxW(_ param: CGFloat) -> TGPhotoPickerConfig {
        self.previewImageFetchMaxW = param
        return self
    }

    @discardableResult
    func tg_barBGColor(_ color: UIColor) -> TGPhotoPickerConfig {
        self.barBGColor = color
        return self
    }

    @discardableResult
    func tg_removeHighlightedColor(_ color: UIColor) -> TGPhotoPickerConfig {
        self.removeHighlightedColor = color
        return self
    }

    @discardableResult
    func tg_isRemoveButtonHidden(_ hidden: Bool) -> TGPhotoPickerConfig {
        self.isRemoveButtonHidden = hidden
        return self
    }

    @discardableResult
    func tg_useiOS8Camera(_ use: Bool) -> TGPhotoPickerConfig {
        self.useiOS8Camera = use
        return self
    }

    @discardableResult
    func tg_disabledColor(_ color: UIColor) -> TGPhotoPickerConfig {
        self.disabledColor = color
        return self
    }

    @discardableResult
    func tg_indicatorColor(_ color: UIColor) -> TGPhotoPickerConfig {
        self.indicatorColor = color
        return self
    }

    @discardableResult
    func tg_maxImageCount(_ max: Int) -> TGPhotoPickerConfig {
        self.maxImageCount = max
        return self
    }

    @discardableResult
    func tg_alertViewTag(_ tag: Int) -> TGPhotoPickerConfig {
        self.alertViewTag = tag
        return self
    }

    @discardableResult
    func tg_compressionQuality(_ quality: CGFloat) -> TGPhotoPickerConfig {
        self.compressionQuality = quality
        return self
    }

    @discardableResult
    func tg_cloudImageScale(_ scale: CGFloat) -> TGPhotoPickerConfig {
        self.cloudImageScale = scale
        return self
    }

    @discardableResult
    func tg_shadowW(_ param: CGFloat) -> TGPhotoPickerConfig {
        self.shadowW = param
        return self
    }

    @discardableResult
    func tg_shadowH(_ param: CGFloat) -> TGPhotoPickerConfig {
        self.shadowH = param
        return self
    }

    @discardableResult
    func tg_buttonEdge(_ edge: UIEdgeInsets) -> TGPhotoPickerConfig {
        self.buttonEdge = edge
        return self
    }

    @discardableResult
    func tg_takeWH(_ wh: CGFloat) -> TGPhotoPickerConfig {
        self.takeWH = wh
        return self
    }

    @discardableResult
    func tg_previewBGColor(_ color: UIColor) -> TGPhotoPickerConfig {
        self.previewBGColor = color
        return self
    }

    @discardableResult
    func tg_transitionType(_ str: String) -> TGPhotoPickerConfig {
        self.transitionType = str
        return self
    }

    @discardableResult
    func tg_sessionPreset(_ str: String) -> TGPhotoPickerConfig {
        self.sessionPreset = str
        return self
    }

    @discardableResult
    func tg_videoGravity(_ str: String) -> TGPhotoPickerConfig {
        self.videoGravity = str
        return self
    }

    @discardableResult
    @available(iOS 10.0, *)
    func tg_captureDeviceType(_ type: TGCaptureDeviceType) -> TGPhotoPickerConfig {
        self.captureDeviceType = type
        return self
    }

    @discardableResult
    func tg_previewPadding(_ padding: CGFloat) -> TGPhotoPickerConfig {
        self.previewPadding = padding
        return self
    }

    @discardableResult
    func tg_showCarmeraInSelectPhoto(_ use: Bool) -> TGPhotoPickerConfig {
        self.useiOS8Camera = use
        return self
    }

    @discardableResult
    func tg_selectKind(_ kind: TGSelectKind) -> TGPhotoPickerConfig {
        self.selectKind = kind
        return self
    }

    @discardableResult
    func tg_isShowIndicator(_ show: Bool) -> TGPhotoPickerConfig {
        self.isShowIndicator = show
        return self
    }

    @discardableResult
    func tg_isShowPreviewButton(_ show: Bool) -> TGPhotoPickerConfig {
        self.isShowPreviewButton = show
        return self
    }

    @discardableResult
    func tg_previewBottonTitle(_ str: String) -> TGPhotoPickerConfig {
        self.previewBottonTitle = str
        return self
    }

    @discardableResult
    func tg_isShowEditButton(_ show: Bool) -> TGPhotoPickerConfig {
        self.isShowEditButton = show
        return self
    }

    @discardableResult
    func tg_editButtonTitle(_ str: String) -> TGPhotoPickerConfig {
        self.editButtonTitle = str
        return self
    }

    @discardableResult
    func tg_onlySelectPhotoOrVideo(_ only: Bool) -> TGPhotoPickerConfig {
        self.onlySelectPhotoOrVideo = only
        return self
    }

    @discardableResult
    func tg_cropScale(_ scale: CGFloat) -> TGPhotoPickerConfig {
        self.cropScale = scale
        return self
    }

    @discardableResult
    func tg_isShowOriginal(_ show: Bool) -> TGPhotoPickerConfig {
        self.isShowOriginal = show
        return self
    }

    @discardableResult
    func tg_originalTitle(_ str: String) -> TGPhotoPickerConfig {
        self.originalTitle = str
        return self
    }

    @discardableResult
    func tg_isShowReselect(_ show: Bool) -> TGPhotoPickerConfig {
        self.isShowReselect = show
        return self
    }

    @discardableResult
    func tg_reselectTitle(_ str: String) -> TGPhotoPickerConfig {
        self.reselectTitle = str
        return self
    }

    @discardableResult
    func tg_showCameraSaveSuccess(_ show: Bool) -> TGPhotoPickerConfig {
        self.showCameraSaveSuccess = show
        return self
    }

    class func getImage(_ name: String) -> UIImage {
        let currentBundle = Bundle(path: Bundle(for: TGPhotoPicker.self).path(forResource: "TGPhotoPicker", ofType: "bundle")!)
        return UIImage(contentsOfFile: (currentBundle?.path(forResource: name, ofType: "png"))!)!
    }

    class func getImageNo2x3xSuffix(_ name: String) -> UIImage {
        let currentBundle = Bundle(path: Bundle(for: TGPhotoPicker.self).path(forResource: "TGPhotoPicker", ofType: "bundle")!)
        return UIImage(contentsOfFile: (((currentBundle?.resourcePath)! as NSString).appendingPathComponent(name+".png") ))!
    }

    func getDigitImage(_ num: UInt, _ type: TGCheckboxType = TGPhotoPickerConfig.shared.checkboxType, _ isCellSize: Bool = true, _ fontSize: CGFloat = TGPhotoPickerConfig.shared.fontSize - 1) -> UIImage? {
        var with = (isCellSize ? self.checkboxCellWH : self.checkboxBarWH) * UIScreen.main.scale
        var height = (isCellSize ? self.checkboxCellWH : self.checkboxBarWH) * UIScreen.main.scale
        let lineWidth = self.checkboxLineW
        let padding = self.checkboxPadding * UIScreen.main.scale
        let checkBoxPosion = self.checkboxPosition

        let str: NSString = String(num) as NSString

        var reduceFontSize = fontSize - 3 * padding / 10
        reduceFontSize -= num > 9 ? 1.5 : 0
        reduceFontSize -= num > 19 ? 1.5 : 0
        reduceFontSize -= type == .triangle ? 2 : 0
        reduceFontSize -= type == .diagonalBelt ? 2 : 0
        reduceFontSize *= UIScreen.main.scale
        let font: UIFont = lineWidth >= 2 ? UIFont.boldSystemFont(ofSize: reduceFontSize) : UIFont.systemFont(ofSize: reduceFontSize)

        var attrs = [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: UIColor.white]
        //NSShadowAttributeName NSVerticalGlyphFormAttributeName，NSObliquenessAttributeName，NSExpansionAttributeName
        if type == .onlyCheckbox {
            let shadow = NSShadow()
            shadow.shadowBlurRadius = 4
            shadow.shadowColor = UIColor.gray
            shadow.shadowOffset = CGSize(width: shadowW, height: shadowH)
            if shadowW > 0 || shadowH > 0 {
                attrs = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: fontSize), NSAttributedStringKey.foregroundColor: tinColor, NSAttributedStringKey.shadow: shadow, NSAttributedStringKey.verticalGlyphForm: 0 as NSNumber]
            } else {
                attrs = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: fontSize), NSAttributedStringKey.foregroundColor: tinColor]
            }
        }

        let viewSize = CGSize(width: TGPhotoPickerConfig.ScreenW, height: CGFloat(MAXFLOAT))
        let size = str.boundingRect(with: viewSize, options: [.usesLineFragmentOrigin], attributes: attrs, context: nil)

        let x = padding / 2 + (with - padding - size.width) / 2
        let y = padding / 2 + (height - padding - size.height) / 2

        var addX: CGFloat = 0
        var addY: CGFloat = 0

        switch type {
        case .onlyCheckbox:
            return UIImage.size(width: with, height: height)
                .color(.clear)
                .image
                .with({ _ in
                    str.draw(in: CGRect(x: x, y: y, width: with, height: height), withAttributes: attrs)
                })
        case .circle, .star, .heart:
            return UIImage.size(width: with, height: height)
                .corner(radius: with * 0.5)
                .color(self.tinColor)
                .border(color: .clear)
                .border(width: padding)
                .image
                .with({ _ in
                    str.draw(in: CGRect(x: x, y: y, width: with, height: height), withAttributes: attrs)
                })
        case .square:
            switch checkBoxPosion {
            case .topLeft:
                addX = -self.checkboxCorner * TGPhotoPickerConfig.factor
                addY = -self.checkboxCorner * TGPhotoPickerConfig.factor
            case .topRight:
                addX = self.checkboxCorner * TGPhotoPickerConfig.factor
                addY = -self.checkboxCorner * TGPhotoPickerConfig.factor
            case .bottomLeft:
                addX = -self.checkboxCorner * TGPhotoPickerConfig.factor
                addY = self.checkboxCorner * TGPhotoPickerConfig.factor
            case .bottomRight:
                addX = self.checkboxCorner * TGPhotoPickerConfig.factor
                addY = self.checkboxCorner * TGPhotoPickerConfig.factor
            }
            return UIImage.size(width: with, height: height)
                .corner(topLeft: checkBoxPosion == .bottomRight ? self.checkboxCorner : 0,
                        topRight: checkBoxPosion == .bottomLeft ? self.checkboxCorner : 0,
                        bottomLeft: checkBoxPosion == .topRight ? self.checkboxCorner : 0,
                        bottomRight: checkBoxPosion == .topLeft ? self.checkboxCorner : 0)
                .color(self.tinColor)
                .image
                .with({ _ in
                    str.draw(in: CGRect(x: x + addX, y: y + addY, width: with, height: height), withAttributes: attrs)
                })
        case .belt:
            addX = (self.checkboxPosition == .topRight || self.checkboxPosition == .bottomRight) ? (with * 2 + padding * 0.5) : (-padding * 0.5)
            addY = -padding * 0.5
            with *= 3
            height -= padding
            var fromPoint: CGPoint?
            var toPoint: CGPoint?
            switch self.checkboxPosition {
            case .topLeft:
                fromPoint = CGPoint(x: 0, y: 0)
                toPoint = CGPoint(x: 1, y: 1)
            case .topRight:
                fromPoint = CGPoint(x: 1, y: 0)
                toPoint = CGPoint(x: 0, y: 1)
            case .bottomLeft:
                fromPoint = CGPoint(x: 0, y: 1)
                toPoint = CGPoint(x: 1, y: 0)
            case .bottomRight:
                fromPoint = CGPoint(x: 1, y: 1)
                toPoint = CGPoint(x: 0, y: 0)
            }
            return UIImage.size(width: with, height: height)
                .corner(topLeft: checkBoxPosion == .bottomRight ? self.checkboxCorner : 0,
                        topRight: checkBoxPosion == .bottomLeft ? self.checkboxCorner : 0,
                        bottomLeft: checkBoxPosion == .topRight ? self.checkboxCorner : 0,
                        bottomRight: checkBoxPosion == .topLeft ? self.checkboxCorner : 0)
                .color(gradient: [self.tinColor.withAlphaComponent(self.checkboxBeginngAlpha), UIColor.white.withAlphaComponent(0.01)], locations: [0, 1], from: fromPoint!, to: toPoint!)
                .image
                .with({ _ in
                    str.draw(in: CGRect(x: x + addX, y: y + addY, width: with, height: height), withAttributes: attrs)
                })
        case .triangle, .diagonalBelt:
            let beltLineW = with * 0.75
            let smallToBigSecondAddY: CGFloat = num > 19 ? 1 : (num > 9 ? 0.75 : 0.25)
            var beltMoveTo: CGPoint?
            var beltLineTo: CGPoint?
            var positionX: CGFloat = 0
            var positionY: CGFloat = 0
            switch self.checkboxPosition {
            case .topLeft:
                addX = -with / 5
                addY = -(with / 5 + smallToBigSecondAddY)
                positionX = -0.000_001
                positionY = 0
                beltMoveTo = CGPoint(x: with * 0.5, y: 0)
                beltLineTo = CGPoint(x: 0, y: height * 0.5)
            case .topRight:
                addX = with / 5
                addY = -(with / 5 + smallToBigSecondAddY)
                positionX = with * 0.5
                positionY = 0
                beltMoveTo = CGPoint(x: with * 0.5, y: 0)
                beltLineTo = CGPoint(x: with, y: height * 0.5)
            case .bottomLeft:
                addX = -with / 5
                addY = with / 5 + smallToBigSecondAddY
                positionX = 0
                positionY = with * 0.5
                beltMoveTo = CGPoint(x: -with * 0.25, y: height * 0.25)
                beltLineTo = CGPoint(x: with * 0.5, y: height)
            case .bottomRight:
                addX = with / 5
                addY = with / 5 + smallToBigSecondAddY
                positionX = with * 0.5
                positionY = with * 0.5
                beltMoveTo = CGPoint(x: with, y: height * 0.5)
                beltLineTo = CGPoint(x: with * 0.5, y: height)
            }

            let image = UIImage.size(width: with, height: height)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.square)
                    self.tinColor.setStroke()
                    context.setLineWidth(beltLineW)
                    context.move(to: beltMoveTo!)
                    context.addLine(to: beltLineTo!)
                    context.strokePath()

                    str.draw(in: CGRect(x: x + addX, y: y + addY, width: with, height: height), withAttributes: attrs)
                })
            return type == .triangle ? image : UIImage.size(width: with * 1.5, height: height * 1.5).color(.clear).image + image.position(CGPoint(x: positionX, y: positionY))
//        default:
//            return nil
        }
    }

    func getCheckboxImage(_ isCellSize: Bool = true,
                          _ isRemove: Bool = false,
                          _ checkboxType: TGCheckboxType = TGPhotoPickerConfig.shared.checkboxType,
                          _ useUserSize: CGFloat = 0
                                 ) -> (select: UIImage, unselect: UIImage, size: CGSize) {
        var width = (useUserSize > 0) ? useUserSize : (isCellSize ? self.checkboxCellWH : self.checkboxBarWH)
        var height = (useUserSize > 0) ? useUserSize : (isCellSize ? self.checkboxCellWH : self.checkboxBarWH)
        let factor = width * TGPhotoPickerConfig.factor
        let lineWidth = self.checkboxLineW
        let padding = self.checkboxPadding
        let position = self.checkboxPosition

        var shape = isRemove ? removeShape : selectShape
        shape[7] = isRemove ? shape[7] : (isCellSize ? shape[7] : 3)

        let tin = isRemove ? self.removeHighlightedColor : self.tinColor

        let type = (useUserSize > 0) ? checkboxType : (isRemove ? self.removeType : checkboxType)

        var imageSelect: UIImage?
        var imageUnselect: UIImage?

        var fromPoint: CGPoint?
        var toPoint: CGPoint?
        switch self.checkboxPosition {
        case .topLeft:
            fromPoint = CGPoint(x: 0, y: 0)
            toPoint = CGPoint(x: 1, y: 1)
        case .topRight:
            fromPoint = CGPoint(x: 1, y: 0)
            toPoint = CGPoint(x: 0, y: 1)
        case .bottomLeft:
            fromPoint = CGPoint(x: 0, y: 1)
            toPoint = CGPoint(x: 1, y: 0)
        case .bottomRight:
            fromPoint = CGPoint(x: 1, y: 1)
            toPoint = CGPoint(x: 0, y: 0)
        }

        var addX: CGFloat = 0
        var addY: CGFloat = 0

        switch  type {
        case .onlyCheckbox:
            imageUnselect = UIImage.size(width: width, height: height)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    UIColor.white.withAlphaComponent(0.7).setStroke()
                    context.setLineWidth(lineWidth)
                    context.move(to: CGPoint(x: factor * shape[0], y: factor * shape[1]))
                    context.addLine(to: CGPoint(x: factor * shape[2], y: factor * shape[3]))
                    context.move(to: CGPoint(x: factor * shape[4], y: factor * shape[5]))
                    context.addLine(to: CGPoint(x: factor * shape[6], y: factor * shape[7]))
                    context.strokePath()
                })

            imageSelect = UIImage.size(width: width, height: height)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    tin.setStroke()
                    context.setLineWidth(lineWidth)
                    context.move(to: CGPoint(x: factor * shape[0], y: factor * shape[1]))
                    context.addLine(to: CGPoint(x: factor * shape[2], y: factor * shape[3]))
                    context.move(to: CGPoint(x: factor * shape[4], y: factor * shape[5]))
                    context.addLine(to: CGPoint(x: factor * shape[6], y: factor * shape[7]))
                    context.strokePath()
                })
        case .circle:
            let spaceW = min(width / 10, lineWidth * 2)
            imageUnselect = (UIImage.size(width: width, height: height)
                .corner(radius: width * 0.5)
                .border(color: .clear)
                .border(width: padding)
                .color(UIColor.white.withAlphaComponent(0.3))
                .image
                +
                UIImage.size(width: width - padding, height: height - padding)
                    .corner(radius: (width - padding) * 0.5)
                    .border(color: UIColor.white.withAlphaComponent(0.7))
                    .border(width: spaceW * 0.5)
                    .color(.clear)
                    .image)
                .with({ context in
                    context.setLineCap(.round)

                    switch self.type {
                    case .weibo:
                        isRemove ? UIColor.white.setStroke() : UIColor.clear.setStroke()
                    default :
                        UIColor.white.setStroke()
                    }

                    context.setLineWidth(lineWidth)
                    context.move(to: CGPoint(x: factor * shape[0], y: factor * shape[1]))
                    context.addLine(to: CGPoint(x: factor * shape[2], y: factor * shape[3]))
                    context.move(to: CGPoint(x: factor * shape[4], y: factor * shape[5]))
                    context.addLine(to: CGPoint(x: factor * shape[6], y: factor * shape[7]))
                    context.strokePath()
                })

            imageSelect = UIImage.size(width: width, height: height)
                .corner(radius: width * 0.5)
                .border(color: .clear)
                .border(width: padding)
                .color(gradient: [tin.withAlphaComponent(isCellSize ? self.checkboxBeginngAlpha : 1), tin.withAlphaComponent(isCellSize ? self.checkboxEndingAlpha : 1)], locations: [0, 1], from: fromPoint!, to: toPoint!)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(lineWidth)
                    context.move(to: CGPoint(x: factor * shape[0], y: factor * shape[1]))
                    context.addLine(to: CGPoint(x: factor * shape[2], y: factor * shape[3]))
                    context.move(to: CGPoint(x: factor * shape[4], y: factor * shape[5]))
                    context.addLine(to: CGPoint(x: factor * shape[6], y: factor * shape[7]))
                    context.strokePath()
                })
        case .square:
            switch self.checkboxPosition {
            case .topLeft:
                addX = -self.checkboxCorner * TGPhotoPickerConfig.factor
                addY = -self.checkboxCorner * TGPhotoPickerConfig.factor
            case .topRight:
                addX = self.checkboxCorner * TGPhotoPickerConfig.factor
                addY = -self.checkboxCorner * TGPhotoPickerConfig.factor
            case .bottomLeft:
                addX = -self.checkboxCorner * TGPhotoPickerConfig.factor
                addY = self.checkboxCorner * TGPhotoPickerConfig.factor
            case .bottomRight:
                addX = self.checkboxCorner * TGPhotoPickerConfig.factor
                addY = self.checkboxCorner * TGPhotoPickerConfig.factor
            }
            imageUnselect = UIImage.size(width: width, height: height)
                .corner(
                    topLeft: position == .bottomRight ? self.checkboxCorner : 0,
                    topRight: position == .bottomLeft ? self.checkboxCorner : 0,
                    bottomLeft: position == .topRight ? self.checkboxCorner : 0,
                    bottomRight: position == .topLeft ? self.checkboxCorner : 0)
                .color(UIColor.white.withAlphaComponent(0.3))
                .image
                .with({ context in
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(lineWidth)
                    context.move(to: CGPoint(x: factor * shape[0] + addX, y: factor * shape[1] + addY))
                    context.addLine(to: CGPoint(x: factor * shape[2] + addX, y: factor * shape[3] + addY))
                    context.move(to: CGPoint(x: factor * shape[4] + addX, y: factor * shape[5] + addY))
                    context.addLine(to: CGPoint(x: factor * shape[6] + addX, y: factor * shape[7] + addY))
                    context.strokePath()
                })

            imageSelect = UIImage.size(width: width, height: height)
                .corner(topLeft: position == .bottomRight ? self.checkboxCorner : 0,
                        topRight: position == .bottomLeft ? self.checkboxCorner : 0,
                        bottomLeft: position == .topRight ? self.checkboxCorner : 0,
                        bottomRight: position == .topLeft ? self.checkboxCorner : 0)
                .color(gradient: [tin.withAlphaComponent(self.checkboxBeginngAlpha), tin.withAlphaComponent(self.checkboxEndingAlpha)], locations: [0, 1], from: fromPoint!, to: toPoint!)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(lineWidth)
                    context.move(to: CGPoint(x: factor * shape[0] + addX, y: factor * shape[1] + addY))
                    context.addLine(to: CGPoint(x: factor * shape[2] + addX, y: factor * shape[3] + addY))
                    context.move(to: CGPoint(x: factor * shape[4] + addX, y: factor * shape[5] + addY))
                    context.addLine(to: CGPoint(x: factor * shape[6] + addX, y: factor * shape[7] + addY))
                    context.strokePath()
                })
        case .belt:
            addX = (self.checkboxPosition == .topRight || self.checkboxPosition == .bottomRight) ? (width * 2 + padding * 0.5) : (-padding * 0.5)
            addY = -padding * 0.5
            width *= 3
            height -= padding
            imageUnselect = UIImage.size(width: width, height: height)
                .corner(topLeft: position == .bottomRight ? self.checkboxCorner : 0,
                        topRight: position == .bottomLeft ? self.checkboxCorner : 0,
                        bottomLeft: position == .topRight ? self.checkboxCorner : 0,
                        bottomRight: position == .topLeft ? self.checkboxCorner : 0)
                .color(gradient: [UIColor.white.withAlphaComponent(0.3), UIColor.white.withAlphaComponent(0.01)], locations: [0, 1], from: fromPoint!, to: toPoint!)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(lineWidth)
                    context.move(to: CGPoint(x: factor * shape[0] + addX, y: factor * shape[1] + addY))
                    context.addLine(to: CGPoint(x: factor * shape[2] + addX, y: factor * shape[3] + addY))
                    context.move(to: CGPoint(x: factor * shape[4] + addX, y: factor * shape[5] + addY))
                    context.addLine(to: CGPoint(x: factor * shape[6] + addX, y: factor * shape[7] + addY))
                    context.strokePath()
                })

            imageSelect = UIImage.size(width: width, height: height)
                .corner(topLeft: position == .bottomRight ? self.checkboxCorner : 0,
                        topRight: position == .bottomLeft ? self.checkboxCorner : 0,
                        bottomLeft: position == .topRight ? self.checkboxCorner : 0,
                        bottomRight: position == .topLeft ? self.checkboxCorner : 0)
                .color(gradient: [tin.withAlphaComponent(self.checkboxBeginngAlpha), UIColor.white.withAlphaComponent(0.01)], locations: [0, 1], from: fromPoint!, to: toPoint!)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(lineWidth)
                    context.move(to: CGPoint(x: factor * shape[0] + addX, y: factor * shape[1] + addY))
                    context.addLine(to: CGPoint(x: factor * shape[2] + addX, y: factor * shape[3] + addY))
                    context.move(to: CGPoint(x: factor * shape[4] + addX, y: factor * shape[5] + addY))
                    context.addLine(to: CGPoint(x: factor * shape[6] + addX, y: factor * shape[7] + addY))
                    context.strokePath()
                })
        case .diagonalBelt:
            let beltLineW = width * 0.5
            width *= 1.5
            height *= 1.5
            var beltMoveTo: CGPoint?
            var beltLineTo: CGPoint?
            switch self.checkboxPosition {
            case .topRight:
                addX = factor * (isRemove ? 5.75 : 5)
                addY = -factor * (isRemove ? 1 : 2)
                beltMoveTo = CGPoint(x: width * 0.5, y: 0)
                beltLineTo = CGPoint(x: width, y: height * 0.5)
            case .bottomLeft:
                addX = -factor * 1.25
                addY = factor * 5.5
                beltMoveTo = CGPoint(x: -width * 0.25, y: height * 0.25)
                beltLineTo = CGPoint(x: width * 0.5, y: height)
            case .topLeft:
                addX = -factor * (isRemove ? 1.25 : 0.5)
                addY = -factor * (isRemove ? 1 : 2)
                beltMoveTo = CGPoint(x: width * 0.5, y: 0)
                beltLineTo = CGPoint(x: 0, y: height * 0.5)
            case .bottomRight:
                addX = factor * (isRemove ? 5.25 : 5.75)
                addY = factor * (isRemove ? 6 : 5)
                beltMoveTo = CGPoint(x: width, y: height * 0.5)
                beltLineTo = CGPoint(x: width * 0.5, y: height)
            }
            imageUnselect = UIImage.size(width: width, height: height)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.square)
                    UIColor.white.withAlphaComponent(0.3).setStroke()
                    context.setLineWidth(beltLineW)
                    context.move(to: beltMoveTo!)
                    context.addLine(to: beltLineTo!)
                    context.strokePath()

                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(lineWidth)
                    context.move(to: CGPoint(x: factor * shape[0] + addX, y: factor * shape[1] + addY))
                    context.addLine(to: CGPoint(x: factor * shape[2] + addX, y: factor * shape[3] + addY))
                    context.move(to: CGPoint(x: factor * shape[4] + addX, y: factor * shape[5] + addY))
                    context.addLine(to: CGPoint(x: factor * shape[6] + addX, y: factor * shape[7] + addY))
                    context.strokePath()
                })

            imageSelect = UIImage.size(width: width, height: height)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.square)
                    tin.setStroke()
                    context.setLineWidth(beltLineW)
                    context.move(to: beltMoveTo!)
                    context.addLine(to: beltLineTo!)
                    context.strokePath()
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(lineWidth)
                    context.move(to: CGPoint(x: factor * shape[0] + addX, y: factor * shape[1] + addY))
                    context.addLine(to: CGPoint(x: factor * shape[2] + addX, y: factor * shape[3] + addY))
                    context.move(to: CGPoint(x: factor * shape[4] + addX, y: factor * shape[5] + addY))
                    context.addLine(to: CGPoint(x: factor * shape[6] + addX, y: factor * shape[7] + addY))
                    context.strokePath()
                })
        case .triangle:
            let beltLineW = width * 0.75
            var beltMoveTo: CGPoint?
            var beltLineTo: CGPoint?
            switch self.checkboxPosition {
            case .topRight:
                addX = factor * 2
                addY = -factor * (isRemove ? 1.75 : 2.5)
                beltMoveTo = CGPoint(x: width * 0.5, y: 0)
                beltLineTo = CGPoint(x: width, y: height * 0.5)
            case .bottomLeft:
                addX = -factor * (isRemove ? 2 : 1.75)
                addY = factor * (isRemove ? 1.75 : 1.5)
                beltMoveTo = CGPoint(x: -width * 0.25, y: height * 0.25)
                beltLineTo = CGPoint(x: width * 0.5, y: height)
            case .topLeft:
                addX = -factor * (isRemove ? 2 : 1.5)
                addY = -factor * (isRemove ? 1.75 : 2.5)
                beltMoveTo = CGPoint(x: width * 0.5, y: 0)
                beltLineTo = CGPoint(x: 0, y: height * 0.5)
            case .bottomRight:
                addX = factor * (isRemove ? 2 : 1.5)
                addY = factor * (isRemove ? 1.75 : 1.5)
                beltMoveTo = CGPoint(x: width, y: height * 0.5)
                beltLineTo = CGPoint(x: width * 0.5, y: height)
            }

            imageUnselect = UIImage.size(width: width, height: height)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.square)
                    UIColor.white.withAlphaComponent(0.3).setStroke()
                    context.setLineWidth(beltLineW)
                    context.move(to: beltMoveTo!)
                    context.addLine(to: beltLineTo!)
                    context.strokePath()

                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(lineWidth)
                    context.move(to: CGPoint(x: factor * shape[0] + addX, y: factor * shape[1] + addY))
                    context.addLine(to: CGPoint(x: factor * shape[2] + addX, y: factor * shape[3] + addY))
                    context.move(to: CGPoint(x: factor * shape[4] + addX, y: factor * shape[5] + addY))
                    context.addLine(to: CGPoint(x: factor * shape[6] + addX, y: factor * shape[7] + addY))
                    context.strokePath()
                })

            imageSelect = UIImage.size(width: width, height: height)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.square)
                    tin.setStroke()
                    context.setLineWidth(beltLineW)
                    context.move(to: beltMoveTo!)
                    context.addLine(to: beltLineTo!)
                    context.strokePath()
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(lineWidth)
                    context.move(to: CGPoint(x: factor * shape[0] + addX, y: factor * shape[1] + addY))
                    context.addLine(to: CGPoint(x: factor * shape[2] + addX, y: factor * shape[3] + addY))
                    context.move(to: CGPoint(x: factor * shape[4] + addX, y: factor * shape[5] + addY))
                    context.addLine(to: CGPoint(x: factor * shape[6] + addX, y: factor * shape[7] + addY))
                    context.strokePath()
                })
        case .heart:
            let spaceW = width / 8
            let radius = (width - spaceW * 2) / 4
            let leftCenter = CGPoint(x: spaceW + radius, y: spaceW + radius)
            let rightCenter = CGPoint(x: spaceW + radius * 3, y: spaceW + radius)

            imageUnselect = UIImage.size(width: width, height: height)
                .color(.clear)
                .image
                .with({ context in
                    let heartLine = UIBezierPath(arcCenter: leftCenter, radius: radius, startAngle: CGFloat(Double.pi), endAngle: 0, clockwise: true)
                    heartLine.addArc(withCenter: rightCenter, radius: radius, startAngle: CGFloat(Double.pi), endAngle: 0, clockwise: true)
                    heartLine.addQuadCurve(to: CGPoint(x: width / 2, y: height - spaceW * 2), controlPoint: CGPoint(x: width - spaceW, y: height * 0.6))
                    heartLine.addQuadCurve(to: CGPoint(x: spaceW, y: spaceW + radius), controlPoint: CGPoint(x: spaceW, y: height * 0.6))
                    context.addPath(heartLine.cgPath)
                    context.setLineCap(.round)
                    UIColor.white.withAlphaComponent(0.7).setStroke()
                    context.setLineWidth(lineWidth)
                    context.strokePath()
                })
            imageSelect = UIImage.size(width: width, height: height)
                .color(.clear)
                .image
                .with({ context in
                    let heartLine = UIBezierPath(arcCenter: leftCenter, radius: radius, startAngle: CGFloat(Double.pi), endAngle: 0, clockwise: true)
                    heartLine.addArc(withCenter: rightCenter, radius: radius, startAngle: CGFloat(Double.pi), endAngle: 0, clockwise: true)
                    heartLine.addQuadCurve(to: CGPoint(x: width / 2, y: height - spaceW * 2), controlPoint: CGPoint(x: width - spaceW, y: height * 0.6))
                    heartLine.addQuadCurve(to: CGPoint(x: spaceW, y: spaceW + radius), controlPoint: CGPoint(x: spaceW, y: height * 0.6))
                    context.addPath(heartLine.cgPath)
                    context.setLineCap(.round)
                    tin.set()
                    context.fillPath()
                })
        case .star:
            let spaceW = width / 10
            let centerPoint = CGPoint(x: width * 0.5, y: height * 0.5)
            let radius = Float(width * 0.5 - spaceW)
            var point = CGPoint(x: centerPoint.x, y: centerPoint.y - CGFloat(radius))
            let angle = Float(4 * Double.pi / 5.0)

            imageUnselect = UIImage.size(width: width, height: height)
                .color(.clear)
                .border(color: UIColor.white.withAlphaComponent(0.7))
                .border(width: TGPhotoPickerConfig.shared.isShowBorder ? TGPhotoPickerConfig.shared.checkboxLineW : 0)
                .corner(radius: width * 0.5)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    UIColor.white.withAlphaComponent(0.3).setFill()
                    context.setLineWidth(lineWidth)
                    context.move(to: point)
                    for idx in 1...5 {
                        let x = centerPoint.x - CGFloat(sinf(Float(idx) * angle) * radius)
                        let y = centerPoint.y - CGFloat(cosf(Float(idx) * angle) * radius)
                        context.addLine(to: CGPoint(x: (point.x + x) / 2 + (idx == 2 || idx == 5 ? lineWidth : -lineWidth), y: (point.y + y) / 2 + (idx == 3 ? -lineWidth : 0) ))
                        point = CGPoint(x: x, y: y)
                        context.addLine(to: point)
                    }
                    context.fillPath()
                })
            imageSelect = UIImage.size(width: width, height: height)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    tin.setFill()
                    //context.setLineWidth(L)
                    context.move(to: point)
                    for idx in 1...5 {
                        let x = centerPoint.x - CGFloat(sinf(Float(idx) * angle) * radius)
                        let y = centerPoint.y - CGFloat(cosf(Float(idx) * angle) * radius)
                        context.addLine(to: CGPoint(x: (point.x + x) / 2 + (idx == 2 || idx == 5 ? lineWidth : -lineWidth), y: (point.y + y) / 2 + (idx == 3 ? -lineWidth : 0) ))
                        point = CGPoint(x: x, y: y)
                        context.addLine(to: point)
                    }
                    context.fillPath()
                })
        //default: break
        }

        return(imageSelect!, imageUnselect!, CGSize(width: width, height: height))
    }

    private func cacheNumberImage() {
        if isShowNumber {
            switch checkboxType {
            case .onlyCheckbox, .circle, .square, .belt, .diagonalBelt, .triangle, .heart, .star:
                cacheNumerImageArr.removeAll()
                cacheNumerImageForBarArr.removeAll()
                for idx in 1...maxImageCount {
                    if let image = getDigitImage(UInt(idx)), let barImage = getDigitImage(UInt(idx), .circle, false, fontSize + 3) {
                        cacheNumerImageArr.append(image)
                        cacheNumerImageForBarArr.append(barImage)
                    }
                }
            }
        } else {
            cacheNumerImageArr.removeAll()
            cacheNumerImageForBarArr.removeAll()
        }
    }

    class func getChineseAlbumName(_ type: PHAssetCollectionSubtype, _ name: String = "") -> String {
        switch type {
        case .smartAlbumPanoramas:
            return "全景照片"
        case .smartAlbumVideos:
            return "视频"
        case .smartAlbumFavorites:
            return "个人收藏"
        case .smartAlbumTimelapses:
            return "延时摄影"
        case .smartAlbumAllHidden:
            return "隐藏"
        case .smartAlbumRecentlyAdded:
            return "最近添加"
        case .smartAlbumBursts:
            return "连拍快照"
        case .smartAlbumSlomoVideos:
            return "慢动作"
        case .smartAlbumUserLibrary:
            return "所有照片"//相机胶卷
        case .smartAlbumSelfPortraits:
            return "自拍"
        case .smartAlbumScreenshots:
            return "屏幕快照"
        case .smartAlbumDepthEffect:
            return "景深效果"
        case .smartAlbumLivePhotos:
            return "Live Photo"
        default:
            switch name {
            case "Recently Deleted":
                return "最近删除"
            case "All Photos":
                return "所有照片"
            case "Camera Roll":
                return "相机胶卷"
            case "Favorites":
                return "收藏"
            case "Videos":
                return "视频"
            case "Recently Added":
                return "最近添加"
            case "Selfies":
                return "自拍"
            case "Screenshots":
                return "屏幕快照"
            case "Panoramas":
                return "全景照片"
            case "Slo-mo":
                return "慢动作"
            case "Bursts":
                return "连拍快照"
            case "Hidden":
                return "隐藏"
            case "Time-lapse":
                return "延时摄影"
            case "Live Photos":
                return "生活"
            case "Depth Effect":
                return "景深效果"
            default:
                return name
            }
        }
    }
}

extension UIColor {
    func getAlpha() -> CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0

        if self.getRed(&red, green: &green, blue: &blue, alpha: &opacity) {
            return opacity
        }

        guard let cmps = self.cgColor.components else {
            return 1
        }
        return cmps[3]
    }

    class func hexInt(_ hexValue: Int) -> UIColor {
        return UIColor(red: ((CGFloat)((hexValue & 0xFF0000) >> 16)) / 255.0,
                       green: ((CGFloat)((hexValue & 0xFF00) >> 8)) / 255.0,
                       blue: ((CGFloat)(hexValue & 0xFF)) / 255.0,
                       alpha: 1.0)
    }
}

extension UIView {
    func clipRectCorner(direction: UIRectCorner, cornerRadius: CGFloat) {
        let cornerSize = CGSize(width: cornerRadius, height: cornerRadius)
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: direction, cornerRadii: cornerSize)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.addSublayer(maskLayer)
        layer.mask = maskLayer
    }

    var x: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var temp = self.frame
            temp.origin.x = newValue
            self.frame = temp
        }
    }

    var y: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            var temp = self.frame
            temp.origin.y = newValue
            self.frame = temp
        }
    }

    var rightX: CGFloat {
        get {
            return self.x + self.width
        }
        set {
            var temp = self.frame
            temp.origin.x = newValue - frame.size.width
            self.frame = temp
        }
    }

    var bottomY: CGFloat {
        get {
            return self.y + self.height
        }
        set {
            var temp = self.frame
            temp.origin.y = newValue - frame.size.height
            self.frame = temp
        }
    }
    // swiftlint:disable identifier_name
    var w: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            var temp = self.frame
            temp.size.width = newValue
            self.frame = temp
        }
    }

    var h: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            var temp = self.frame
            temp.size.height = newValue
            self.frame = temp
        }
    }
    // swiftlint:enable identifier_name

    var origin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            self.x = newValue.x
            self.y = newValue.y
        }
    }

    var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            self.width = newValue.width
            self.height = newValue.height
        }
    }
}
