// Cheesy Movies
// Copyright (C) 2016  Sasmito Adibowo – http://cutecoder.org

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation
import Alamofire

private let backendConfigFileName = "BackendConfig.plist"

private let apiKey = "900a1c8214b1686a76c5fd0f50150be0"

enum ImageType {
    case backdrop
    case poster
    case profile
}

class MovieBackend {
    static let defaultInstance = MovieBackend()
    
    lazy var backendURL = {
        return URL(string:"https://api.themoviedb.org/3/")!
    }()
    
    var configuration : Dictionary<String,Any>?
    
    var imageSizeMap  = Dictionary<ImageType,Array<(CGFloat,String)>>()
    
    required init() {
        let fileManager = FileManager.default
        if let cachesDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let filePathString = cachesDir.appendingPathComponent(backendConfigFileName).path
            if let dict = NSKeyedUnarchiver.unarchiveObject(withFile: filePathString) as? Dictionary<String,AnyObject> {
                self.imageSizeMap.removeAll(keepingCapacity:true)
                self.configuration = dict
            }
        }
    }
    
    
    func refresh(_ completionHandler: ((Error?) -> Void)? ) {
        self.requestJSON(path:"configuration") {
            (jsonObject : Any?, error : Error?) in
            defer {
                completionHandler?(error)
            }
            if let jsonDict = jsonObject as? Dictionary<String,Any> {
                self.configuration = jsonDict
                self.saveConfiguration()
            }
        }
    }

    func requestJSON(path: String,completionHandler: @escaping (Any?,Error?) -> Void) {
        requestJSON(path:path,parameters:nil,completionHandler: completionHandler)
    }

    func requestJSON(path: String,parameters:[String:Any]?,completionHandler: @escaping (Any?,Error?) -> Void) {
        let requestURL = backendURL.appendingPathComponent(path)
        requestJSON(url:requestURL, parameters:parameters,completionHandler: completionHandler)
    }
    
    func requestJSON(url: Foundation.URL,parameters : [String:Any]? ,completionHandler: @escaping (Any?,Error?) -> Void) {
        var requestParams = parameters ?? Dictionary<String,Any>()
        requestParams["api_key"] = apiKey
        Alamofire.request(url, method: .get, parameters: requestParams).responseJSON {
            response in
            completionHandler(response.result.value,response.result.error)
        }
    }
    
    func getImageURL(_ path:String,type:ImageType,size: CGSize) -> URL? {
        guard let   currentConfig = self.configuration,
                    let imageConfig = currentConfig["images"] as? [String:AnyObject],
                    let imageBaseString = imageConfig["secure_base_url"] as? String else {
            return nil
        }
        
        var sizesArrayOpt = imageSizeMap[type]
        if sizesArrayOpt == nil {
            let sizesKey : String
            switch type {
            case .backdrop:
                sizesKey = "backdrop_sizes"
            case .poster:
                sizesKey = "poster_sizes"
            case .profile:
                sizesKey = "profile_sizes"
            }
            if let  sizesList = imageConfig[sizesKey] as? [String] {
                let sizesCount = sizesList.count
                if sizesCount > 0 {
                    sizesArrayOpt = Array<(CGFloat,String)>()
                    sizesArrayOpt?.reserveCapacity(sizesList.count)
                    for entry in sizesList {
                        if entry.hasPrefix("w") {
                            if let floatValue = Float(entry.substring(from: entry.characters.index(after: entry.startIndex))) {
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
        
        return URL(string: urlString)
    }

    
    func saveConfiguration() {
        guard let currentConfig = self.configuration else {
            return
        }
        
        let processInfo = ProcessInfo.processInfo
        let activityToken = processInfo.beginActivity(options: [.background], reason: "Saving backend configuration")
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            defer {
                processInfo.endActivity(activityToken)
            }

            let fileManager = FileManager.default
            guard let cachesDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                    return
            }
            let pathString = cachesDir.appendingPathComponent(backendConfigFileName).path 
            NSKeyedArchiver.archiveRootObject(currentConfig, toFile: pathString)
        }
    }
}
