//
//  GenreList.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 30/4/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//  http://basilsalad.com

import Foundation

private let genreListFileName = "GenreList.plist"

class GenreList {
    static let defaultInstance = GenreList()
    
    /// Mapping between ID and Genre, for the current language
    var currentMapping : Dictionary<Int64,GenreEntity>?
    
    
    
    func refresh(_ completionHandler: ((Error?) -> Void)? ) {
        // TODO: refresh list of genres
        MovieBackend.defaultInstance.requestJSON(path: "genre/movie/list") {
            (result, error) in
            guard error == nil else {
                completionHandler?(error)
                return
            }
            
            if let resultDict = result as? [String:AnyObject] {
                if let genresArray = resultDict["genres"] as? [[String:AnyObject]] {
                    var mapping = Dictionary<Int64,GenreEntity>(minimumCapacity:genresArray.count)
                    for genreDict in genresArray {
                        let genreObj = GenreEntity(json: genreDict)
                        if genreObj.genreID != 0 {
                            mapping[genreObj.genreID] = genreObj
                        }
                    }
                    if mapping.count > 0 {
                        self.currentMapping = mapping
                        self.save()
                    }
                }
            }

            completionHandler?(nil)
        }
    }
    
    required init() {
        let fileManager = FileManager.default
        if let cachesDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let genrePathString = cachesDir.appendingPathComponent(genreListFileName).path
            if let dict = NSKeyedUnarchiver.unarchiveObject(withFile: genrePathString) as? Dictionary<NSNumber,GenreEntity> {
                var ourDict = Dictionary<Int64,GenreEntity>()
                for (k,v) in dict {
                    ourDict[k.int64Value] = v
                }
                self.currentMapping = ourDict
            }
        }
    }
    
    /// Save the genre list into folder
    func save() {
        guard let mapping = self.currentMapping else {
            return
        }
        
        let processInfo = ProcessInfo.processInfo
        let activityToken = processInfo.beginActivity(options: [.background], reason: "Saving genre information")

        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            defer {
                processInfo.endActivity(activityToken)
            }
            let fileManager = FileManager.default
            guard let cachesDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                return
            }
            let genrePathString = cachesDir.appendingPathComponent(genreListFileName).path

            let serializedDict = NSMutableDictionary(capacity: mapping.count)
            for (k,v) in mapping {
                serializedDict.setObject(v, forKey: NSNumber(value: k as Int64))
            }
            NSKeyedArchiver.archiveRootObject(serializedDict, toFile: genrePathString)
        }
    }
}
