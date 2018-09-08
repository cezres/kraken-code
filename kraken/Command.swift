//
//  CommandLine.swift
//  kraken
//
//  Created by 晨风 on 2017/7/14.
//  Copyright © 2017年 晨风. All rights reserved.
//

import Foundation

protocol Command: CustomStringConvertible {
    
    var flag: String { get }
    
    var shortFlag: String? { get }
    
    var message: String? { get }
    
    var verbose: Bool { get set }
    
    var commands: [Command]? { get set }
    
    var options: [String: String]? { get }
    
    var usage: String? { get }
    
    func handler(arguments: [String])
    
}

extension Command {
    
    var shortFlag: String? {
        return nil
    }
    
    var flagDescription: String {
        if shortFlag == nil {
            return flag
        }
        else {
            return flag + "(\(shortFlag!))"
        }
    }
}

extension CustomStringConvertible where Self: Command {
    
    var description: String {
        var description = ""
        if let usage = usage {
            description += "Usage:\n\n".applyingStyle(.underline)
            description += "    " + usage + "\n\n"
        }
        if let commands = commands {
            description += "Commands:\n\n".applyingStyle(.underline)
            for cmd in commands {
                if let msg = cmd.message {
                    description += "    + \(cmd.flagDescription)".green
                    for _ in cmd.flagDescription.lengthOfBytes(using: .utf8) ... 10 {
                        description += " "
                    }
                    description += msg + "\n"
                }
                else {
                    description += "    " + cmd.flag.green + "\n"
                }
            }
            description += "\n"
        }
        if let options = options {
            description += "Options:\n\n".applyingStyle(.underline)
            for option in options {
                description += "    " + option.key.blue
                for _ in option.key.lengthOfBytes(using: .utf8) ... 12 {
                    description += " "
                }
                description += option.value + "\n"
            }
        }
        
        return description
    }
    
    
    
}







