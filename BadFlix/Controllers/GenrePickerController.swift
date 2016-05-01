//
//  GenrePickerController.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 30/4/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//

import UIKit

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
        updatingSelectionList.sortInPlace( {
            $0.0 > $1.0
        })
        updatingSelectionList.insert((NSLocalizedString("All Genres", comment: "Genre Entry"),nil), atIndex: 0)
        self.selectionList = updatingSelectionList
        
        pickerView?.reloadAllComponents()
    }
    
    func resetSelection(animated:Bool) {
        guard selectionList?.count > 0 else {
            return
        }
        
        self.pickerView?.selectRow(0, inComponent: 0, animated: animated)
    }
    
    // MARK: - Picker View
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let items = selectionList else {
            self.reloadData()
            return 0
        }
        return items.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let items = selectionList else {
            return ""
        }

        return items[row].0
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let selectionEntry = selectionList?[row] {
            delegate?.genrePickerController(self, didSelectGenre: selectionEntry.1)
        }
    }
}


@objc protocol GenrePickerControllerDelegate {
    func genrePickerController(ctrl:GenrePickerController,didSelectGenre:GenreEntity?)
}
