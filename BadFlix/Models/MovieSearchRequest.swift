//
//  MovieSearch.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 1/5/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//

import Foundation

class MovieSearchRequest : NSObject {
    var requestParameters : [String:AnyObject]?
    
    var requestPath  = "discover/movie"
    
    var sortFunction : ((MovieEntity,MovieEntity) -> Bool)? = {
        (movie1,movie2) -> Bool in
        if let  vote1 = movie1.voteAverage,
            vote2 = movie2.voteAverage {
            return vote1 < vote2
        }
        return movie1.movieID ?? 0 < movie2.movieID ?? 0
    }
    
    static let dateFormatter = {
        () -> NSDateFormatter in
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        // use ISO calendar since we're using this formatter for making Backend API calls
        df.calendar = NSCalendar(identifier: NSCalendarIdentifierISO8601)
        return df
    }()
    
    override init() {
        super.init()

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
    }
    
    init(publishYear:Int?,genre:GenreEntity?) {
        var params = [
            "sort_by" : "popularity.asc",
            "vote_count.gte" : 1
        ]
        
        if let yearValue = publishYear {
            let calendar = NSCalendar.currentCalendar()

            let yearComponent = NSDateComponents()
            yearComponent.year = yearValue
            
            if let dateSelection = calendar.dateFromComponents(yearComponent) {
                var yearStartDateOpt : NSDate? = nil
                if  calendar.rangeOfUnit(.Year, startDate: &yearStartDateOpt, interval: nil, forDate: dateSelection),
                    let yearStartDate = yearStartDateOpt {
                    let yearStartDateStr = MovieSearchRequest.dateFormatter.stringFromDate(yearStartDate)
                    params["primary_release_date.gte"] = yearStartDateStr
                    
                    if let nextYearDate = calendar.dateByAddingUnit(.Year, value: 1, toDate: yearStartDate, options: [.MatchFirst]) {
                        var nextYearStartDateOpt : NSDate? = nil
                        if calendar.rangeOfUnit(.Year, startDate: &nextYearStartDateOpt, interval:nil,forDate:nextYearDate),
                            let nextYearStartDate = nextYearStartDateOpt,
                                thisYearEndDate = calendar.dateByAddingUnit(.Day, value: -1, toDate: nextYearStartDate, options: [.MatchFirst,.SearchBackwards]) {
                            let thisYearEndDateStr = MovieSearchRequest.dateFormatter.stringFromDate(thisYearEndDate)
                            params["primary_release_date.lte"] = thisYearEndDateStr
                        }
                    }
                }
            }
        }
        
        if let selGenre = genre {
            let genreID  = selGenre.genreID
            if genreID != 0 {
                params["with_genres"] = NSNumber(longLong:genreID)
            }
        }
    
        requestParameters = params
    }
}