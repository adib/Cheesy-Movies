//
//  MovieBackend.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 30/4/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//

import Foundation

private let backendConfigFileName = "BackendConfig.plist"

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
    
    
    func refresh(completionHandler: ((NSError?) -> Void)? ) {
        self.requestJSON("configuration") {
            (jsonObject : AnyObject?, error : NSError?) in
            defer {
                completionHandler?(error)
            }
            if let jsonDict = jsonObject as? Dictionary<String,AnyObject> {
                self.configuration = jsonDict
                self.saveConfiguration()
            }
        }
    }
    
    func requestJSON(path: String,completionHandler: (AnyObject?,NSError?) -> Void) {
        let requestURL = backendURL.URLByAppendingPathComponent(path)
        requestJSON(requestURL, completionHandler: completionHandler)
    }
    
    func requestJSON(URL: NSURL,completionHandler: (AnyObject?,NSError?) -> Void) {
        let task = NSURLSession.sharedSession().dataTaskWithURL(URL) {
            (resultData : NSData?, _ : NSURLResponse?, requestError : NSError?) in
            // TODO: handle error
            var needReturn = true
            var errorReturn : NSError? = nil
            defer {
                if needReturn {
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(nil,errorReturn)
                    })
                }
            }
            guard requestError == nil else {
                errorReturn = requestError
                return
            }
            if let resultDataObj = resultData {
                do {
                    let resultJSON = try NSJSONSerialization.JSONObjectWithData(resultDataObj, options: [])
                    needReturn = false
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(resultJSON,nil)
                    })
                } catch let error as NSError {
                    // TODO: handle error
                    print("error refreshing config: \(error)")
                    errorReturn = error
                }
            }
        }
        task.resume()
    }

    
    func saveConfiguration() {
        guard let currentConfig = self.configuration else {
            return
        }
        
        let processInfo = NSProcessInfo.processInfo()
        let activityToken = processInfo.beginActivityWithOptions([.Background], reason: "Saving backend configuration")
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            defer {
                processInfo.endActivity(activityToken)
            }

            let fileManager = NSFileManager.defaultManager()
            guard let cachesDir = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first,
                pathString = cachesDir.URLByAppendingPathComponent(backendConfigFileName).path else {
                    return
            }
            NSKeyedArchiver.archiveRootObject(currentConfig, toFile: pathString)
        }
    }
}