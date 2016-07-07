//
//  MovieEntity.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 30/4/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//  http://basilsalad.com

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
    
    var homepageURLString : String?
    
    var trailerURLString : String?
    
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
        
        var homepage = json["homepage"] as? String
        if homepage == nil || homepage?.isEmpty ?? true {
            if let imdb = json["imdb_id"] as? String {
                homepage = "https://www.imdb.com/title/\(imdb)/"
            }
        }
        homepageURLString = homepage
        
        if let  videosDict = json["videos"] as? [String:AnyObject],
                videoResults = videosDict["results"] as? [[String:AnyObject]],
                firstVideo = videoResults.first {
            if firstVideo["site"] as? String == "YouTube" {
                if let youtubeID = firstVideo["key"] {
                    trailerURLString = "https://www.youtube.com/embed/\(youtubeID)"
                }
            }
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
    
    func refresh(completionHandler: ((NSError?) -> Void)? ) {
        guard let movieID = self.movieID else {
            // TODO: report error of missing ID
            completionHandler?(nil)
            return
        }
        let params = [
            "append_to_response" : "videos,credits"
        ]
        MovieBackend.defaultInstance.requestJSON("movie/\(movieID)",parameters: params, completionHandler:  {
            (jsonObject,error) in
            guard error == nil, let resultDict = jsonObject as? [String:AnyObject] else {
                completionHandler?(error)
                return
            }
            
            self.update(resultDict)
            completionHandler?(nil)
        })
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