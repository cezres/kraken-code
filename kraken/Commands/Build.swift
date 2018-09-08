//
//  Build.swift
//  kraken
//
//  Created by 晨风 on 2017/5/10.
//  Copyright © 2017年 晨风. All rights reserved.
//

import Foundation



class Build: Command {
    
    var flag: String = "build"
    var shortFlag: String? = "b"
    
    var message: String? {
        return "编译target"
    }
    
    var verbose: Bool = false
    
    var commands: [Command]?
    
    var options: [String : String]? = ["--help": "帮助", "--verbose": "显示更多调试信息"]
    
    var usage: String? {
        return "$ kraken build".green + " [FRAMEWORK_TARGET_NAME]".blue
    }
    
    func handler(arguments: [String]) {
        guard arguments.count == 1 else {
            print(self)
            return
        }
        guard arguments.has(any: "--help") == -1 else {
            print(self)
            return
        }
        
        let targetname = arguments[0]
        _ = build(directory: CurrentDirectory, target: targetname, output: CurrentDirectory)
        
    }
    
}




private let xcodebuildPath = "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild"


/// 编译target
///
/// - Parameters:
///   - directory: <#directory description#>
///   - target: <#target description#>
///   - output: <#output description#>
/// - Returns: <#return value description#>
func build(directory: URL, target: String?, output: URL) -> Bool {
    
    var targetname: String? = target
    
    guard let projectPath = searchProjectPath(directory: directory) else {
        print("\(directory) 目录下未搜索到Xcode项目文件".red)
        exit(-1)
    }
    if targetname == nil {
        targetname = projectPath.deletingPathExtension().lastPathComponent
    }
    return build(project: projectPath, target: targetname!, output: output)
}

/// 编译target
///
/// - Parameters:
///   - project: <#project description#>
///   - target: <#target description#>
///   - output: <#output description#>
/// - Returns: <#return value description#>
func build(project: URL, target: String, output: URL) -> Bool {
    
    let iphoneosShell: String
    let iphonesimulatorShell: String
    
    if project.pathExtension == "xcworkspace" {
        iphoneosShell = "xcodebuild -workspace \(project.lastPathComponent) -scheme \(target) -configuration Release -sdk iphoneos clean build"
        iphonesimulatorShell = "xcodebuild -workspace \(project.lastPathComponent) -scheme \(target) -configuration Release -sdk iphonesimulator clean build"
    }
    else if project.pathExtension == "xcodeproj" {
        iphoneosShell = "xcodebuild -project \(project.lastPathComponent) -configuration Release -target \(target) -sdk iphoneos clean build"
        iphonesimulatorShell = "xcodebuild -project \(project.lastPathComponent) -configuration Release -target \(target) -sdk iphonesimulator clean build"
    }
    else {
        print("\(project.path) \(target) \(output)".red)
        exit(-1)
    }
    
    let dirPath = project.deletingLastPathComponent().path
    
    let iphoneosResult = launchedShell(shell: iphoneosShell, directoryPath: dirPath)
    guard let iphoneosFramework = getFrameworkPath(log: iphoneosResult) else {
        print("Shell: \(iphoneosShell)".red)
        exit(-1)
    }
    print(iphoneosFramework.path)
    print("** BUILD iphoneos SUCCEEDED **".green)
    
    
    let iphonesimulatorResult = launchedShell(shell: iphonesimulatorShell, directoryPath: "")
    guard let iphonesimulatorFramework = getFrameworkPath(log: iphonesimulatorResult) else {
        print("Shell \(iphonesimulatorShell)".red)
        exit(-1)
    }
    print(iphonesimulatorFramework.path)
    print("** BUILD iphonesimulator SUCCEEDED **".green)
    
    let exportDirectory = output
    guard let framework = mergeFramework(iphoneosFramework: iphoneosFramework, iphonesimulatorFramework: iphonesimulatorFramework, exportDirectory: exportDirectory) else {
        print("error merge framework".red)
        exit(-1)
    }
    print(framework.path)
    print("** MERGE FRAMEWORK SUCCEEDED **".green)
    
    return true
}


/// 从xcodebuild执行
///
/// - Parameter log: <#log description#>
/// - Returns: <#return value description#>
func getFrameworkPath(log: String) -> URL? {
    guard log.range(of: "SUCCEEDED **", options: .backwards, range: nil, locale: nil) != nil else {
        print(log)
        fatalError("编译失败")
    }
    guard let sRange = log.range(of: "/touch -c ", options: .backwards, range: nil, locale: nil) else {
        print(log)
        print("没有搜索到 /usr/bin/touch -c".red)
        exit(-1)
    }
    
    let lowerBound = sRange.upperBound
    let upperBound = log.endIndex
    let searchRange = Range(uncheckedBounds: (lowerBound, upperBound))
    guard let eRange = log.range(of: ".framework", options: .caseInsensitive, range: searchRange, locale: nil) else {
        print(log)
        print("没有搜索到 framework".red)
        exit(-1)
    }
    
    let substrRange = Range(uncheckedBounds: (lowerBound, eRange.upperBound))
    let string = log.substring(with: substrRange)
    return URL(fileURLWithPath: string)
}

func mergeFramework(iphoneosFramework: URL, iphonesimulatorFramework: URL, exportDirectory: URL) -> URL? {
    let exportFramework = exportDirectory.appendingPathComponent(iphoneosFramework.lastPathComponent)
    try? FileManager.default.removeItem(at: exportFramework)
    do {
        try FileManager.default.createDirectory(at: exportDirectory, withIntermediateDirectories: true, attributes: nil)
        try FileManager.default.moveItem(at: iphoneosFramework, to: exportFramework)
    }
    catch {
        return nil
    }
    let name = iphoneosFramework.deletingPathExtension().lastPathComponent
    let output = exportFramework.path + "/\(name)"
    
    Process.launchedProcess(launchPath: "/usr/bin/lipo", arguments: ["-create", output, iphonesimulatorFramework.path + "/\(name)", "-output", output]).waitUntilExit()
    let result = launchedShell(shell: "lipo -info \(output)", directoryPath: exportDirectory.path)
    print(result)
    if result.range(of: "i386") != nil ||
        result.range(of: "x86_64") != nil ||
        result.range(of: "armv7") != nil ||
        result.range(of: "arm64") != nil {
        return exportFramework
    }
    else {
        return nil
    }
}




