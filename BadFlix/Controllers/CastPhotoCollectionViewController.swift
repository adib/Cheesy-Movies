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
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: sel, object: nil)
        self.perform(sel, with: nil, afterDelay: 0)
    }
    
    func reloadImages() {
        guard let collectionView = self.collectionView else {
            return
        }
        
        let visibleIndexes = collectionView.indexPathsForVisibleItems
        collectionView.reloadItems(at: visibleIndexes)
    }
    
    /*
    // MARK: - Navigation
     */


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let item = self.item else {
            return 0
        }
        return item.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        if let actorCell = cell as? ActorPhotoCollectionViewCell,
                let castItem = item?[indexPath.row] {
            actorCell.actorNameLabel?.text = castItem.performerName
            actorCell.characterNameLabel?.text = castItem.characterName
            
            let nativeScale = collectionView.window?.screen.nativeScale ?? 1
            let rescaleSize = {
                (size: CGSize)-> CGSize in
                if nativeScale > 1 {
                    return CGSize(width: size.width * nativeScale, height: size.height * nativeScale)
                }
                return size
            }

            var itemSize = CGSize(width: 200,height: 200)
            // at this point of time, the collectionView item may not have laid out its subviews, hence we can't ask for the image view's size
            // the next best thing would be to use the layout's item size
            if let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout {
                itemSize = rescaleSize(flowLayout.itemSize)
            }
            
            if let imageURL = castItem.profileURL(itemSize) {
                actorCell.profileImageView?.af_setImage(withURL:imageURL)
            }
        }
        // Configure the cell
    
        return cell
    }


}
