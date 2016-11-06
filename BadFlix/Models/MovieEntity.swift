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

class MovieEntity {
    var movieID : Int64?
    var title: String?
    var overview: String?
    var releaseDate: Date?
    var popularity : Float32?
    var voteAverage : Float32?
    
    var productionCompany : String?
    var runtime : Float32?
    
    var posterPath : String?
    var backdropPath : String?
    var genres : Array<GenreEntity>?
    var casts : Array<CastEntity>?
    
    var homepageURLString : String?
    
    var trailerURLString : String?
    
    init(json:[String:AnyObject]) {
        self.update(json)
    }
    
    func update(_ json:[String:AnyObject]) {
        if let number = json["id"] as? NSNumber {
            movieID = number.int64Value
        }
        title = json["original_title"] as? String
        overview = json["overview"] as? String
        if let dateStr = json["release_date"] as? String {
            releaseDate = MovieSearchRequest.dateFormatter.date(from: dateStr)
        }
        
        if let number = json["popularity"] as? NSNumber {
            popularity = number.floatValue
        }
        if let number = json["vote_average"] as? NSNumber {
            voteAverage = number.floatValue
        }
        
        if let companies = json["production_companies"] as? [[String:AnyObject]],
                let firstCompany = companies.first  {
            productionCompany = firstCompany["name"] as? String
        }
        
        if let number = json["runtime"] as? NSNumber {
            runtime = number.floatValue
        }
        
        posterPath = json["poster_path"] as? String
        backdropPath = json["backdrop_path"] as? String
        
        if let genresArray = json["genres"] as? [[String:AnyObject]] {
            genres = GenreEntity.parse(genresArray)
        }

        if let  creditsDict = json["credits"] as? [String:AnyObject],
                let castArray = creditsDict["cast"] as? [[String:AnyObject]] {
            casts = CastEntity.parse(castArray)
        }
        
        var homepage = json["homepage"] as? String
        if homepage == nil || homepage?.isEmpty ?? true {
            if let imdb = json["imdb_id"] as? String {
                homepage = "https://www.imdb.com/title/\(imdb)/"
            }
        }
        homepageURLString = homepage
        
        if let  videosDict = json["videos"] as? [String:AnyObject],
                let videoResults = videosDict["results"] as? [[String:AnyObject]],
                let firstVideo = videoResults.first {
            if firstVideo["site"] as? String == "YouTube" {
                if let youtubeID = firstVideo["key"] {
                    trailerURLString = "https://www.youtube.com/embed/\(youtubeID)"
                }
            }
        }
    }
    
    func posterURL(_ size: CGSize) -> URL? {
        guard let path = posterPath else {
            return nil
        }
        
        return MovieBackend.defaultInstance.getImageURL(path, type: .poster, size: size)
    }
    
    func backdropURL(_ size:CGSize) -> URL? {
        guard let path = backdropPath else {
            return nil
        }
        
        return MovieBackend.defaultInstance.getImageURL(path, type: .backdrop, size: size)
    }
    
    func refresh(_ completionHandler: ((Error?) -> Void)? ) {
        guard let movieID = self.movieID else {
            // TODO: report error of missing ID
            completionHandler?(nil)
            return
        }
        let params = [
            "append_to_response" : "videos,credits"
        ]
        MovieBackend.defaultInstance.requestJSON(path:"movie/\(movieID)",parameters: params, completionHandler:  {
            (jsonObject,error) in
            guard error == nil, let resultDict = jsonObject as? [String:AnyObject] else {
                completionHandler?(error)
                return
            }
            
            self.update(resultDict)
            completionHandler?(nil)
        })
    }
    
    static func parse(_ json:[[String:AnyObject]]) -> [MovieEntity] {
        var resultArray = Array<MovieEntity>()
        resultArray.reserveCapacity(json.count)
        for dict in json {
            let obj = MovieEntity(json: dict)
            if obj.movieID != nil {
                resultArray.append(obj)
            }
        }
        return resultArray
    }

    static func search(_ request:MovieSearchRequest,completionHandler: @escaping ([MovieEntity]?,Error?) -> Void) {
        let backend = MovieBackend.defaultInstance
        backend.requestJSON(path:request.requestPath, parameters: request.requestParameters) {
            (resultObject, resultError) in
            guard resultError == nil else {
                completionHandler(nil,resultError)
                return
            }
            if let  resultDict = resultObject as? [String:AnyObject],
                    let resultEntries = resultDict["results"] as? [[String:AnyObject]] {
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async(execute: { 
                    var moviesArray = MovieEntity.parse(resultEntries)
                    if let sortFunction = request.sortFunction {
                        moviesArray.sort(by: sortFunction)
                    }
                    DispatchQueue.main.async(execute: {
                        completionHandler(moviesArray,nil)
                    })
                })
            } else {
                completionHandler(nil,nil)
            }
        }
    }
    
}
