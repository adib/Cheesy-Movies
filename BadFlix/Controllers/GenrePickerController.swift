//
//  GenrePickerController.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 30/4/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//  http://basilsalad.com

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class GenrePickerController: NSObject,UIPickerViewDataSource,UIPickerViewDelegate {

    let genreList = GenreList.defaultInstance
    
    var selectionList : [(String,GenreEntity?)]?
    
    @IBOutlet weak var pickerView: UIPickerView?
    
    @IBOutlet weak var delegate : GenrePickerControllerDelegate?
    
    func reloadData() {
        guard let genreMappings = genreList.currentMapping else {
            genreList.refresh({
                [weak self] (error) in
                guard error == nil else {
                    return
                }
                self?.reloadData()
            })
            return
        }
        
        var updatingSelectionList = Array<(String,GenreEntity?)>()
        updatingSelectionList.reserveCapacity(genreMappings.count + 1)
        
        for (_,genre) in genreMappings {
            if let title = genre.title {
                updatingSelectionList.append((title,genre))
            }
        }
        updatingSelectionList.sort( by: {
            $0.0 > $1.0
        })
        updatingSelectionList.insert((NSLocalizedString("All Genres", comment: "Genre Entry"),nil), at: 0)
        self.selectionList = updatingSelectionList
        
        pickerView?.reloadAllComponents()
    }
    
    func resetSelection(_ animated:Bool) {
        guard selectionList?.count > 0 else {
            return
        }
        
        self.pickerView?.selectRow(0, inComponent: 0, animated: animated)
    }
    
    // MARK: - Picker View
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let items = selectionList else {
            self.reloadData()
            return 0
        }
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let items = selectionList else {
            return ""
        }

        return items[row].0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let selectionEntry = selectionList?[row] {
            delegate?.genrePickerController(self, didSelectGenre: selectionEntry.1)
        }
    }
}


@objc protocol GenrePickerControllerDelegate {
    func genrePickerController(_ ctrl:GenrePickerController,didSelectGenre:GenreEntity?)
}
