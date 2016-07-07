//
//  DetailViewController.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 30/4/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//  http://basilsalad.com

import UIKit
import SafariServices
import AlamofireImage

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var backdropImageView: UIImageView?

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    
    @IBOutlet weak var posterImageView: UIImageView?
    @IBOutlet weak var summaryLabel: UILabel?
    
    @IBOutlet weak var votesLabel: UILabel?
    
    @IBOutlet weak var productionHouseLabel: UILabel!
    
    @IBOutlet weak var trailerPlayButton: UIButton!
    
    weak var castCollectionViewController : CastPhotoCollectionViewController?
    
    var trailerViewController : SFSafariViewController?
 
    lazy var runtimeFormatter = {
        () -> NSDateComponentsFormatter in
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = .Abbreviated
        formatter.allowedUnits = [.Day,.Hour,.Minute]
        return formatter
    }()
    
    lazy var yearFormatter = {
        () -> NSDateFormatter in
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    var item : MovieEntity?
    
    func reloadData() {
        // TODO: add title year
        if let title = item?.title,
            releaseDate = item?.releaseDate {
            // have both date and year

            let releaseDateStr = String(format: " (%@)", yearFormatter.stringFromDate(releaseDate))
            
            let font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
            let titleAttributes = [
                NSFontAttributeName : font,
                NSForegroundColorAttributeName : UIColor.blackColor()

            ]
            let yearAttributes  = [
                NSFontAttributeName : font,
                NSForegroundColorAttributeName : UIColor.darkGrayColor()
            ]
            let attributedTitle = NSMutableAttributedString(string: title, attributes: titleAttributes)
            attributedTitle.appendAttributedString(NSAttributedString(string:releaseDateStr,attributes:yearAttributes))
            titleLabel?.attributedText = attributedTitle
        } else {
            titleLabel?.text = item?.title ?? ""
        }
        
        var subtitleText = String()
        if let runtimeMinutes = item?.runtime {
            if runtimeMinutes > 0 {
                if let intervalText = runtimeFormatter.stringFromTimeInterval(Double(runtimeMinutes) * 60) {
                    subtitleText += intervalText
                }
            }
        }
        
        if let genresArray = item?.genres {
            if !subtitleText.isEmpty {
                subtitleText += " | "
            }
            var genresStrings = Array<String>()
            genresStrings.reserveCapacity(genresArray.count)
            for genre in genresArray {
                if let title = genre.title {
                    genresStrings.append(title)
                }
            }
            subtitleText += genresStrings.joinWithSeparator(", ")
        }
        subtitleLabel?.text = subtitleText
        summaryLabel?.text = item?.overview ?? ""
        
        if let voteAverage = item?.voteAverage {
            let crapLevel = Int(round((10 - voteAverage) * 10))
            votesLabel?.text = NSString.localizedStringWithFormat(NSLocalizedString("🧀 %d%%", comment: "Crap Level Percentage"), crapLevel) as String
        } else {
            votesLabel?.text = "-"
        }
        
        productionHouseLabel?.text = item?.productionCompany ?? ""
        trailerPlayButton?.hidden = item?.trailerURLString == nil
        
        if let castCtrl = castCollectionViewController {
            castCtrl.item = item?.casts
            castCtrl.reloadData()
        }
    }

    func reloadImages() {
        guard let   item = self.item,
                    window = self.view?.window else {
            return
        }
        let nativeScale = window.screen.nativeScale
        let rescaleSize = {
            (size: CGSize)-> CGSize in
            if nativeScale > 1 {
                return CGSizeMake(size.width * nativeScale, size.height * nativeScale)
            }
            return size
        }

        if let imageView = self.posterImageView,
                imageURL = item.posterURL(rescaleSize(imageView.bounds.size)) {
            imageView.af_setImageWithURL(imageURL)
        }
        
        if let imageView = self.backdropImageView {
            let posterImageViewSize = rescaleSize(imageView.bounds.size)
            if let imageURL = item.backdropURL(posterImageViewSize) {
                imageView.af_setImageWithURL(imageURL)
            } else if let imageURL = item.posterURL(posterImageViewSize) {
                imageView.af_setImageWithURL(imageURL)
            }
        }
        
        if let castCtrl = castCollectionViewController {
            castCtrl.setNeedsReloadImages()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let item = self.item {
            reloadData()
            item.refresh({
                (error) in
                guard error == nil else {
                    // TODO: report error
                    return
                }
                self.reloadData()
                self.reloadImages()
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // image view sizes may have changed, thus an opportunity to get appropriately-sized images
        reloadImages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let segueIdentifier = segue.identifier
        if segueIdentifier == "embedCastCollectionView" {
            if let castCollectionCtrl = segue.destinationViewController as? CastPhotoCollectionViewController {
                castCollectionViewController = castCollectionCtrl
                castCollectionCtrl.item = item?.casts
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func showMovieTrailer(sender: AnyObject) {
        // TODO: get the trailer URL from the movie
        guard let   urlString = item?.trailerURLString,
                targetURL = NSURL(string:urlString)  else {
            return
        }
        
        let safariCtrl = SFSafariViewController(URL: targetURL, entersReaderIfAvailable: true)
        self.presentViewController(safariCtrl, animated: true, completion: { 
            self.trailerViewController = safariCtrl
        })
    }
    
    @IBAction func showActivities(sender: AnyObject) {
        // TODO: get the URL from the movie (either IMDB or the movie's home page
        guard let shareURLstring = item?.homepageURLString,
            shareURL = NSURL(string:shareURLstring) else {
            return
        }
        
        let activityCtrl = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
        
        if let barButtonItem = sender as? UIBarButtonItem {
            activityCtrl.modalPresentationStyle = .Popover
            activityCtrl.popoverPresentationController?.barButtonItem = barButtonItem
        }
        
        self.presentViewController(activityCtrl, animated: true, completion: nil)
    }



}

