//
//  FourthVC.swift
//  Demo
//
//  Created by Appinventiv on 11/23/20.
//  Copyright © 2020 Appinventiv. All rights reserved.
//

import UIKit
import AVFoundation

class FourthVC: UIViewController  {
    
    static let sharedInstance = FourthVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
}



class Text:UITabBarController{
    
    static let sharedInstance = Text()
    
    func callText(){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObserver()
    }
    
    func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("NotificationIdentifier"), object: nil)
        print("add observer")
    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        print("calling")
    }
    
    func removeObserverS(){
        NotificationCenter.default.removeObserver(self)
    }
    
}
