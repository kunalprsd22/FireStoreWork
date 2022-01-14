//
//  GrowingVC.swift
//  Demo
//
//  Created by Appinventiv on 12/20/20.
//  Copyright © 2020 Appinventiv. All rights reserved.
//

import UIKit

class GrowingVC: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func click(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil, userInfo:nil)
    }
    
    
}


