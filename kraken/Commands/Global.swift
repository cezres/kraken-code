//
//  Global.swift
//  kraken
//
//  Created by 晨风 on 2017/7/14.
//  Copyright © 2017年 晨风. All rights reserved.
//

import Foundation



class Global: Command {
    
    var flag: String = "global"
    var shortFlag: String? = "g"
    
    var message: String? {
        return "显示/编辑全局配置"
    }
    
    var verbose: Bool = false
    
    var commands: [Command]?
    
    var options: [String : String]? = ["--help": "帮助"]
    
    var usage: String? {
        return "$ kraken global\n    $ kraken global".green + " [KEY] [VALUE]".blue
    }
    
    func handler(arguments: [String]) {
        guard arguments.has(any: "--help") == -1 else {
            print(self)
            return
        }
        
        guard arguments.count > 0 else {
            Global.printGlobal()
            return
        }
        
        if arguments.count == 2 {
            let key = arguments[0]
            let value = arguments[1]
            if Global.dictValue[key] != nil {
                Global.dictValue[key] = value
                Global.printGlobal()
            }
            else {
                print(self)
            }
        }
        else {
            print(self)
        }
        
    }
    
    
    static let name = "Global.plist"
    class var podsSource: String {
        get {
            return dictValue["podsSource"]!
        }
        set {
            dictValue["podsSource"] = newValue
        }
    }
    class var author_name: String {
        return dictValue["author_name"]!
    }
    class var author_email: String {
        return dictValue["author_email"]!
    }
    
    private static var dictValue = [String: String]()
    
    static var config: GlboalConfig!
    
    class func initialize() {
        let globalURL = ToolDirectory().appendingPathComponent(Global.name)
        if let globalDict = NSDictionary(contentsOf: globalURL) {
            dictValue = globalDict as! [String: String]
            return
        }
        dictValue["author_name"] = launchedShell(shell: "git config user.name").deleteLinefeed
        dictValue["author_email"] = launchedShell(shell: "git config user.email").deleteLinefeed
        
        
        if Podspec.hasPodsName(podsName: "__INPrivatePods__") {
            Global.podsSource = "__INPrivatePods__"
        }
        else {
            print("输入Pods源的git地址:(Enter默认使用git@githost.in66.cc:app/ios-galaxy-podspec.git)".blue)
            var privatePods = keyboardInput()
            if privatePods.isEmpty {
                privatePods = "git@githost.in66.cc:app/ios-galaxy-podspec.git"
            }
            print("添加私有Pods源 __INPrivatePods__  \(privatePods)".blue)
            Process.launchedProcess(launchPath: "/usr/local/bin/pod", arguments: ["repo", "add", "__INPrivatePods__", privatePods]).waitUntilExit()
            Global.podsSource = "__INPrivatePods__"
        }
        save()
    }
    
    
    class func printGlobal() {
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
        let globalURL = ToolDirectory().appendingPathComponent(Global.name)
        NSDictionary(dictionary: dictValue).write(to: globalURL, atomically: true)
    }
    
}


struct GlboalConfig: Codable {
    var podsSource: String?
    var author_name: String?
    var author_email: String?
    
    init() {
        
    }
    
    func save(url: URL) {
        do {
            let data = try JSONEncoder().encode(self)
            try data.write(to: url)
        }
        catch {
            print(error.localizedDescription.red)
        }
    }
    
    static func read(url: URL) -> GlboalConfig? {
        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(GlboalConfig.self, from: data)
            return config
        }
        catch {
            print(error.localizedDescription.red)
            return nil
        }
    }
}
