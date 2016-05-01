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
}