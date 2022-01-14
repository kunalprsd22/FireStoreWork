//
//  ImageSectionController.swift
//  FeedExample
//
//  Created by Simon Lee on 3/21/19.
//  Copyright © 2019 Shao Ping Lee. All rights reserved.
//

import UIKit
import IGListKit

class ImageSectionController: ListSectionController {
    var image: UIImage?

    override func sizeForItem(at index: Int) -> CGSize {
        let height = collectionContext?.containerSize.height ?? 0
        return CGSize(width: height * 2 / 3.0, height: height)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
         guard let cell =  collectionContext!.dequeueReusableCell(withNibName:"ImageCell", bundle: nil, for: self, at: index) as? ImageCell else { fatalError()}
        
        guard let image = image else { return cell}

        cell.imageView.image = image

        return cell
    }

    override func didUpdate(to object: Any) {
        image = object as? UIImage
    }

    override init() {
        super.init()
        self.inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    }
}
