//
//  MovieSummaryTableViewCell.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 1/5/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//

import UIKit

class MovieSummaryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backdropImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.backdropImageView.image = nil
    }
}
