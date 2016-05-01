//
//  MovieBackend.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 30/4/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//

import Foundation
import Alamofire

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
        requestJSON(path,parameters:nil,completionHandler: completionHandler)
    }

    func requestJSON(path: String,parameters:[String:AnyObject]?,completionHandler: (AnyObject?,NSError?) -> Void) {
        let requestURL = backendURL.URLByAppendingPathComponent(path)
        requestJSON(requestURL, parameters:nil,completionHandler: completionHandler)
    }
    
    func requestJSON(URL: NSURL,parameters : [String:AnyObject]? ,completionHandler: (AnyObject?,NSError?) -> Void) {
        var requestParams = parameters ?? Dictionary<String,AnyObject>()
        requestParams["api_key"] = apiKey
        Alamofire.request(.GET, URL,parameters: requestParams).responseJSON {
            ( response : Response<AnyObject,NSError>) in
            completionHandler(response.result.value,response.result.error)
        }
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