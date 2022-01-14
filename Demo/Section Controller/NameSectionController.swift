//
//  NameSectionController.swift
//  MyIgListKit
//
//  Created by Appinventiv on 5/10/20.
//  Copyright © 2020 Appinventiv. All rights reserved.
//

import UIKit
import IGListKit

class NameSectionController: ListSectionController {
    var textRow: TextRow?

    override init() {
      super.init()
        
    }
    
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext?.containerSize.width ?? 0.0,height: 50)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
       let cell =  collectionContext!.dequeueReusableCell(withNibName:"LabelCell", bundle: nil, for: self, at: index)
        if let cell = cell as? LabelCell{
            cell.name.text = textRow?.text
        }
       return cell
     }
    
    override func didUpdate(to object: Any) {
      textRow = object as? TextRow
        
    }
    
    override func didSelectItem(at index: Int) {
        print(index)
    }
    
}


