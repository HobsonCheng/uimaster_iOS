//
//  SandboxTool.swift
//  UIDS
//
//  Created by one2much on 2018/1/15.
//  Copyright © 2018年 one2much. All rights reserved.
//

import UIKit

///沙盒路径类型
enum SandboxType {
    case library
    case preferences
    case document
    case caches
    case home
    case tmp
    case bundle
    case applicationSupport
}
enum SandboxFileType {
    case text
    case image
}
/// 该类主要用于从沙盒中寻找文件数据
class SandboxTool {
    /// 获取文件路径
    ///
    /// - Parameters:
    ///   - fileName: 文件名，常用的在GlobalConst中有声明
    ///   - location: 文件位置
    /// - Returns: 文件完整路径
    static func getFilePath(of fileName: String, in location: SandboxType, subPathStr: String = "") -> String {
        let fileName = subPathStr == "" ?  fileName : subPathStr + "/" + fileName
        switch location {
        case .home:
            return "\(homePath())/\(fileName)"
        case .bundle:
            return "\(bundlePath())/\(fileName)"
        case .library:
            return "\(libraryPath())/\(fileName)"
        case .document:
            return "\(documentPath())/\(fileName)"
        case .caches:
            return "\(cachesPath())/\(fileName)"
        case .tmp:
            return "\(tmpPath())/\(fileName)"
        case .preferences:
            return "\(perferencesPath())/\(fileName)"
        case .applicationSupport:
            return "\(applicationSupportPath())/\(fileName)"
        }
    }

    /// 创建文件夹
    ///
    /// - Parameter path: 文件夹路径
    static func createDir(path: String) {
        let manager = FileManager.default
        do {
            try manager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            dPrint(error)
        }
    }

    /// 根据文件路径,检测文件是否存在
    ///
    /// - Parameter path: 文件路径
    /// - Returns: 文件是否存在
    static func isFileExist(in path: String) -> Bool {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            return true
        }
        return false
    }

    /// 根据文件名和位置，检测文件是否存在
    ///
    /// - Parameters:
    ///   - fileName: 文件名，常用的在GlobalConst中有声明
    ///   - location: 沙盒位置
    /// - Returns: 文件是否存在
    static func isFileExist(of fileName: String, in location: SandboxType, subPath: String = "") -> Bool {
        var path = ""
        let fileName = subPath == "" ? fileName : subPath + "/" + fileName
        switch location {
        case .home:
            path = "\(homePath())/\(fileName)"
        case .bundle:
            path = "\(bundlePath())/\(fileName)"
        case .library:
            path = "\(libraryPath())/\(fileName)"
        case .document:
            path = "\(documentPath())/\(fileName)"
        case .caches:
            path = "\(cachesPath())/\(fileName)"
        case .tmp:
            path = "\(tmpPath())/\(fileName)"
        case .preferences:
            path = "\(perferencesPath())/\(fileName)"
        case .applicationSupport:
            path = "\(applicationSupportPath())/\(fileName)"
        }
        return isFileExist(in: path)
    }
    /// 将bundle中的数据移到沙盒library目录下
    ///
    /// - Parameters:
    ///   - fileName: 文件名字
    ///   - type: 文件类型
    static func moveBundleDataToLibrary(of fileName: String, is type: SandboxFileType, desPath: FileManager.SearchPathDirectory = .libraryDirectory, subPathStr: String = "") {
        //读取bundle中的数据
        let path = SandboxTool.getFilePath(of: fileName, in: .bundle)
        let file = FileHandle(forReadingAtPath: path)
        let data: Data?
        switch type {
        case .image:
            data = UIImage(named: fileName)?.kf.pngRepresentation()
        case .text:
            data = file?.readDataToEndOfFile()
        }
        guard let safeData = data else {
            return
        }
        var tempData = Data()
        tempData.append(safeData)
        let subPath = subPathStr == "" ? "" : subPathStr + "/"
        let fileUrl = try? FileManager.default.url(for: desPath, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(subPath + fileName)
        //将数据写入到library路径下
        if let safeUrl = fileUrl {
            dPrint("\(safeUrl)")
            do {
                try tempData.write(to: safeUrl, options: .atomic)
            } catch {
                dPrint(error)
            }
        }
    }
    /// 读取文件数据
    ///
    /// - Parameters:
    ///   - fileName: 文件名
    ///   - dir: 所在目录
    ///   - subPath: 目录下的路径
    ///   - type: 文件类型
    /// - Returns: 读取的数据
    static func readData(fileName: String, dir: SandboxType, subPath: String, type: SandboxFileType) -> Data {
        let path = SandboxTool.getFilePath(of: fileName, in: dir, subPathStr: subPath)
        let file = FileHandle(forReadingAtPath: path)
        let data: Data?
        switch type {
        case .image:
            data = UIImage(named: fileName)?.kf.pngRepresentation()
        case .text:
            data = file?.readDataToEndOfFile()
        }
        return data ?? Data()
    }
    /// 把data数据，写入沙盒
    ///
    /// - Parameters:
    ///   - data: 要写入的数据
    ///   - path: 要写到沙盒路径
    ///   - fileName: 文件名字
    static func writeData(from data: Data?, to path: FileManager.SearchPathDirectory, name fileName: String, subPathStr: String = "") {
        guard let safeData = data else {
            return
        }
        var tempData = Data()
        tempData.append(safeData)
        let subPath = subPathStr == "" ? "" : subPathStr + "/"
        let fileUrl = try? FileManager.default.url(for: path, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(subPath + fileName)
        //将数据写入到library路径下
        if let safeUrl = fileUrl {
            do {
                try tempData.write(to: safeUrl, options: .atomic)
            } catch {
                dPrint(error)
            }
        }
    }

    static func removeData(from path: FileManager.SearchPathDirectory, name fileName: String, subPathStr: String = "") {
        let fileManager = FileManager.default
        let subPath = subPathStr == "" ? "" : subPathStr + "/"
        let fileUrl = try? FileManager.default.url(for: path, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(subPath + fileName)
        if let safeUrl = fileUrl {
            try? fileManager.removeItem(at: safeUrl)
            dPrint("删除文件\(safeUrl)")
        }
    }
}

// MARK: - 沙盒基本路径
extension SandboxTool {
    ///获取Home路径
    static func homePath() -> String {
        return NSHomeDirectory()
    }

    ///获取document路径
    static func documentPath() -> String {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
    }
    ///获取library路径
    static func libraryPath() -> String {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
    }
    ///获取tmp文件路径
    static func tmpPath() -> String {
        return NSTemporaryDirectory()
    }
    ///获取caches文件路径
    static func cachesPath() -> String {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
    }
    ///获取preferences文件路径
    static func perferencesPath() -> String {
        let lib = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        return lib + "/Preferences"
    }
    ///获取bundlePath
    static func bundlePath() -> String {
        return Bundle.main.bundlePath
    }
    ///获取applicationSupport
    static func applicationSupportPath() -> String {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.applicationSupportDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
    }
    ///获取bundle中的文件路径
    static func getBundleFilePath(with fileName: String) -> String? {
        return Bundle.main.path(forResource: fileName, ofType: nil)
    }
}
