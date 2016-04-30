//
//  MovieEntity.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 30/4/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//

import Foundation

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
    
}