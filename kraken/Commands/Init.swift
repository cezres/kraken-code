//
//  Init.swift
//  kraken
//
//  Created by 晨风 on 2017/5/10.
//  Copyright © 2017年 晨风. All rights reserved.
//

import Foundation


class Init: Command {
    
    var flag: String { return "init" }
    
    var shortFlag: String? = "i"
    
    var verbose: Bool = false
    
    var commands: [Command]?
    
    var options: [String: String]? {
        return ["--help": "帮助", "--verbose": "显示更多调试信息"]
    }
    
    var message: String? {
        return "初始化配置"
    }
    
    var usage: String? {
        return "$ kraken init".green + " " + "[POD_NAME]".blue
    }
    
    func handler(arguments: [String]) {
        guard arguments.count > 0 else {
            print(self)
            return
        }
        
        guard arguments.has(any: "--help") == -1 else {
            print(self)
            return
        }
        
        let verbose = arguments.has(any: "--verbose") != -1
        
        let podname = arguments[0]
        
        if verbose {
            print("POD_NAME: ".blue + podname.green)
        }
        
        Pod.initialize(podname: podname)
        
        
    }
    
}


