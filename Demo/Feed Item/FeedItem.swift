//
//  FeedItem.swift
//  FeedExample
//
//  Created by Simon Lee on 3/21/19.
//  Copyright © 2019 Shao Ping Lee. All rights reserved.
//

import UIKit
import IGListKit

class FeedItem: NSObject {
    let rows: [ListDiffable]

    init(rows: [ListDiffable]) {
        self.rows = rows
    }

}
