//
//  StringExtension.swift
//  kraken
//
//  Created by 晨风 on 2017/7/14.
//  Copyright © 2017年 晨风. All rights reserved.
//

import Foundation


extension String {
    
    var deletePathExtension: String {
        return NSString(string: self).deletingPathExtension
    }
    
    var deleteLinefeed: String {
        return replacingOccurrences(of: "\n", with: "")
    }
    
}
