//
//  PerformerEntity.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 30/4/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//

import Foundation
import CoreGraphics

class CastEntity {
    var castID = Int64(0)
    var performerName:String?
    var characterName:String?
    var profilePath : String?
    
    init(json: [String:AnyObject]) {
        if let number = json["id"] as? NSNumber {
            castID = number.longLongValue
        }
        characterName = json["character"] as? String
        performerName = json["name"] as? String
        profilePath = json ["profile_path"] as? String
    }
    
    func profileURL(size: CGSize) -> NSURL? {
        guard let path = profilePath else {
            return nil
        }
        
        return MovieBackend.defaultInstance.getImageURL(path, type: .Profile, size: size)
    }

    
    static func parse(json:[[String:AnyObject]]) -> [CastEntity] {
        var resultArray = Array<CastEntity>()
        resultArray.reserveCapacity(json.count)
        for dict in json {
            let castObj = CastEntity(json: dict)
            if castObj.castID != 0 {
                resultArray.append(castObj)
            }
        }
        return resultArray
    }
}