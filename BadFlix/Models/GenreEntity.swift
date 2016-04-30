//
//  GenreEntity.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 30/4/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//

import Foundation


class GenreEntity : NSObject,NSCoding {
    var title = ""
    var genreID = Int64(0)
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        title = aDecoder.decodeObjectForKey("title") as? String ?? ""
        genreID = aDecoder.decodeInt64ForKey("genreID")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeInt64(genreID, forKey: "genreID")
    }
}