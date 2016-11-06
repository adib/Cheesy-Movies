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
