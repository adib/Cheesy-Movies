//
//  CastPhotoCollectionViewController.swift
//  BadFlix
//
//  Created by Sasmito Adibowo on 30/4/16.
//  Copyright © 2016 Basil Salad Software. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ActorPhotoCell"

class CastPhotoCollectionViewController: UICollectionViewController {
    
    var item : [CastEntity]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bounds = self.view.bounds
        if let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            var itemSize  = bounds.size
            itemSize.width = round(bounds.size.height * 2 / 3)
            if flowLayout.itemSize != itemSize {
                flowLayout.itemSize = itemSize
                setNeedsReloadImages()
            }
        }
    }
    
    func reloadData() {
        self.collectionView?.reloadData()
    }
    
    func setNeedsReloadImages() {
        let sel = #selector(CastPhotoCollectionViewController.reloadImages)
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: sel, object: nil)
        self.performSelector(sel, withObject: nil, afterDelay: 0)
    }
    
    func reloadImages() {
        guard let collectionView = self.collectionView else {
            return
        }
        
        let visibleIndexes = collectionView.indexPathsForVisibleItems()
        collectionView.reloadItemsAtIndexPaths(visibleIndexes)
    }
    
    /*
    // MARK: - Navigation
     */


    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let item = self.item else {
            return 0
        }
        return item.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
        if let actorCell = cell as? ActorPhotoCollectionViewCell,
                castItem = item?[indexPath.row] {
            actorCell.actorNameLabel?.text = castItem.performerName
            actorCell.characterNameLabel?.text = castItem.characterName
            
            let nativeScale = collectionView.window?.screen.nativeScale ?? 1
            let rescaleSize = {
                (size: CGSize)-> CGSize in
                if nativeScale > 1 {
                    return CGSizeMake(size.width * nativeScale, size.height * nativeScale)
                }
                return size
            }

            var itemSize = CGSizeMake(200,200)
            // at this point of time, the collectionView item may not have laid out its subviews, hence we can't ask for the image view's size
            // the next best thing would be to use the layout's item size
            if let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout {
                itemSize = rescaleSize(flowLayout.itemSize)
            }
            
            if let imageURL = castItem.profileURL(itemSize) {
                actorCell.profileImageView?.af_setImageWithURL(imageURL)
            }
        }
        // Configure the cell
    
        return cell
    }


}
