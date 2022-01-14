//
//  Helper.swift
//  Demo
//
//  Created by Appinventiv on 11/25/20.
//  Copyright © 2020 Appinventiv. All rights reserved.
//

import UIKit
import AVFoundation

extension FileManager{
    
    class func removeFile(atPath filePath: String) {
        let fileManager = self.default
        if fileManager.fileExists(atPath: filePath) {
            do {
                try fileManager.removeItem(atPath: filePath)
            }
            catch{
            }
        }
    }
    
}




private let _shared = LocalFileOperation()

class LocalFileOperation {
    
    static var shared: LocalFileOperation {
        return _shared
    }
    
    // MARK: - Write Operations
    
    func removeFileWithCompletePath(filePath: URL) {
        do {
            try FileManager.default.removeItem(atPath: filePath.path)
            debugPrint("Compressed Local File removed successfully")
        } catch let error  {
            debugPrint(error.localizedDescription)
        }
    }

   
    
    func writeFile(_ image: UIImage, _ imgName: String) -> Bool{
        let imageData = image.jpegData(compressionQuality: 1.0)
        let relativePath = imgName
        let path = self.getAbsolutePathFor(fileName: relativePath)
        
        do {
            try imageData?.write(to: path, options: .atomic)
        } catch {
            return false
        }
        return true
    }
    
    func readFile(_ name: String) -> UIImage {
        let fullPath = self.getAbsolutePathFor(fileName: name)
        var image = UIImage()
        
        if FileManager.default.fileExists(atPath: fullPath.path){
            image = UIImage(contentsOfFile: fullPath.path)!
        }else{
             //a default place holder image from apps asset folder
        }
        return image
    }
    
    func readFileData(localFileName: String, mediaType: MediaType) -> Data? {
        if let dirPath = self.getDirectoryPathFor(mediaType: mediaType) {
            let filePath = dirPath.appendingPathComponent(localFileName)
            do {
                let fileData = try Data(contentsOf: filePath)
                return fileData
            } catch {
                return nil
            }
        }
        return nil
    }

    
    func getCompleteFilePath(fileName: String, mediaType: MediaType) -> URL? {
        if let dirPath = self.getDirectoryPathFor(mediaType: mediaType) {
            let filePath = dirPath.appendingPathComponent(fileName)
            return filePath
        }
        return nil
    }
    
    // MARK: - Helper Methods
    func getDirectoryPathFor(mediaType: MediaType) -> URL? {
        let dirPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let dirPath = dirPaths[0]
        var mediaDirPath: URL? = nil
        switch mediaType {
        case .image:
            mediaDirPath = dirPath.appendingPathComponent("media/images")
        case .video:
            mediaDirPath = dirPath.appendingPathComponent("media/videos")
        case .gif, .sticker:
            mediaDirPath = dirPath.appendingPathComponent("media/gif")
//        case .sticker:
//            mediaDirPath = dirPath.appendingPathComponent("media/bitmoji")
        case .file:
            mediaDirPath = dirPath.appendingPathComponent("media/file")
        case .audio:
            mediaDirPath = dirPath.appendingPathComponent("media/audio")
        case .thumbnail:
             mediaDirPath = dirPath.appendingPathComponent("media/thumbnail")
        case .unknown:
            break
        }
        
        guard let safeDirPath = mediaDirPath else { return nil }
        if self.isDirectoryExist(path: safeDirPath.absoluteString) {
            return safeDirPath
        } else {
            do {
                try FileManager.default.createDirectory(atPath: safeDirPath.relativePath, withIntermediateDirectories: true, attributes: nil)
                return safeDirPath
            } catch let error {
                debugPrint(error.localizedDescription)
                return nil
            }
        }
    }
    
    func getAbsolutePathFor(fileName: String) -> URL{
        let dirPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let dirPath = dirPaths[0]
        let filePath = dirPath.appendingPathComponent(fileName)
        return filePath
    }
    
    func isDirectoryExist(path: String) -> Bool{
        var isDir : ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
            return isDir.boolValue
        } else {
            return false
        }
    }
    
    func uniqueFileNameWithExtention(fileExtension: String) -> String {
        let uniqueString: String = ProcessInfo.processInfo.globallyUniqueString
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddhhmmsss"
        let currentDate = Date()
        let dateString: String = formatter.string(from: currentDate)
        let uniqueName: String = "\(uniqueString)_\(dateString)"
        if fileExtension.count > 0 {
            let fileName: String = "\(uniqueName).\(fileExtension)"
            return fileName
        }
        return uniqueName
    }
    
        func deleteMediaFilesDirectory() {
            let dirPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let dirPath = dirPaths[0]
            let safeDirPath: URL = dirPath.appendingPathComponent("media")

            do {
                try FileManager.default.removeItem(at: safeDirPath)
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
}


enum MediaType : String {
    
    case image = "IMAGE"
    case video = "VIDEO"
    case file = "FILE"
    case audio = "AUDIO"
    case gif = "GIF"
    case sticker = "STICKER"
    case thumbnail = "THUMBNAIL"
    case unknown
    
    var mimeType: String {
        switch self {
        case .image:
            return "image"
        default:
            return ""
        }
    }
}
