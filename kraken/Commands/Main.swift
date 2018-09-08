//
//  Main.swift
//  kraken
//
//  Created by 晨风 on 2017/7/25.
//  Copyright © 2017年 晨风. All rights reserved.
//

import Foundation


class Main: Command {
    
    var flag: String = "kraken"
    
    var verbose: Bool = false
    
    var commands: [Command]? = [Init(), Push(), Build(), Global()/*, Pod()*/, Update(), Version()]
    
    var options: [String: String]? {
        return ["--help": "帮助", "--verbose": "显示更多调试信息"]
    }
    
    var usage: String? {
        return "$ kraken".green + " " + "[COMMAND]".blue +
            "\n\n    1. " + "$ cd ".green + "[PROJECT_DIR]".blue +
            "\n    2. " + "$ kraken init ".green + "[POD_NAME]".blue +
            "\n    3. " + "$ kraken push ".green + "[POD_NAME] [VERSION]".blue
    }
    
    var message: String?
    
    func handler(arguments: [String]) {
        
        guard arguments.count > 0 else {
            print(self)
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
    
    func searchCommand() {
        
    }
    
}


