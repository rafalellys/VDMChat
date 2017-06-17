//
//  MemoryStorage.swift
//  VDMChat
//
//  Created by Rafael on 2017-06-16.
//  Copyright © 2017 Tony. All rights reserved.
//

import UIKit

class MemoryStorage: NSObject {
    
    static let instance: MemoryStorage = {
        let instance = MemoryStorage()
        return instance
    }()

    var username:String?
    
    
}
