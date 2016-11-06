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


class GenreEntity : NSObject,NSCoding {
    var title : String?
    var genreID = Int64(0)
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        title = aDecoder.decodeObject(forKey: "title") as? String
        genreID = aDecoder.decodeInt64(forKey: "genreID")
    }
    
    init(json:[String:AnyObject]) {
        if let number = json["id"] as? NSNumber {
            genreID = number.int64Value
        }
        title = json["name"] as? String
    }
    
    func encode(with aCoder: NSCoder) {
        if let v = title {
            aCoder.encode(v, forKey: "title")
        }
        aCoder.encode(genreID, forKey: "genreID")
    }
    
    
    override func isEqual(_ object: Any?) -> Bool {
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
    
    static func parse(_ json:[[String:AnyObject]]) -> [GenreEntity] {
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
