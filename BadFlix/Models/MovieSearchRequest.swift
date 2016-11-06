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

class MovieSearchRequest : NSObject {
    var requestParameters : [String:AnyObject]?
    
    var requestPath  = "discover/movie"
    
    var title : String?
    
    var sortFunction : ((MovieEntity,MovieEntity) -> Bool)? = {
        (movie1,movie2) -> Bool in
        if let  vote1 = movie1.voteAverage,
            let vote2 = movie2.voteAverage {
            return vote1 < vote2
        }
        return movie1.movieID ?? 0 < movie2.movieID ?? 0
    }
    
    static let dateFormatter = {
        () -> DateFormatter in
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        // use ISO calendar since we're using this formatter for making Backend API calls
        df.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        return df
    }()
    
    override init() {
        super.init()

        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let beforeDate = (calendar as NSCalendar).date(byAdding: .month, value: -6, to: now, options: [.searchBackwards,.matchFirst])
        var params = [
            "sort_by" : "popularity.asc",
            "vote_count.gte" : 150
        ] as [String : Any]
        
        if let date = beforeDate {
            params["primary_release_date.gte"] = MovieSearchRequest.dateFormatter.string(from: date)
        }
        params["primary_release_date.lte"] = MovieSearchRequest.dateFormatter.string(from: today)
        
        requestParameters = params as [String : AnyObject]?
        
        title = NSLocalizedString("Cheesy Movies", comment: "Search Title")
    }
    
    init(publishYear:Int?,genre:GenreEntity?) {
        var params = [
            "sort_by" : "popularity.asc",
            "vote_count.gte" : 15
        ] as [String : Any]

        var searchTitle = String()
        
        if let selGenre = genre {
            let genreID  = selGenre.genreID
            if genreID != 0 {
                params["with_genres"] = NSNumber(value: genreID as Int64)
                searchTitle += selGenre.title ?? ""
            }
        } else {
            searchTitle += NSLocalizedString("All Genres", comment: "Search Title")
        }

        if let yearValue = publishYear {
            if !searchTitle.isEmpty {
                searchTitle += " "
            }
            searchTitle += String(format: "(%d)",yearValue)
            let calendar = Calendar.current

            var yearComponent = DateComponents()
            yearComponent.year = yearValue
            
            if let dateSelection = calendar.date(from: yearComponent) {
                var yearStartDateOpt : NSDate? = nil
                if  (calendar as NSCalendar).range(of: .year, start: &yearStartDateOpt, interval: nil, for: dateSelection),
                    let yearStartDate = yearStartDateOpt {
                    let yearStartDateStr = MovieSearchRequest.dateFormatter.string(from: yearStartDate as Date)
                    params["primary_release_date.gte"] = yearStartDateStr
                    
                    if let nextYearDate = (calendar as NSCalendar).date(byAdding: .year, value: 1, to: yearStartDate as Date, options: [.matchFirst]) {
                        var nextYearStartDateOpt : NSDate? = nil
                        if (calendar as NSCalendar).range(of: .year, start: &nextYearStartDateOpt, interval:nil,for:nextYearDate),
                            let nextYearStartDate = nextYearStartDateOpt,
                                let thisYearEndDate = (calendar as NSCalendar).date(byAdding: .day, value: -1, to: nextYearStartDate as Date, options: [.matchFirst,.searchBackwards]) {
                            let thisYearEndDateStr = MovieSearchRequest.dateFormatter.string(from: thisYearEndDate)
                            params["primary_release_date.lte"] = thisYearEndDateStr
                        }
                    }
                }
            }
        }
        
        title = searchTitle
        requestParameters = params as [String : AnyObject]?
    }
}
