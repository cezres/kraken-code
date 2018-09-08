//
//  Update.swift
//  kraken
//
//  Created by 晨风 on 2017/5/11.
//  Copyright © 2017年 晨风. All rights reserved.
//

import Foundation

//curl "http://oh32pp4u5.bkt.clouddn.com/${1}" --create-dirs -o $2/$1

class Update: Command {
    
    var flag: String = "update"
    var shortFlag: String? = "u"
    
    var message: String? {
        return "更新kraken"
    }
    
    var verbose: Bool = false
    
    var commands: [Command]?
    
    var options: [String : String]? = ["--verbose": "显示更多调试信息", "--help": "帮助"]
    
    var usage: String? {
        return "$ kraken update".green
    }
    
    func handler(arguments: [String]) {
        
        guard arguments.has(any: "--help") == -1 else {
            print(self)
            return
        }
        
        let verbose = arguments.has(any: "--verbose") != -1
        
        do {
            let version = try String(contentsOf: URL(string: "https://raw.githubusercontent.com/cezres/kraken/master/version")!, encoding: .utf8)
            print("当前版本: \(VERSION.blue) 最新版本: \(version.green)\n")
            
            if version != VERSION {
                let zipPath = "https://raw.githubusercontent.com/cezres/kraken/master/kraken.zip"
                let savePath = "/usr/local/bin/kraken.zip"
                let krakenPath = "/usr/local/bin/kraken"
                if verbose {
                    print("文件路径: \(zipPath)".blue)
                    print("存储路径: \(savePath)".blue)
                }
                print("开始下载kraken.zip...".blue)
                
                Process.launchedProcess(launchPath: "/bin/sh", arguments: ["-c", "curl \(zipPath) --create-dirs -o \(savePath)"]).waitUntilExit()
                
                if !FileManager.default.fileExists(atPath: savePath) {
                    print("kraken.zip下载失败".red)
                    return
                }
                if verbose {
                    print("文件下载成功".green)
                }
                if verbose {
                    print("开始解压缩...".blue)
                }
                Process.launchedProcess(launchPath: "/bin/sh", arguments: ["-c", "unzip -o \(savePath) -d \(krakenPath)"]).waitUntilExit()
                
                if !FileManager.default.fileExists(atPath: krakenPath) {
                    print("kranken.zip解压缩失败".red)
                    return
                }
                if verbose {
                    print("解压缩成功".green)
                }
                try? FileManager.default.removeItem(atPath: savePath)
                if verbose {
                    print("删除kraken.zip".blue)
                }
                print("更新完成".green)
            }
        }
        catch {
            print(error.localizedDescription.red)
        }
        
        
    }
    
    
}


