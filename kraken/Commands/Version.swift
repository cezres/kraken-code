//
//  Version.swift
//  kraken
//
//  Created by 晨风 on 2017/7/14.
//  Copyright © 2017年 晨风. All rights reserved.
//

import Foundation


class Version: Command {
    
    var flag: String = "version"
    var shortFlag: String? = "v"
    
    var message: String? {
        return "显示当前版本或最新版本"
    }
    
    var verbose: Bool = false
    
    var commands: [Command]? = [Version_New()]
    
    var options: [String : String]? = ["--help": "帮助"]
    
    var usage: String? {
        return "$ kraken version".green + "\n    $ kraken version".green + " [COMMAND]".blue
    }
    
    func handler(arguments: [String]) {
        guard arguments.count > 0 else {
            print("当前版本: " + VERSION.blue + "\n")
            return
        }
        
        for command in commands ?? [] {
            if command.flag == arguments[0] || command.shortFlag == arguments[0] {
                command.handler(arguments: arguments.deleteFirst)
                return
            }
        }
        
        guard arguments.has(any: "--help") == -1 else {
            print(self)
            return
        }
    }
    
}


class Version_New: Command {
    
    var flag: String = "new"
    var shortFlag: String? = "n"
    
    var message: String? {
        return "显示最新版本"
    }
    
    var verbose: Bool = false
    
    var commands: [Command]?
    
    var options: [String : String]? = ["--verbose": "显示更多调试信息", "--help": "帮助"]
    
    var usage: String? {
        return "$ kraken version new".green
    }
    
    func handler(arguments: [String]) {
        guard arguments.has(any: "--help") == -1 else {
            print(self)
            return
        }
        
        do {
            let version = try String(contentsOf: URL(string: "https://raw.githubusercontent.com/cezres/kraken/master/version")!, encoding: .utf8)
            print("最新版本: " + version.blue + "\n")
        }
        catch {
            print(error.localizedDescription.red)
        }
        
    }
    
    
}





