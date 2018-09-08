//
//  Podspec.swift
//  kraken
//
//  Created by 晨风 on 2017/5/23.
//  Copyright © 2017年 晨风. All rights reserved.
//

import Foundation


class Podspec {
    
    class func create(name: String, savePath: String) -> URL {
        var podspec = "Pod::Spec.new do |s| \n"
        podspec += "s.name = '\(name)' \n"
        podspec += "s.version = '1.0' \n"
        podspec += "s.summary = '\(name)' \n"
        podspec += "s.homepage = 'http://www.in66.com' \n"
        podspec += "s.license = 'MIT' \n"
        podspec += "s.author = { '\(Global.author_name)' => '\(Global.author_email)' } \n"
        podspec += "s.platform = :ios, '7.0' \n"
        podspec += "s.source = { :git => '\(Pod.source_git)', :commit => 'xxxx' } \n"
        podspec += "s.vendored_frameworks = '\(savePath)/\(name).framework' \n"
        podspec += "end\n"
        print(podspec)
        let writeURL = CurrentDirectory.appendingPathComponent("\(name).podspec")
        try? podspec.write(to: writeURL, atomically: true, encoding: .utf8)
        return writeURL
    }
    
    
    class func create(name: String) -> URL {
        var podspec = "Pod::Spec.new do |s| \n"
        podspec += "s.name = '\(name)' \n"
        podspec += "s.version = '1.0' \n"
        podspec += "s.summary = '\(name)' \n"
        podspec += "s.homepage = 'http://www.in66.com' \n"
        podspec += "s.license = 'MIT' \n"
        podspec += "s.author = { '\(Global.author_name)' => '\(Global.author_email)' } \n"
        podspec += "s.platform = :ios, '7.0' \n"
        podspec += "s.source = { :git => '\(Pod.source_git)', :commit => 'xxxx' } \n"
        podspec += "s.vendored_frameworks = '\(name).framework' \n"
        podspec += "end\n"
        print(podspec)
        let writeURL = CurrentDirectory.appendingPathComponent("\(name).podspec")
        try? podspec.write(to: writeURL, atomically: true, encoding: .utf8)
        return writeURL
    }
    
    class func update(podspecURL: URL, commit_id: String, version: String?) {
        guard var podspec = try? String(contentsOf: podspecURL, encoding: .utf8) else {
            print("读取podspec文件失败".red)
            exit(-1)
        }
        
        func replaceValue(flag: String, value: String) {
            guard var sRange = podspec.range(of: flag) else {
                print("更改\(value)失败".red)
                exit(-1)
            }
            sRange = podspec.range(of: "'", options: .caseInsensitive, range: Range(uncheckedBounds: (sRange.upperBound, podspec.endIndex)), locale: nil)!
            
            guard let eRange = podspec.range(of: "'", options: .caseInsensitive, range: Range(uncheckedBounds: (sRange.upperBound, podspec.endIndex)), locale: nil) else {
                print("更改\(value)失败".red)
                exit(-1)
            }
            let replaceSubrange = Range(uncheckedBounds: (sRange.upperBound, eRange.lowerBound))
            let newPodspec = podspec.replacingCharacters(in: replaceSubrange, with: value)
            
            podspec = newPodspec
        }
        
        
        replaceValue(flag: ":commit", value: commit_id)
        if let version = version {
            replaceValue(flag: "version", value: version)
        }
        
        print(podspec)
        
        try? podspec.write(to: podspecURL, atomically: true, encoding: .utf8)
    }
    
    class func value(podspecURL: URL, key: String) -> String? {
        guard let podspec = try? String(contentsOf: podspecURL, encoding: .utf8) else {
            print("读取podspec文件失败".red)
            return nil
        }
        guard var sRange = podspec.range(of: key) else {
            print("更改\(value)失败".red)
            return nil
        }
        sRange = podspec.range(of: "'", options: .caseInsensitive, range: Range(uncheckedBounds: (sRange.upperBound, podspec.endIndex)), locale: nil)!
        
        guard let eRange = podspec.range(of: "'", options: .caseInsensitive, range: Range(uncheckedBounds: (sRange.upperBound, podspec.endIndex)), locale: nil) else {
            print("更改\(value)失败".red)
            return nil
        }
        let subrange = Range(uncheckedBounds: (sRange.upperBound, eRange.lowerBound))
        return podspec.substring(with: subrange)
    }
    
    class func repoPush(podspec: URL, localRepoName: String = "PrivatePods") {
        let process = Process()
        process.currentDirectoryPath = podspec.deletingLastPathComponent().path
        process.launchPath = "/usr/local/bin/pod"
        process.arguments = ["repo", "push", localRepoName, podspec.lastPathComponent, "--use-libraries", "--allow-warnings", "--sources=git@githost.in66.cc:app/ios-galaxy-podspec.git,master"]
        process.launch()
        process.waitUntilExit()
    }
    
    class func specLint(podspec: URL) {
        let process = Process()
        process.currentDirectoryPath = podspec.deletingLastPathComponent().path
        process.launchPath = "/usr/local/bin/pod"
        process.arguments = ["spec", "lint", podspec.lastPathComponent, "--use-libraries", "--allow-warnings"]
        process.launch()
        process.waitUntilExit()
    }
    
    class func repoPushNotCheck(podspec: URL, name: String, version: String?, localRepoName: String = "PrivatePods") {
        // /Users/cezr/.cocoapods/repos
        let _version: String
        if version == nil {
            _version = value(podspecURL: podspec, key: "version") ?? ""
            if _version == "" {
                print("获取podspec版本出错".red)
                exit(-1)
            }
        }
        else {
            _version = version!
        }
        
        let repoURL = DocumentDirectory.appendingPathComponent(".cocoapods/repos/\(localRepoName)")
        guard FileManager.default.fileExists(atPath: repoURL.path) else {
            fatalError("不存在的pod repo  -  \(localRepoName)")
        }
        let podDirURL = repoURL.appendingPathComponent("\(name)/\(_version)")
        try? FileManager.default.createDirectory(at: podDirURL, withIntermediateDirectories: true, attributes: nil)
        
        pull(directory: repoURL)
        do {
            let toURL = podDirURL.appendingPathComponent(podspec.lastPathComponent)
            try? FileManager.default.removeItem(at: toURL)
            try FileManager.default.copyItem(at: podspec, to: toURL)
            _ = commit(directory: repoURL, message: "\(name) \(_version)")
        }
        catch {
            
        }
        
    }
    
    class func hasPodsName(podsName: String) -> Bool {
        
        let process = Process()
        process.launchPath = "/usr/local/bin/pod"
        process.arguments = ["repo", "list"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        let file = pipe.fileHandleForReading
        
        process.launch()
        process.waitUntilExit()
        
        let data = file.readDataToEndOfFile()
        
        guard let result = String(data: data, encoding: .utf8) else {
            return false
        }
        //        print(result)
        
        return result.range(of: podsName) != nil
    }
    
}

