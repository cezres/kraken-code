//
//  Push.swift
//  kraken
//
//  Created by 晨风 on 2017/5/10.
//  Copyright © 2017年 晨风. All rights reserved.
//

import Foundation


class Push: Command {
    
    var flag: String { return "push" }
    var shortFlag: String? = "p"
    
    var verbose: Bool = false
    
    var commands: [Command]?
    
    var options: [String: String]? {
        return ["--help": "帮助", "--verbose": "显示更多调试信息", "--no-check": "不检查podspec"]
    }
    
    var message: String? {
        return "编译合并提交framework -> 提交podspec"
    }
    
    var usage: String? {
        return "$ kraken push".green + " " + "[POD_NAME] [VERSION]\n".blue + "    $ kraken push".green + " " + "[PODSPEC_FILENAME]".blue
    }
    
    func handler(arguments: [String]) {
        guard arguments.count >= 1 && arguments.has(any: "--help") == -1 else {
            print(self)
            return
        }
        
        guard !arguments[0].hasSuffix(".podspec") else {
            print("提交podspec".blue)
            let podspec = CurrentDirectory.appendingPathComponent(arguments[0])
            print(podspec.path)
            Podspec.repoPushNotCheck(podspec: podspec, name: arguments[0].deletePathExtension, version: nil, localRepoName: Global.podsSource)
            return
        }
        
        let podname = arguments[0]
        let version = arguments[1]
        Pod.load(podname: podname)
        let podspec = URL(fileURLWithPath: Pod.podspec)
        
        
        pull(directory: URL(fileURLWithPath: Pod.frameworkRepo))
        print("PULL SUCCEEDED".green)
        
        print("编译framework-targets".blue)
        for target in Pod.buildTargets.components(separatedBy: "|") {
            guard build(project: URL(fileURLWithPath: Pod.projectPath), target: target, output: URL(fileURLWithPath: Pod.frameworkRepo)) else {
                exit(-1)
            }
        }
        
        print("提交framework".blue)
        guard let commit_id = commit(directory: URL(fileURLWithPath: Pod.frameworkRepo), message: "Update \(podname) \(version)") else {
            exit(-1)
        }
        
        print("修改podspec".blue)
        Podspec.update(podspecURL: podspec, commit_id: commit_id, version: version)
        
        // 提交podspec
        print("提交podspec".blue)
        if arguments.has(any: "--no-check") != -1 {
            Podspec.repoPushNotCheck(podspec: podspec, name: Pod.name, version: version, localRepoName: Global.podsSource)
        }
        else {
            Podspec.repoPush(podspec: podspec, localRepoName: Global.podsSource)
        }
    }
    
}


