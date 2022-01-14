//
//  ImageListRow.swift
//  FeedExample
//
//  Created by Simon Lee on 3/21/19.
//  Copyright © 2019 Shao Ping Lee. All rights reserved.
//

import IGListKit
import UIKit

class ImageListRow: NSObject {
    let images: [UIImage]

    init(images: [UIImage]) {
        self.images = images
    }
}
