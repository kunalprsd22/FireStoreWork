//
//  ViewController.swift
//  Demo
//
//  Created by Appinventiv on 5/19/20.
//  Copyright © 2020 Appinventiv. All rights reserved.
//

import UIKit
import IGListKit

class ViewController: UIViewController {

    
   
@IBOutlet weak var collectionView: UICollectionView!
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    
    let data: [FeedItem] = [
        FeedItem(rows: [ TextRow(text: "Foo"),
        ImageListRow(images: [UIImage(named: "image1")!,UIImage(named: "image2")!])
        ]),
        FeedItem(rows: [ TextRow(text: "Bar"),
        ImageListRow(images: [UIImage(named: "image3")!,UIImage(named: "image4")!])
        ])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adapter.collectionView = collectionView
        adapter.dataSource = self
        adapter.performUpdates(animated: true, completion: nil)
       
    }
    
    


}



extension ViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data.flatMap { (value) -> [ListDiffable] in
            value.rows
        }
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is TextRow:
            return NameSectionController()
        case is ImageListRow:
            return ImageListSectionController()
        default:
           return  ListSectionController()
        }
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}



