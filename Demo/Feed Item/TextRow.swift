//
//  TextRow.swift
//  FeedExample
//
//  Created by Simon Lee on 3/21/19.
//  Copyright © 2019 Shao Ping Lee. All rights reserved.
//

import UIKit
import IGListKit

class TextRow: ListDiffable {
    let pk: Int
    let text: String

    init(pk: Int, text: String) {
        self.pk = pk
        self.text = text
    }

    func diffIdentifier() -> NSObjectProtocol {
        return pk as NSObjectProtocol
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? TextRow else { return false }
        return text == object.text
    }
}
