//
//  PopOverVC.swift
//  Demo
//
//  Created by Appinventiv on 11/28/20.
//  Copyright © 2020 Appinventiv. All rights reserved.
//

import UIKit

class PopOverVC: UIViewController,UIPopoverPresentationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func click(_ sender: UIButton) {
        
        var popoverContent = (self.storyboard?.instantiateViewController(withIdentifier: "ThirdVC")) as! ThirdVC
            popoverContent.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = popoverContent.popoverPresentationController
            popoverContent.preferredContentSize = CGSize(width: 120, height: 40)
            popover?.delegate = self
            popover?.sourceView = sender
            popover?.permittedArrowDirections  = .up
            present(popoverContent, animated: true, completion:nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    

}
