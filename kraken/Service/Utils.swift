//
//  Utils.swift
//  kraken
//
//  Created by 晨风 on 2017/5/10.
//  Copyright © 2017年 晨风. All rights reserved.
//

import Foundation

let DocumentDirectory = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0], isDirectory: true).deletingLastPathComponent()
private let toolDirectory = DocumentDirectory.appendingPathComponent("/kraken", isDirectory: true)


func ToolDirectory() -> URL {
    try? FileManager.default.createDirectory(at: toolDirectory, withIntermediateDirectories: false, attributes: nil)
    return toolDirectory
}


extension String {
    func removeSuffixSpace() -> String {
        var newString = self
        while newString.hasSuffix(" ") {
            let lowerBound = newString.index(before: newString.endIndex)
            let range = Range(uncheckedBounds: (lowerBound, newString.endIndex))
            newString.replaceSubrange(range, with: "")
        }
        return newString
    }
}



func keyboardInput() -> String {
    let keyboard = FileHandle.standardInput
    let inputData = keyboard.availableData
    let input = String(data: inputData, encoding: .utf8)!.replacingOccurrences(of: "\n", with: "").removeSuffixSpace().replacingOccurrences(of: "\\ ", with: " ")
    if input == "q" {
        print("退出".blue)
        exit(-1)
    }
    return input
}


func searchProjectPath(directory: URL) -> URL? {
    do {
        let contents = try FileManager.default.contentsOfDirectory(atPath: directory.path)
        var xcodeproj: URL?
        for name in contents {
            if name.hasSuffix(".xcworkspace") {
                return directory.appendingPathComponent(name)
            }
            else if name.hasSuffix(".xcodeproj") {
                xcodeproj = directory.appendingPathComponent(name)
            }
        }
        return xcodeproj
    }
    catch {
        return nil
    }
}


func podspecPath(directoryPath: String) -> URL? {
    do {
        let contents = try FileManager.default.contentsOfDirectory(atPath: directoryPath)
        for name in contents {
            if name.hasSuffix(".podspec") {
                return URL(fileURLWithPath: directoryPath + "/\(name)")
            }
        }
        return nil
    }
    catch {
        return nil
    }
}



func isGitRepositoryDirectory(directory: URL) -> Bool {
    let gitDir = directory.appendingPathComponent(".git", isDirectory: true)
    var isDirectory: ObjCBool = false
    return FileManager.default.fileExists(atPath: gitDir.path, isDirectory: &isDirectory) && isDirectory.boolValue
}


func launchedShell(shell: String, directoryPath: String = "") -> String {
    
    let logPath = ToolDirectory().appendingPathComponent("log.txt", isDirectory: false)
    
    let process = Process()
    if directoryPath != "" {
        process.currentDirectoryPath = directoryPath
    }
    process.launchPath = "/bin/sh"
    process.arguments = ["-c", shell + " > \(logPath.path)"]
    process.launch()
    process.waitUntilExit()
    do {
        let string = try String(contentsOfFile: logPath.path)
        return string
    }
    catch {
        return ""
    }
}


