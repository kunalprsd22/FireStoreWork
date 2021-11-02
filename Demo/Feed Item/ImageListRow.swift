//
//  ImageListRow.swift
//  FeedExample
//
//  Created by Simon Lee on 3/21/19.
//  Copyright © 2019 Shao Ping Lee. All rights reserved.
//

import IGListKit
import UIKit

class ImageListRow: ListDiffable {
    let pk: Int
    let images: [UIImage]

    init(pk: Int, images: [UIImage]) {
        self.pk = pk
        self.images = images
    }

    func diffIdentifier() -> NSObjectProtocol {
        return pk as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? ImageListRow else { return false }
        return images == object.images
    }
}
