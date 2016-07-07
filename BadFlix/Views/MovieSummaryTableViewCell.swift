//
//  MovieSummaryTableViewCell.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 1/5/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//  http://basilsalad.com

import UIKit
import AlamofireImage

class MovieSummaryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backdropImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let backdropImageView = self.backdropImageView {
            backdropImageView.af_cancelImageRequest()
            backdropImageView.image = nil
        }
        self.titleLabel.text = " "
    }
}
