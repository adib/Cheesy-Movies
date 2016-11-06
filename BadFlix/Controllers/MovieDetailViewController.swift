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
        () -> DateComponentsFormatter in
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.day,.hour,.minute]
        return formatter
    }()
    
    lazy var yearFormatter = {
        () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    var item : MovieEntity?
    
    func reloadData() {
        // TODO: add title year
        if let title = item?.title,
            let releaseDate = item?.releaseDate {
            // have both date and year

            let releaseDateStr = String(format: " (%@)", yearFormatter.string(from: releaseDate as Date))
            
            let font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
            let titleAttributes = [
                NSFontAttributeName : font,
                NSForegroundColorAttributeName : UIColor.black

            ]
            let yearAttributes  = [
                NSFontAttributeName : font,
                NSForegroundColorAttributeName : UIColor.darkGray
            ]
            let attributedTitle = NSMutableAttributedString(string: title, attributes: titleAttributes)
            attributedTitle.append(NSAttributedString(string:releaseDateStr,attributes:yearAttributes))
            titleLabel?.attributedText = attributedTitle
        } else {
            titleLabel?.text = item?.title ?? ""
        }
        
        var subtitleText = String()
        if let runtimeMinutes = item?.runtime {
            if runtimeMinutes > 0 {
                if let intervalText = runtimeFormatter.string(from: Double(runtimeMinutes) * 60) {
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
            subtitleText += genresStrings.joined(separator: ", ")
        }
        subtitleLabel?.text = subtitleText
        summaryLabel?.text = item?.overview ?? ""
        
        if let voteAverage = item?.voteAverage {
            let crapLevel = Int(round((10 - voteAverage) * 10))
            votesLabel?.text = NSString.localizedStringWithFormat(NSLocalizedString("🧀 %d%%", comment: "Crap Level Percentage") as NSString, crapLevel) as String
        } else {
            votesLabel?.text = "-"
        }
        
        productionHouseLabel?.text = item?.productionCompany ?? ""
        trailerPlayButton?.isHidden = item?.trailerURLString == nil
        
        if let castCtrl = castCollectionViewController {
            castCtrl.item = item?.casts
            castCtrl.reloadData()
        }
    }

    func reloadImages() {
        guard let   item = self.item,
                    let window = self.view?.window else {
            return
        }
        let nativeScale = window.screen.nativeScale
        let rescaleSize = {
            (size: CGSize)-> CGSize in
            if nativeScale > 1 {
                return CGSize(width: size.width * nativeScale, height: size.height * nativeScale)
            }
            return size
        }

        if let imageView = self.posterImageView,
                let imageURL = item.posterURL(rescaleSize(imageView.bounds.size)) {
            imageView.af_setImage(withURL: imageURL)
        }
        
        if let imageView = self.backdropImageView {
            let posterImageViewSize = rescaleSize(imageView.bounds.size)
            if let imageURL = item.backdropURL(posterImageViewSize) {
                imageView.af_setImage(withURL: imageURL)
            } else if let imageURL = item.posterURL(posterImageViewSize) {
                imageView.af_setImage(withURL: imageURL)
            }
        }
        
        if let castCtrl = castCollectionViewController {
            castCtrl.setNeedsReloadImages()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueIdentifier = segue.identifier
        if segueIdentifier == "embedCastCollectionView" {
            if let castCollectionCtrl = segue.destination as? CastPhotoCollectionViewController {
                castCollectionViewController = castCollectionCtrl
                castCollectionCtrl.item = item?.casts
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func showMovieTrailer(_ sender: AnyObject) {
        // TODO: get the trailer URL from the movie
        guard let   urlString = item?.trailerURLString,
                let targetURL = URL(string:urlString)  else {
            return
        }
        
        let safariCtrl = SFSafariViewController(url: targetURL, entersReaderIfAvailable: true)
        self.present(safariCtrl, animated: true, completion: { 
            self.trailerViewController = safariCtrl
        })
    }
    
    @IBAction func showActivities(_ sender: AnyObject) {
        // TODO: get the URL from the movie (either IMDB or the movie's home page
        guard let shareURLstring = item?.homepageURLString,
            let shareURL = URL(string:shareURLstring) else {
            return
        }
        
        let activityCtrl = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
        
        if let barButtonItem = sender as? UIBarButtonItem {
            activityCtrl.modalPresentationStyle = .popover
            activityCtrl.popoverPresentationController?.barButtonItem = barButtonItem
        }
        
        self.present(activityCtrl, animated: true, completion: nil)
    }



}

