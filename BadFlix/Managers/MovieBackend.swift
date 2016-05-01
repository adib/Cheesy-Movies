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

enum ImageType {
    case Backdrop
    case Poster
    case Profile
}

class MovieBackend {
    static let defaultInstance = MovieBackend()
    
    lazy var backendURL = {
        return NSURL(string:"https://api.themoviedb.org/3/")!
    }()
    
    var configuration : Dictionary<String,AnyObject>?
    
    var imageSizeMap  = Dictionary<ImageType,Array<(CGFloat,String)>>()
    
    required init() {
        let fileManager = NSFileManager.defaultManager()
        if let cachesDir = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first,
            filePathString = cachesDir.URLByAppendingPathComponent(backendConfigFileName).path {
            if let dict = NSKeyedUnarchiver.unarchiveObjectWithFile(filePathString) as? Dictionary<String,AnyObject> {
                self.imageSizeMap.removeAll(keepCapacity:true)
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
        requestJSON(requestURL, parameters:parameters,completionHandler: completionHandler)
    }
    
    func requestJSON(URL: NSURL,parameters : [String:AnyObject]? ,completionHandler: (AnyObject?,NSError?) -> Void) {
        var requestParams = parameters ?? Dictionary<String,AnyObject>()
        requestParams["api_key"] = apiKey
        Alamofire.request(.GET, URL,parameters: requestParams).responseJSON {
            ( response : Response<AnyObject,NSError>) in
            completionHandler(response.result.value,response.result.error)
        }
    }
    
    func getImageURL(path:String,type:ImageType,size: CGSize) -> NSURL? {
        guard let   currentConfig = self.configuration,
                    imageConfig = currentConfig["images"] as? [String:AnyObject],
                    imageBaseString = imageConfig["secure_base_url"] as? String else {
            return nil
        }
        
        var sizesArrayOpt = imageSizeMap[type]
        if sizesArrayOpt == nil {
            let sizesKey : String
            switch type {
            case .Backdrop:
                sizesKey = "backdrop_sizes"
            case .Poster:
                sizesKey = "poster_sizes"
            case .Profile:
                sizesKey = "profile_sizes"
            }
            if let  sizesList = imageConfig[sizesKey] as? [String] {
                let sizesCount = sizesList.count
                if sizesCount > 0 {
                    sizesArrayOpt = Array<(CGFloat,String)>()
                    sizesArrayOpt?.reserveCapacity(sizesList.count)
                    for entry in sizesList {
                        if entry.hasPrefix("w") {
                            if let floatValue = Float(entry.substringFromIndex(entry.startIndex.successor())) {
                                sizesArrayOpt?.append((CGFloat(floatValue),entry))
                            }
                        }
                    }
                    imageSizeMap[type] = sizesArrayOpt
                }
            }
        }
        
        guard let sizesArray = sizesArrayOpt else {
            return nil
        }

        var sizePath = "original"
        for (width,path) in sizesArray {
            if width >= size.width {
                sizePath = path
                break
            }
        }
        
        let urlString = "\(imageBaseString)\(sizePath)\(path)"
        
        return NSURL(string: urlString)
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