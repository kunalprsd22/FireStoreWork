//
//  FeedItem.swift
//  FeedExample
//
//  Created by Simon Lee on 3/21/19.
//  Copyright © 2019 Shao Ping Lee. All rights reserved.
//

import UIKit
import IGListKit

class FeedItem: ListDiffable {
    let pk: Int
    let rows: [ListDiffable]

    init(pk: Int, rows: [ListDiffable]) {
        self.pk = pk
        self.rows = rows
    }

    func diffIdentifier() -> NSObjectProtocol {
        return pk as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? FeedItem else { return false }
        return zip(rows, object.rows).allSatisfy({ $0.isEqual(toDiffableObject: $1) })
    }
}
