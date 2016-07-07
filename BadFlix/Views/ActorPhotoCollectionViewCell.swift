//
//  ActorPhotoCollectionViewCell.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 1/5/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//  http://basilsalad.com

import UIKit
import AlamofireImage

class ActorPhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var actorNameLabel: UILabel!
    
    @IBOutlet weak var characterNameLabel: UILabel!
 
    override func prepareForReuse() {
        profileImageView?.af_cancelImageRequest()
        profileImageView?.image = nil
        actorNameLabel?.text = " "
        characterNameLabel?.text = " "
        super.prepareForReuse()
    }
}
