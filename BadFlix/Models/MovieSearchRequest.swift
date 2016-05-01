//
//  MovieSearch.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 1/5/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//

import Foundation

struct MovieSearchRequest {
    var requestParameters : [String:AnyObject]?
    
    var requestPath : String
    
    var sortFunction : ((MovieEntity,MovieEntity) -> Bool)?
    
    static let dateFormatter = {
        () -> NSDateFormatter in
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    init() {
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let today = calendar.startOfDayForDate(now)
        let beforeDate = calendar.dateByAddingUnit(.Month, value: -6, toDate: now, options: [.SearchBackwards,.MatchFirst])
        var params = [
            "sort_by" : "popularity.asc",
            "vote_count.gte" : 150
        ]
        
        if let date = beforeDate {
            params["primary_release_date.gte"] = MovieSearchRequest.dateFormatter.stringFromDate(date)
        }
        params["primary_release_date.lte"] = MovieSearchRequest.dateFormatter.stringFromDate(today)
        
        requestParameters = params
        requestPath = "discover/movie"
        // TODO: sort function
        sortFunction = {
            (movie1,movie2) -> Bool in
            if let  vote1 = movie1.voteAverage,
                    vote2 = movie2.voteAverage {
                return vote1 < vote2
            }
            return movie1.movieID ?? 0 < movie2.movieID ?? 0
        }
    }
}