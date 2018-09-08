//
//  main.swift
//  kraken
//
//  Created by 晨风 on 2017/5/10.
//  Copyright © 2017年 晨风. All rights reserved.
//

import Foundation
//CommandLine.arguments = ["kraken", "push", "INZip", "1.0.4"]
//CommandLine.arguments = ["kraken", "init", "INUIKit"]
//CommandLine.arguments = ["kraken", "push", "INUIKit.podspec"]

// print(CommandLine.arguments)

// CommandLine.arguments


let VERSION = "1.2.0"
let CurrentDirectory = URL(fileURLWithPath: Process().currentDirectoryPath, isDirectory: true)


Global.initialize()

Main().handler(arguments: CommandLine.arguments.deleteFirst)




