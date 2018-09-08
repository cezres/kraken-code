//
//  Git.swift
//  kraken
//
//  Created by 晨风 on 2017/5/10.
//  Copyright © 2017年 晨风. All rights reserved.
//

import Foundation

/// 提交更新
///
/// - Parameter directory: git目录路径
/// - Returns: commit_id
func commit(directory: URL, message: String = "Update") -> String? {
    var result: String
    
    result = launchedShell(shell: "git pull origin master:master", directoryPath: directory.path)
    print(result)
    
    result = launchedShell(shell: "git add .", directoryPath: directory.path)
    if result.lengthOfBytes(using: .utf8) > 0 {
        fatalError("")
    }
    result = launchedShell(shell: "git commit -m \"\(message)\"", directoryPath: directory.path)
    print(result)
    result = launchedShell(shell: "git push -u origin master", directoryPath: directory.path)
    print(result)
    result = launchedShell(shell: "git rev-parse HEAD", directoryPath: directory.path)
    print("commit_id: " + result)
    return result.replacingOccurrences(of: "\n", with: "")
}

func pull(directory: URL) {
    var result: String
    result = launchedShell(shell: "git pull origin master:master", directoryPath: directory.path)
    print(result)
}

