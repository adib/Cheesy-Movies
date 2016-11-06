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
import CoreGraphics

class CastEntity {
    var castID = Int64(0)
    var performerName:String?
    var characterName:String?
    var profilePath : String?
    
    init(json: [String:AnyObject]) {
        if let number = json["id"] as? NSNumber {
            castID = number.int64Value
        }
        characterName = json["character"] as? String
        performerName = json["name"] as? String
        profilePath = json ["profile_path"] as? String
    }
    
    func profileURL(_ size: CGSize) -> URL? {
        guard let path = profilePath else {
            return nil
        }
        
        return MovieBackend.defaultInstance.getImageURL(path, type: .profile, size: size)
    }

    
    static func parse(_ json:[[String:AnyObject]]) -> [CastEntity] {
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
