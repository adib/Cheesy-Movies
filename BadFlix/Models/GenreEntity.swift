//
//  GenreEntity.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 30/4/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//

import Foundation


class GenreEntity : NSObject,NSCoding {
    var title : String?
    var genreID = Int64(0)
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        title = aDecoder.decodeObjectForKey("title") as? String
        genreID = aDecoder.decodeInt64ForKey("genreID")
    }
    
    init(json:[String:AnyObject]) {
        if let number = json["id"] as? NSNumber {
            genreID = number.longLongValue
        }
        title = json["name"] as? String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        if let v = title {
            aCoder.encodeObject(v, forKey: "title")
        }
        aCoder.encodeInt64(genreID, forKey: "genreID")
    }
    
    
    override func isEqual(object: AnyObject?) -> Bool {
        guard let otherGenre = object as? GenreEntity else {
            return false
        }
        return otherGenre.genreID == genreID
    }

    override var hash : Int {
        get {
            return Int(genreID)
        }
    }
    
    static func parse(json:[[String:AnyObject]]) -> [GenreEntity] {
        var resultArray = Array<GenreEntity>()
        resultArray.reserveCapacity(json.count)
        for genreDict in json {
            let genreObj = GenreEntity(json: genreDict)
            if genreObj.genreID != 0 {
                resultArray.append(genreObj)
            }
        }
        return resultArray
    }
}