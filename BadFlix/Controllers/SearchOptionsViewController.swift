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
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: sel, object: nil)
        self.perform(sel, with: nil, afterDelay: 0.3)
    }
    
    func updateSearchResults() {
        if let yearText = releaseYearTextField?.text,
            let intValue = Int(yearText) {
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

    @IBAction func resetForm(_ sender: AnyObject) {
        genrePickerController?.resetSelection(true)
        releaseYearTextField?.text = nil
        releaseYearTextField?.resignFirstResponder()
        selectedGenre = nil
        selectedReleaseYear = nil
        setNeedsUpdateSearchResults()
    }
    
    @IBAction func applyForm(_ sender: AnyObject) {
        releaseYearTextField?.resignFirstResponder()
        setNeedsUpdateSearchResults()
    }
    

    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        setNeedsUpdateSearchResults()
        return true
    }
    
    // MARK: - GenrePickerControllerDelegate
    func genrePickerController(_ ctrl: GenrePickerController, didSelectGenre genre: GenreEntity?) {
        selectedGenre = genre
        setNeedsUpdateSearchResults()
    }

}


@objc protocol SearchOptionsViewControllerDelegate  {
    func searchOptionsViewController(_ ctrl : SearchOptionsViewController,updateMovieSearchRequest:MovieSearchRequest)
}
