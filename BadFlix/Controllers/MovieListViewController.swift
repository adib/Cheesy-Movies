//
//  MasterViewController.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 30/4/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//  http://basilsalad.com

import UIKit
import AlamofireImage

private let searchOptionsAnimationDuration : TimeInterval = 0.2
private let searchOptionsAnimationDelay  : TimeInterval = 0
private let searchOptionsAnimationOptions : UIViewAnimationOptions =  [.beginFromCurrentState, .curveEaseOut]


class MovieListViewController: UITableViewController,SearchOptionsViewControllerDelegate {

    @IBOutlet var searchOptionsView: UIView!
    
    weak var searchOptionsController : SearchOptionsViewController?
    
    var showingSearchOptions = false
    
    var searchResults : [MovieEntity]?
    
    lazy var yearFormatter = {
        () -> DateFormatter in
        let formatter = DateFormatter()
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
        tableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[searchOptionsView]|", options: [], metrics: nil, views: viewBindings))
        tableView.addConstraint(NSLayoutConstraint(item: searchOptionsView, attribute: .bottom, relatedBy: .equal, toItem: tableView, attribute: .top, multiplier: 1, constant: 0))
        tableView.addConstraint(NSLayoutConstraint(item: searchOptionsView, attribute: .width, relatedBy: .equal, toItem: tableView, attribute: .width, multiplier: 1, constant: 0))
        tableView.addConstraint(NSLayoutConstraint(item: searchOptionsView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 216+44))
        

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if searchResults == nil {
            self.performSearch(MovieSearchRequest())
        }
    }

    func performSearch(_ request : MovieSearchRequest) {
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

    @IBAction func toggleSearchOptions(_ sender: AnyObject) {
        let showingSearch = showingSearchOptions
        if showingSearch {
            // hide search options
        }
        
        let scrollView = tableView as UIScrollView
        let topOffset = topLayoutGuide.length
        let headerFrame = searchOptionsView.frame
        
        if !showingSearch {
            // toggle to show search
            UIView.animate(withDuration: searchOptionsAnimationDuration, delay:searchOptionsAnimationDelay, options:searchOptionsAnimationOptions,  animations: {
                scrollView.contentInset = UIEdgeInsetsMake(headerFrame.size.height + topOffset, 0, 0, 0)
                }, completion: {
                    (completed: Bool) in
                    self.tableView.setContentOffset(CGPoint(x: 0, y: -(headerFrame.size.height + topOffset)), animated: true)
                    self.showingSearchOptions = true
            })
        } else {
            // toggle to hide search
            UIView.animate(withDuration: searchOptionsAnimationDuration, delay:searchOptionsAnimationDelay, options:searchOptionsAnimationOptions, animations: {
                scrollView.contentInset = UIEdgeInsetsMake(topOffset, 0, 0, 0)
                }, completion: {
                    (completed: Bool) in
                    self.showingSearchOptions = false
            })
        }

    }
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        defer {
            // fixup back button
            if let  navController = segue.destination as? UINavigationController,
                    let topViewController = navController.topViewController,
                    let displayModeButtonItem = self.splitViewController?.displayModeButtonItem {
                let navItem  = topViewController.navigationItem
                navItem.leftBarButtonItem = displayModeButtonItem
                navItem.leftItemsSupplementBackButton = true
            }
        }
        let segueIdentifier = segue.identifier
        if segueIdentifier == "showMovie" {
            if let  indexPath = self.tableView.indexPathForSelectedRow,
                    let selectedItem = searchResults?[indexPath.row],
                    let navController = segue.destination as? UINavigationController,
                    let detailController = navController.topViewController as? MovieDetailViewController {
                detailController.item = selectedItem
            }
        } else if segueIdentifier == "embedSearchOptions" {
            if let searchCtrl = segue.destination as? SearchOptionsViewController {
                searchCtrl.delegate = self
                self.searchOptionsController = searchCtrl
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = searchResults {
            return items.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tableViewBounds = tableView.bounds
        return round(max(tableViewBounds.size.width / 1.78, 44) / 2) * 2 + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieSummaryCell", for: indexPath)
        let row = indexPath.row
        
        if let  movieCell = cell as? MovieSummaryTableViewCell,
                let movieItem = searchResults?[row]  {
            
            if let  title = movieItem.title,
                    let releaseDate = movieItem.releaseDate {
                movieCell.titleLabel.text = String(format: "%@ (%@)",title,yearFormatter.string(from: releaseDate as Date))
            } else {
                movieCell.titleLabel.text = movieItem.title
            }

            var requestSize = CGSize(width: tableView.bounds.width, height: tableView.rowHeight)
            if let nativeScale = tableView.window?.screen.nativeScale {
                if nativeScale > 1 {
                    requestSize.width *= nativeScale
                    requestSize.height *= nativeScale
                }
            }
            
            if let backdropURL = movieItem.backdropURL(requestSize) {
                movieCell.backdropImageView.af_setImage(withURL: backdropURL)
            } else if let posterURL = movieItem.posterURL(requestSize) {
                movieCell.backdropImageView.af_setImage(withURL: posterURL)
            }
        }
        return cell
    }

    
    // MARK: - Scroll View

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let topOffset = topLayoutGuide.length
        let headerFrame = searchOptionsView.frame
        if decelerate && scrollView.contentOffset.y < -(topOffset + 44) {
            UIView.animate(withDuration: searchOptionsAnimationDuration, delay:searchOptionsAnimationDelay, options:searchOptionsAnimationOptions,  animations: {
                 scrollView.contentInset = UIEdgeInsetsMake(headerFrame.size.height + topOffset, 0, 0, 0)
                }, completion: {
                    (completed: Bool) in
                    self.showingSearchOptions = true
            })
        } else {
            UIView.animate(withDuration: searchOptionsAnimationDuration, delay:searchOptionsAnimationDelay, options:searchOptionsAnimationOptions, animations: {
                scrollView.contentInset = UIEdgeInsetsMake(topOffset, 0, 0, 0)
                }, completion: {
                    (completed: Bool) in
                    self.showingSearchOptions = false
            })
        }
    }
    
    // MARK: - SearchOptionsViewControllerDelegate
    
    func searchOptionsViewController(_ ctrl: SearchOptionsViewController, updateMovieSearchRequest: MovieSearchRequest) {
        self.performSearch(updateMovieSearchRequest)
    }
}

