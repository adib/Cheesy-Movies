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
    
    // MARK: - Picker View
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        self.pickerView = pickerView
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
}
