//
//  ArrayExtension.swift
//  kraken
//
//  Created by 晨风 on 2017/7/14.
//  Copyright © 2017年 晨风. All rights reserved.
//

import Foundation


extension Array {
    
    func subarray(range: NSRange) -> [Element] {
        let array = NSArray(array: self)
        return array.subarray(with: range) as! [Element]
    }
    
    var deleteFirst: [Element] {
        return subarray(range: NSMakeRange(1, count - 1))
    }
    
}

extension Array where Element: Equatable {
    
    func has(any: Element) -> Index {
        for value in self.enumerated() {
            if value.element == any {
                return value.offset
            }
        }
        return -1
    }
    
    
    
}




