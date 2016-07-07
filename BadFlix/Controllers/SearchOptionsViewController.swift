//
//  SearchOptionsViewController.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 30/4/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//  http://basilsalad.com

import UIKit

class SearchOptionsViewController: UIViewController,GenrePickerControllerDelegate,UITextFieldDelegate {

    @IBOutlet var genrePickerController: GenrePickerController!
    
    @IBOutlet weak var releaseYearTextField: UITextField!
    
    @IBOutlet weak var delegate : SearchOptionsViewControllerDelegate?
    
    var selectedGenre : GenreEntity?
    var selectedReleaseYear : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setNeedsUpdateSearchResults() {
        let sel = #selector(SearchOptionsViewController.updateSearchResults)
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: sel, object: nil)
        self.performSelector(sel, withObject: nil, afterDelay: 0.3)
    }
    
    func updateSearchResults() {
        if let yearText = releaseYearTextField?.text,
            intValue = Int(yearText) {
            selectedReleaseYear = intValue
            releaseYearTextField?.text = String(format:"%d",intValue)
        } else {
            releaseYearTextField?.text = nil
            selectedReleaseYear = nil
        }
        
        let searchRequest : MovieSearchRequest
        if selectedReleaseYear == nil && selectedGenre == nil {
            searchRequest = MovieSearchRequest()
        } else {
            searchRequest = MovieSearchRequest(publishYear:selectedReleaseYear, genre: selectedGenre)
        }
        
        delegate?.searchOptionsViewController(self, updateMovieSearchRequest: searchRequest)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Actions

    @IBAction func resetForm(sender: AnyObject) {
        genrePickerController?.resetSelection(true)
        releaseYearTextField?.text = nil
        releaseYearTextField?.resignFirstResponder()
        selectedGenre = nil
        selectedReleaseYear = nil
        setNeedsUpdateSearchResults()
    }
    
    @IBAction func applyForm(sender: AnyObject) {
        releaseYearTextField?.resignFirstResponder()
        setNeedsUpdateSearchResults()
    }
    

    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        setNeedsUpdateSearchResults()
        return true
    }
    
    // MARK: - GenrePickerControllerDelegate
    func genrePickerController(ctrl: GenrePickerController, didSelectGenre genre: GenreEntity?) {
        selectedGenre = genre
        setNeedsUpdateSearchResults()
    }

}


@objc protocol SearchOptionsViewControllerDelegate  {
    func searchOptionsViewController(ctrl : SearchOptionsViewController,updateMovieSearchRequest:MovieSearchRequest)
}