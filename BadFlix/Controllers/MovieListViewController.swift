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

private let maxSearchResultsDisplay = 10

class MovieListViewController: UITableViewController {

    @IBOutlet var searchOptionsView: UIView!
    
    @IBOutlet var genrePickerController: GenrePickerController!
    
    var showingSearchOptions = false
    
    var searchResults : [MovieEntity]? {
        didSet {
            if let newValueArray = searchResults  {
                let newCount = newValueArray.count
                if newCount > maxSearchResultsDisplay {
                    // Trim the results because the requirements says so
                    searchResults?.removeRange(maxSearchResultsDisplay..<newCount)
                }
            }
        }
    }

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
            MovieEntity.search(MovieSearchRequest()) {
                [weak self] (entities, error) in
                guard error == nil else {
                    print("Search error: \(error?.localizedDescription)")
                    return
                }
                self?.searchResults = entities
                self?.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if segue.identifier == "showMovie" {
            if let  indexPath = self.tableView.indexPathForSelectedRow,
                    selectedItem = searchResults?[indexPath.row],
                    navController = segue.destinationViewController as? UINavigationController,
                    detailController = navController.topViewController as? MovieDetailViewController {
                detailController.item = selectedItem
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
            movieCell.titleLabel.text = movieItem.title

            var requestSize = CGSizeMake(tableView.bounds.width, tableView.rowHeight)
            if let nativeScale = tableView.window?.screen.nativeScale {
                if nativeScale > 1 {
                    requestSize.width *= nativeScale
                    requestSize.height *= nativeScale
                }
            }
            
            if let backdropURL = movieItem.backdropURL(requestSize) {
                movieCell.backdropImageView.af_setImageWithURL(backdropURL)
            }
        }
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
//            objects.removeAtIndex(indexPath.row)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
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


}

