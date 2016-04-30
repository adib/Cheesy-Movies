//
//  DetailViewController.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 30/4/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//

import UIKit
import SafariServices

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    var trailerViewController : SFSafariViewController?
 

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func showMovieTrailer(sender: AnyObject) {
        // TODO: get the trailer URL from the movie
        let urlString = "https://www.youtube.com/embed/qUp7Qgimn38"
        if let targetURL = NSURL(string:urlString) {
            let safariCtrl = SFSafariViewController(URL: targetURL, entersReaderIfAvailable: true)
            self.presentViewController(safariCtrl, animated: true, completion: { 
                self.trailerViewController = safariCtrl
            })
        }
    }
    
    @IBAction func showActivities(sender: AnyObject) {
        // TODO: get the URL from the movie (either IMDB or the movie's home page
        guard let shareURL = NSURL(string:"https://example.com") else {
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

