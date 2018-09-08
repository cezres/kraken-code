//
//  Pod.swift
//  kraken
//
//  Created by 晨风 on 2017/7/14.
//  Copyright © 2017年 晨风. All rights reserved.
//

import Foundation

class Pod: Command {
    
    var flag: String = "pod"
    
    var message: String? {
        return "显示/编辑pod配置"
    }
    
    var verbose: Bool = false
    
    var commands: [Command]?
    
    var options: [String : String]? = ["--help": "帮助"]
    
    var usage: String? {
        return "$ kraken pod\n    $ kraken pod".green + " [KEY] [VALUE]".blue
    }
    
    func handler(arguments: [String]) {
        guard arguments.count > 0 else {
            print(self)
            return
        }
    }
    
    static var dictValue = [String: String]()
    class var name: String {
        return dictValue["name"]!
    }
    class var projectPath: String {
        return dictValue["projectPath"]!
    }
    class var buildTargets: String {
        return dictValue["buildTargets"]!
    }
    class var frameworkRepo: String {
        return dictValue["frameworkRepo"]!
    }
    class var source_git: String {
        return dictValue["source_git"]!
    }
    class var podspec: String {
        return dictValue["podspec"]!
    }
    
    
    class func initialize(podname: String) {
        let configURL = CurrentDirectory.appendingPathComponent("kraken.plist")
        if let dict = NSDictionary(contentsOf: configURL) {
            if let podDict = dict.object(forKey: podname) as? [String: String] {
                dictValue = podDict
                return
            }
        }
        
        dictValue["name"] = podname
        
        let path = searchProjectPath(directory: CurrentDirectory)
        guard path != nil else {
            print("需要在项目目录下执行命令".red)
            exit(-1)
        }
        dictValue["projectPath"] = path!.path
        
        print("输入需要编译的framework_tagets(多个target用'|'分隔  targetA|targrtB, Enter使用\(podname): ".blue)
        dictValue["buildTargets"] = keyboardInput()
        if (dictValue["buildTargets"] ?? "").isEmpty {
            dictValue["buildTargets"] = podname
        }
        
        repeat {
            print("输入 framework git地址: ".blue)
            let git = keyboardInput()
            if git.hasSuffix(".git") {
                let gitname = NSString(string: git).components(separatedBy: "/").last?.deletePathExtension
                if gitname != nil {
                    let dirURL = ToolDirectory().appendingPathComponent("FrameworkRepos", isDirectory: true).appendingPathComponent(gitname!, isDirectory: true)
                    if FileManager.default.fileExists(atPath: dirURL.path) {
                        print("已存在\(gitname!)".green)
                    }
                    else {
                        try? FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
                        _ = launchedShell(shell: "git clone \(git)", directoryPath: ToolDirectory().appendingPathComponent("FrameworkRepos", isDirectory: true).path)
                        if !FileManager.default.fileExists(atPath: dirURL.path) {
                            print("git clone error: \(git)".red)
                        }
                    }
                    dictValue["frameworkRepo"] = dirURL.path
                    dictValue["source_git"] = git
                    break
                }
                else {
                    print("异常: \(git)".red)
                }
            }
            else {
                print("错误的git地址".red)
            }
        }
        while true
        
        
        let podspecURL = CurrentDirectory.appendingPathComponent("\(podname).podspec")
        if FileManager.default.fileExists(atPath: podspecURL.path) {
            dictValue["podspec"] = podspecURL.path
        }
        else {
            print("创建一个默认的podspec文件".blue)
            dictValue["podspec"] = Podspec.create(name: podname).path
        }
        
        save()
    }
    
    class func printPod() {
        var description = ""
        for (offset: _, element: (key: key, value: value)) in dictValue.enumerated() {
            description += "\(key)"
            for _ in key.lengthOfBytes(using: .utf8) ... 20 {
                description += " "
            }
            description += ":  \(value.blue)\n"
        }
        print(description)
    }
    
    class func save() {
        let configURL = CurrentDirectory.appendingPathComponent("kraken.plist")
        var dict: [String: Any]
        if let configDict = NSDictionary(contentsOf: configURL) {
            dict = configDict as! [String: Any]
        }
        else {
            dict = [String: Any]()
        }
        dict[name] = dictValue
        NSDictionary(dictionary: dict).write(to: configURL, atomically: true)
    }
    
    class func load(podname: String) {
        let configURL = CurrentDirectory.appendingPathComponent("kraken.plist")
        if let dict = NSDictionary(contentsOf: configURL) {
            if let podDict = dict.object(forKey: podname) as? [String: String] {
                dictValue = podDict
                return
            }
        }
        print("未初始化".red)
        print(Main())
        exit(-1)
    }
}


