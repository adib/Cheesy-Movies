//
//  MovieEntity.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 30/4/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//

import Foundation
import CoreGraphics

class MovieEntity {
    var movieID : Int64?
    var title: String?
    var overview: String?
    var releaseDate: NSDate?
    var popularity : Float32?
    var voteAverage : Float32?
    
    var productionCompany : String?
    var runtime : Float32?
    
    var posterPath : String?
    var backdropPath : String?
    var genres : Array<GenreEntity>?
    var casts : Array<CastEntity>?
    
    init(json:[String:AnyObject]) {
        self.update(json)
    }
    
    func update(json:[String:AnyObject]) {
        if let number = json["id"] as? NSNumber {
            movieID = number.longLongValue
        }
        title = json["original_title"] as? String
        overview = json["overview"] as? String
        if let dateStr = json["release_date"] as? String {
            releaseDate = MovieSearchRequest.dateFormatter.dateFromString(dateStr)
        }
        
        if let number = json["popularity"] as? NSNumber {
            popularity = number.floatValue
        }
        if let number = json["vote_average"] as? NSNumber {
            voteAverage = number.floatValue
        }
        
        if let companies = json["production_companies"] as? [[String:AnyObject]],
                firstCompany = companies.first  {
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
                castArray = creditsDict["cast"] as? [[String:AnyObject]] {
            casts = CastEntity.parse(castArray)
        }
    }
    
    func posterURL(size: CGSize) -> NSURL? {
        guard let path = posterPath else {
            return nil
        }
        
        return MovieBackend.defaultInstance.getImageURL(path, type: .Poster, size: size)
    }
    
    func backdropURL(size:CGSize) -> NSURL? {
        guard let path = backdropPath else {
            return nil
        }
        
        return MovieBackend.defaultInstance.getImageURL(path, type: .Backdrop, size: size)
    }
    
    static func parse(json:[[String:AnyObject]]) -> [MovieEntity] {
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

    static func search(request:MovieSearchRequest,completionHandler: ([MovieEntity]?,NSError?) -> Void) {
        let backend = MovieBackend.defaultInstance
        backend.requestJSON(request.requestPath, parameters: request.requestParameters) {
            (resultObject, resultError) in
            guard resultError == nil else {
                completionHandler(nil,resultError)
                return
            }
            if let  resultDict = resultObject as? [String:AnyObject],
                    resultEntries = resultDict["results"] as? [[String:AnyObject]] {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), { 
                    var moviesArray = MovieEntity.parse(resultEntries)
                    if let sortFunction = request.sortFunction {
                        moviesArray.sortInPlace(sortFunction)
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(moviesArray,nil)
                    })
                })
            } else {
                completionHandler(nil,nil)
            }
        }
    }
    
}