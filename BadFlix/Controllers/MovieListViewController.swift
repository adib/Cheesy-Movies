//
//  MasterViewController.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 30/4/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//

import UIKit
import AlamofireImage

private let searchOptionsAnimationDuration : NSTimeInterval = 0.2
private let searchOptionsAnimationDelay  : NSTimeInterval = 0
private let searchOptionsAnimationOptions : UIViewAnimationOptions =  [.BeginFromCurrentState, .CurveEaseOut]


class MovieListViewController: UITableViewController,SearchOptionsViewControllerDelegate {

    @IBOutlet var searchOptionsView: UIView!
    
    weak var searchOptionsController : SearchOptionsViewController?
    
    var showingSearchOptions = false
    
    var searchResults : [MovieEntity]?
    
    lazy var yearFormatter = {
        () -> NSDateFormatter in
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        searchOptionsView.translatesAutoresizingMaskIntoConstraints = false
        let viewBindings = [
            "searchOptionsView" : searchOptionsView
        ]
        tableView.addSubview(searchOptionsView)
        tableView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[searchOptionsView]|", options: [], metrics: nil, views: viewBindings))
        tableView.addConstraint(NSLayoutConstraint(item: searchOptionsView, attribute: .Bottom, relatedBy: .Equal, toItem: tableView, attribute: .Top, multiplier: 1, constant: 0))
        tableView.addConstraint(NSLayoutConstraint(item: searchOptionsView, attribute: .Width, relatedBy: .Equal, toItem: tableView, attribute: .Width, multiplier: 1, constant: 0))
        tableView.addConstraint(NSLayoutConstraint(item: searchOptionsView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 216+44))
        

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if searchResults == nil {
            self.performSearch(MovieSearchRequest())
        }
    }

    func performSearch(request : MovieSearchRequest) {
        MovieEntity.search(request) {
            [weak self] (entities, error) in
            guard error == nil else {
                print("Search error: \(error?.localizedDescription)")
                return
            }
            self?.searchResults = entities
            self?.tableView.reloadData()
            self?.title = request.title
        }
    }
    // MARK: - Actions

    @IBAction func toggleSearchOptions(sender: AnyObject) {
        let showingSearch = showingSearchOptions
        if showingSearch {
            // hide search options
        }
        
        let scrollView = tableView as UIScrollView
        let topOffset = topLayoutGuide.length
        let headerFrame = searchOptionsView.frame
        
        if !showingSearch {
            // toggle to show search
            UIView.animateWithDuration(searchOptionsAnimationDuration, delay:searchOptionsAnimationDelay, options:searchOptionsAnimationOptions,  animations: {
                scrollView.contentInset = UIEdgeInsetsMake(headerFrame.size.height + topOffset, 0, 0, 0)
                }, completion: {
                    (completed: Bool) in
                    self.tableView.setContentOffset(CGPointMake(0, -(headerFrame.size.height + topOffset)), animated: true)
                    self.showingSearchOptions = true
            })
        } else {
            // toggle to hide search
            UIView.animateWithDuration(searchOptionsAnimationDuration, delay:searchOptionsAnimationDelay, options:searchOptionsAnimationOptions, animations: {
                scrollView.contentInset = UIEdgeInsetsMake(topOffset, 0, 0, 0)
                }, completion: {
                    (completed: Bool) in
                    self.showingSearchOptions = false
            })
        }

    }
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        defer {
            // fixup back button
            if let  navController = segue.destinationViewController as? UINavigationController,
                    topViewController = navController.topViewController,
                    displayModeButtonItem = self.splitViewController?.displayModeButtonItem() {
                let navItem  = topViewController.navigationItem
                navItem.leftBarButtonItem = displayModeButtonItem
                navItem.leftItemsSupplementBackButton = true
            }
        }
        let segueIdentifier = segue.identifier
        if segueIdentifier == "showMovie" {
            if let  indexPath = self.tableView.indexPathForSelectedRow,
                    selectedItem = searchResults?[indexPath.row],
                    navController = segue.destinationViewController as? UINavigationController,
                    detailController = navController.topViewController as? MovieDetailViewController {
                detailController.item = selectedItem
            }
        } else if segueIdentifier == "embedSearchOptions" {
            if let searchCtrl = segue.destinationViewController as? SearchOptionsViewController {
                searchCtrl.delegate = self
                self.searchOptionsController = searchCtrl
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = searchResults {
            return items.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let tableViewBounds = tableView.bounds
        return round(max(tableViewBounds.size.width / 1.78, 44) / 2) * 2 + 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieSummaryCell", forIndexPath: indexPath)
        let row = indexPath.row
        
        if let  movieCell = cell as? MovieSummaryTableViewCell,
                movieItem = searchResults?[row]  {
            
            if let  title = movieItem.title,
                    releaseDate = movieItem.releaseDate {
                movieCell.titleLabel.text = String(format: "%@ (%@)",title,yearFormatter.stringFromDate(releaseDate))
            } else {
                movieCell.titleLabel.text = movieItem.title
            }

            var requestSize = CGSizeMake(tableView.bounds.width, tableView.rowHeight)
            if let nativeScale = tableView.window?.screen.nativeScale {
                if nativeScale > 1 {
                    requestSize.width *= nativeScale
                    requestSize.height *= nativeScale
                }
            }
            
            if let backdropURL = movieItem.backdropURL(requestSize) {
                movieCell.backdropImageView.af_setImageWithURL(backdropURL)
            } else if let posterURL = movieItem.posterURL(requestSize) {
                movieCell.backdropImageView.af_setImageWithURL(posterURL)
            }
        }
        return cell
    }

    
    // MARK: - Scroll View

    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let topOffset = topLayoutGuide.length
        let headerFrame = searchOptionsView.frame
        if decelerate && scrollView.contentOffset.y < -(topOffset + 44) {
            UIView.animateWithDuration(searchOptionsAnimationDuration, delay:searchOptionsAnimationDelay, options:searchOptionsAnimationOptions,  animations: {
                 scrollView.contentInset = UIEdgeInsetsMake(headerFrame.size.height + topOffset, 0, 0, 0)
                }, completion: {
                    (completed: Bool) in
                    self.showingSearchOptions = true
            })
        } else {
            UIView.animateWithDuration(searchOptionsAnimationDuration, delay:searchOptionsAnimationDelay, options:searchOptionsAnimationOptions, animations: {
                scrollView.contentInset = UIEdgeInsetsMake(topOffset, 0, 0, 0)
                }, completion: {
                    (completed: Bool) in
                    self.showingSearchOptions = false
            })
        }
    }
    
    // MARK: - SearchOptionsViewControllerDelegate
    
    func searchOptionsViewController(ctrl: SearchOptionsViewController, updateMovieSearchRequest: MovieSearchRequest) {
        self.performSearch(updateMovieSearchRequest)
    }
}

