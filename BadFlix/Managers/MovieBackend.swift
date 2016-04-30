//
//  MovieBackend.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 30/4/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//

import Foundation

private let backendConfigFileName = "GenreList.plist"

private let apiKey = "900a1c8214b1686a76c5fd0f50150be0"

class MovieBackend {
    static let defaultInstance = MovieBackend()
    
    lazy var backendURL = {
        return NSURL(string:"https://api.themoviedb.org/3/")!
    }()
    
    var configuration : Dictionary<String,AnyObject>?
    
    required init() {
        let fileManager = NSFileManager.defaultManager()
        if let cachesDir = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first,
            filePathString = cachesDir.URLByAppendingPathComponent(backendConfigFileName).path {
            if let dict = NSKeyedUnarchiver.unarchiveObjectWithFile(filePathString) as? Dictionary<String,AnyObject> {
                self.configuration = dict
            }
        }
    }
    
    
    func refresh(completionHandler: dispatch_block_t) {
        // TODO: refresh configuration
    }

    
    func saveConfiguration() {
        guard let currentConfig = self.configuration else {
            return
        }
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            let fileManager = NSFileManager.defaultManager()
            guard let cachesDir = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first,
                pathString = cachesDir.URLByAppendingPathComponent(backendConfigFileName).path else {
                    return
            }
            NSKeyedArchiver.archiveRootObject(currentConfig, toFile: pathString)
        }
    }

}